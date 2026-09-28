// Support code of the live tests: credentials, secret scrubbing, logging
// and helpers to wait for the providers.
//
// Printing is how the live tests report what they did.
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:upcloud/upcloud.dart';

/// Variables read by the live tests, from the environment or the `.env`
/// file at the root of the repository (the environment wins).
abstract final class LiveVars {
  /// API key of a StreamHG account.
  static const streamHgKey = 'STREAMHG_API_KEY';

  /// API key of an EarnVids account.
  static const earnVidsKey = 'EARNVIDS_API_KEY';

  /// API key of a Byse account.
  static const byseKey = 'BYSE_API_KEY';

  /// Email of a MediaFire account.
  static const mediaFireEmail = 'MEDIAFIRE_EMAIL';

  /// Password of a MediaFire account.
  static const mediaFirePassword = 'MEDIAFIRE_PASSWORD';

  /// Optional: id of an own MediaFire application (defaults to the public
  /// one of the library).
  static const mediaFireApplicationId = 'MEDIAFIRE_APPLICATION_ID';

  /// Optional: secret key of that application.
  static const mediaFireApiKey = 'MEDIAFIRE_API_KEY';

  /// Optional: comma separated ids of the providers to test (all those with
  /// credentials by default).
  static const providers = 'UPCLOUD_LIVE_PROVIDERS';

  /// Optional: `1` logs every HTTP request (with secrets redacted).
  static const verbose = 'UPCLOUD_LIVE_VERBOSE';

  /// Variables whose values must never be printed.
  static const List<String> secrets = [
    streamHgKey,
    earnVidsKey,
    byseKey,
    mediaFireEmail,
    mediaFirePassword,
    mediaFireApplicationId,
    mediaFireApiKey,
  ];
}

/// Parses the `KEY=value` lines of a `.env` file.
///
/// Supports `export` prefixes, comments, blank lines and values in single
/// or double quotes.
Map<String, String> parseDotEnv(String text) {
  final line = RegExp(r'^\s*(?:export\s+)?([A-Za-z_]\w*)\s*=\s*(.*?)\s*$');
  final values = <String, String>{};
  for (final raw in const LineSplitter().convert(text)) {
    if (raw.trimLeft().startsWith('#')) continue;
    final match = line.firstMatch(raw);
    if (match == null) continue;
    var value = match.group(2)!;
    final quote = value.isEmpty ? '' : value[0];
    if ((quote == '"' || quote == "'") &&
        value.length >= 2 &&
        value.endsWith(quote)) {
      value = value.substring(1, value.length - 1);
    } else {
      // Unquoted values end at an inline comment.
      value = value.replaceFirst(RegExp(r'\s+#.*$'), '');
    }
    values[match.group(1)!] = value;
  }
  return values;
}

/// Credentials of the live tests.
final class LiveEnv {
  LiveEnv._(this._file);

  /// Reads the `.env` file of the current directory or of the closest
  /// parent that has one (the repository root when running from
  /// `packages/upcloud`).
  factory LiveEnv.load() {
    var dir = Directory.current.absolute;
    while (true) {
      final file = File('${dir.path}${Platform.pathSeparator}.env');
      if (file.existsSync()) {
        return LiveEnv._(parseDotEnv(file.readAsStringSync()));
      }
      final parent = dir.parent;
      if (parent.path == dir.path) return LiveEnv._(const {});
      dir = parent;
    }
  }

  final Map<String, String> _file;

  /// Value of the variable [name], or `null` when missing or empty.
  String? operator [](String name) {
    final value = Platform.environment[name]?.trim();
    if (value != null && value.isNotEmpty) return value;
    final fromFile = _file[name]?.trim();
    return fromFile == null || fromFile.isEmpty ? null : fromFile;
  }

  /// Variables of [names] without a value.
  List<String> missing(Iterable<String> names) => [
    for (final name in names)
      if (this[name] == null) name,
  ];

  late final List<Pattern> _secrets = () {
    final values = {
      for (final name in LiveVars.secrets)
        if (this[name] case final value? when value.length >= 3) ...[
          value,
          Uri.encodeComponent(value),
          Uri.encodeQueryComponent(value),
        ],
    }.toList()..sort((a, b) => b.length.compareTo(a.length));
    return [
      for (final value in values)
        RegExp(RegExp.escape(value), caseSensitive: false),
    ];
  }();

  /// [value] as text with every credential replaced by `<redacted>`.
  String scrub(Object? value) {
    var text = '$value';
    for (final secret in _secrets) {
      text = text.replaceAll(secret, '<redacted>');
    }
    return text;
  }

  /// Prints [message] without credentials.
  void log(String message) => print(scrub(message));

  /// Runs [body] and rethrows its errors without credentials.
  Future<T> guard<T>(FutureOr<T> Function() body) async {
    try {
      return await body();
    } on TestFailure catch (e, st) {
      Error.throwWithStackTrace(TestFailure(scrub(e.message)), st);
    } on Object catch (e, st) {
      Error.throwWithStackTrace(LiveError(scrub(describeError(e))), st);
    }
  }
}

/// An error of a live test, with credentials removed from its message.
final class LiveError extends Error {
  /// Creates the error.
  LiveError(this.message);

  /// Description of the original error.
  final String message;

  @override
  String toString() => message;
}

/// Short description of [error]: its type and message, without the
/// response or cause it may carry.
String describeError(Object error) => switch (error) {
  ProviderException(:final message, :final statusCode) =>
    'ProviderException${statusCode == null ? '' : ' ($statusCode)'}: '
        '$message',
  UpCloudException(:final message) => '${error.runtimeType}: $message',
  _ => '$error',
};

/// Id of this run: UTC time and a random suffix, made of lowercase letters,
/// digits and dashes (e.g. `20260928-101500-k3x9`).
String liveRunId() {
  final now = DateTime.now().toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  final random = Random();
  const letters = 'abcdefghijkmnpqrstuvwxyz23456789';
  final suffix = [
    for (var i = 0; i < 4; i++) letters[random.nextInt(letters.length)],
  ].join();
  return '${now.year}${two(now.month)}${two(now.day)}-'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}-$suffix';
}

/// Letters and digits of [text], lowercased: hosts turn `a-b_c.mp4` into
/// titles such as `a b c`.
String alphanumeric(String text) =>
    text.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// Writes a copy of [sample] to [path] followed by an MP4 `free` box
/// holding [tag].
///
/// Every copy has its own content (hosts may deduplicate identical files)
/// and stays a valid MP4 file.
File uniqueVideo(File sample, String path, String tag) {
  final payload = utf8.encode('upcloud-live $tag');
  final size = ByteData(4)..setUint32(0, 8 + payload.length);
  final bytes = BytesBuilder(copy: false)
    ..add(sample.readAsBytesSync())
    ..add(size.buffer.asUint8List())
    ..add(ascii.encode('free'))
    ..add(payload);
  return File(path)..writeAsBytesSync(bytes.takeBytes());
}

/// Calls [action] until [until] accepts its result (or it stops throwing
/// [NotFoundException]), for up to [timeout].
///
/// Hosts index new files and folders with some delay. The last result is
/// returned (or the last error thrown) when time runs out.
Future<T> eventually<T>(
  Future<T> Function() action, {
  bool Function(T value)? until,
  Duration timeout = const Duration(seconds: 90),
  Duration interval = const Duration(seconds: 3),
}) async {
  final watch = Stopwatch()..start();
  while (true) {
    try {
      final value = await action();
      if (until == null || until(value) || watch.elapsed >= timeout) {
        return value;
      }
    } on NotFoundException {
      if (watch.elapsed >= timeout) rethrow;
    }
    await Future<void>.delayed(interval);
  }
}

/// Every entry of [folderId] (all pages, at most [maxPages]).
Future<List<CloudEntry>> listAll(
  FolderBrowsing browser,
  FolderId? folderId, {
  int maxPages = 20,
}) async {
  final entries = <CloudEntry>[];
  var page = const PageRequest(perPage: 100);
  for (var i = 0; i < maxPages; i++) {
    final result = await browser.listFolder(folderId, page: page);
    entries.addAll(result.items);
    if (!result.hasMore || result.items.isEmpty) break;
    page = page.next;
  }
  return entries;
}

/// Subfolders of [entries] called [name] (ignoring case).
List<CloudFolder> foldersNamed(Iterable<CloudEntry> entries, String name) => [
  for (final entry in entries)
    if (entry case CloudFolder(name: final folderName)
        when folderName.trim().toLowerCase() == name.toLowerCase())
      entry,
];

/// Logs the response of every upload (credentials removed), so new
/// response shapes can be recorded as fixtures.
final class LoggingExecutor implements UploadExecutor {
  /// Wraps [inner].
  LoggingExecutor(this.inner, this.env);

  /// Executor sending the uploads.
  final UploadExecutor inner;

  /// Removes credentials from the log.
  final LiveEnv env;

  @override
  Future<UploadResponse> execute(
    UploadRequest request,
    UploadSource source, {
    void Function(TransferProgress progress)? onProgress,
    CancellationToken? cancelToken,
  }) async {
    final response = await inner.execute(
      request,
      source,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    final body = response.body.replaceAll(RegExp(r'\s+'), ' ');
    env.log(
      '    upload of ${source.name} to ${request.url.host}: '
      'HTTP ${response.statusCode} '
      '${body.length > 400 ? '${body.substring(0, 400)}...' : body}',
    );
    return response;
  }
}
