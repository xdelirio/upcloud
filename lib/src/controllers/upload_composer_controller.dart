import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upcloud/upcloud.dart';

/// An upload of an [UploadComposerController] that breaks the limits of
/// the provider of [account], so it is skipped.
@immutable
class SkippedUpload {
  /// Creates a skipped upload.
  const SkippedUpload({
    required this.file,
    required this.account,
    required this.reason,
  });

  /// File that cannot be uploaded to [account].
  final UploadSource file;

  /// Account whose provider rejects [file].
  final CloudAccount account;

  /// Why the provider rejects the file.
  final UploadRejection reason;
}

/// State and actions of an `UploadComposer`: files, destination accounts,
/// folder path and visibility of a batch upload.
///
/// ```dart
/// final composer = UploadComposerController(upcloud)
///   ..addFiles([UploadSource.file(path)])
///   ..selectAll()
///   ..folderPath = 'Movies/2026';
/// if (composer.canSubmit) {
///   final batch = composer.submit();
/// }
/// ```
///
/// Only accounts whose provider supports uploads are offered. The account
/// selection is remembered in memory for the [UpCloud] instance, so a new
/// controller starts with the last selection.
class UploadComposerController extends ChangeNotifier {
  /// Creates a controller for [upcloud].
  ///
  /// [accountIds] defaults to the last selection (or the only account that
  /// can receive uploads). The folder path and the
  /// visibility start with the defaults of the upload settings, and follow
  /// them until they are changed.
  UploadComposerController(
    this.upcloud, {
    Iterable<UploadSource> files = const [],
    Iterable<String>? accountIds,
  }) : _folderPath = upcloud.settings.defaultFolderPath ?? '',
       _visibility = upcloud.settings.defaultVisibility {
    _accounts = _uploadAccounts();
    _selected = _validIds(
      accountIds ??
          _lastSelection[upcloud] ??
          // A single account is the obvious destination.
          [if (_accounts.length == 1) _accounts.single.id],
    );
    _accountSubscription = upcloud.accountChanges.listen(_onAccounts);
    _providerSubscription = upcloud.providerChanges.listen(
      (_) => _onAccounts(upcloud.accounts),
    );
    _settingsSubscription = upcloud.settingsChanges.listen(_onSettings);
    addFiles(files);
  }

  /// Last account selection of each [UpCloud] instance (memory only).
  static final _lastSelection = Expando<Set<String>>('upcloud.composer');

  /// Instance the uploads are sent to.
  final UpCloud upcloud;

  late final StreamSubscription<List<CloudAccount>> _accountSubscription;
  late final StreamSubscription<List<ProviderDefinition>> _providerSubscription;
  late final StreamSubscription<UploadSettings> _settingsSubscription;
  final _files = <UploadSource>[];
  final _sizes = Map<UploadSource, int?>.identity();
  late List<CloudAccount> _accounts;
  late Set<String> _selected;
  String _folderPath;
  UploadVisibility _visibility;
  var _folderEdited = false;
  var _visibilityEdited = false;
  var _selectionEdited = false;
  List<SkippedUpload>? _skipped;
  var _disposed = false;

  /// Files to upload, in the order they were added.
  List<UploadSource> get files => List.unmodifiable(_files);

  /// Size of [file] in bytes, `null` while unknown.
  int? sizeOf(UploadSource file) => _sizes[file];

  /// Size of the known files in bytes.
  int get totalBytes => _files.fold(0, (sum, f) => sum + (_sizes[f] ?? 0));

  /// Accounts that can receive uploads, in the order of `upcloud.accounts`.
  List<CloudAccount> get accounts => List.unmodifiable(_accounts);

  /// Ids of the selected accounts.
  Set<String> get selectedAccountIds => Set.unmodifiable(_selected);

  /// Selected accounts, in the order of [accounts].
  List<CloudAccount> get selectedAccounts => [
    for (final account in _accounts)
      if (_selected.contains(account.id)) account,
  ];

  /// Destination folder path in every account (e.g. `Movies/2026`); empty
  /// for the root folder.
  String get folderPath => _folderPath;

  set folderPath(String value) {
    _folderEdited = true;
    if (value == _folderPath) return;
    _folderPath = value;
    _notify(limitsChanged: false);
  }

  /// Visibility of the uploaded files.
  UploadVisibility get visibility => _visibility;

  set visibility(UploadVisibility value) {
    _visibilityEdited = true;
    if (value == _visibility) return;
    _visibility = value;
    _notify(limitsChanged: false);
  }

  /// Uploads that break the limits of a provider (file too large, file
  /// type not allowed), in file then account order. They are skipped by
  /// [submit].
  ///
  /// Sizes are checked once they are known.
  List<SkippedUpload> get skipped => _skipped ??= [
    for (final file in _files)
      for (final account in selectedAccounts)
        if (_check(file, account) case final reason?)
          SkippedUpload(file: file, account: account, reason: reason),
  ];

  /// Number of uploads [submit] starts.
  int get uploadCount => _files.length * _selected.length - skipped.length;

  /// Whether there are files, selected accounts and uploads to start.
  bool get canSubmit => uploadCount > 0;

  /// Adds [files], ignoring files already added (same path or object).
  void addFiles(Iterable<UploadSource> files) {
    var added = false;
    for (final file in files) {
      if (_contains(file)) continue;
      _files.add(file);
      added = true;
      _sizes[file] = switch (file) {
        FileUploadSource(:final length) => length,
        BytesUploadSource(:final bytes) => bytes.length,
        StreamUploadSource(:final length) => length,
      };
      if (_sizes[file] == null) unawaited(_resolveSize(file));
    }
    if (added) _notify();
  }

  /// Removes [file].
  void removeFile(UploadSource file) {
    if (_files.remove(file)) {
      _sizes.remove(file);
      _notify();
    }
  }

  /// Removes every file.
  void clearFiles() {
    if (_files.isEmpty) return;
    _files.clear();
    _sizes.clear();
    _notify();
  }

  /// Selects or deselects the account [id].
  void toggleAccount(String id, {bool? selected}) {
    if (!_accounts.any((a) => a.id == id)) return;
    final select = selected ?? !_selected.contains(id);
    final changed = select ? _selected.add(id) : _selected.remove(id);
    if (changed) _onSelectionChanged();
  }

  /// Selects every account of [accounts].
  void selectAll() {
    final all = {for (final account in _accounts) account.id};
    if (all.length == _selected.length) return;
    _selected = all;
    _onSelectionChanged();
  }

  /// Deselects every account.
  void selectNone() {
    if (_selected.isEmpty) return;
    _selected = {};
    _onSelectionChanged();
  }

  /// Starts the uploads with `UpCloud.uploadBatch` and clears the files.
  ///
  /// Every file goes to every selected account into [folderPath] with
  /// [visibility], except the [skipped] combinations, which are never
  /// queued. Throws a [StateError] when [canSubmit] is false.
  UploadBatch submit() {
    if (!canSubmit) throw StateError('Nothing to upload');
    final skippedPairs = {for (final s in skipped) (s.file, s.account.id)};
    final batch = upcloud.uploadBatch(
      files: [..._files],
      accountIds: [for (final account in selectedAccounts) account.id],
      folderPath: normalizeFolderPath(_folderPath),
      visibility: _visibility,
      skip: (file, accountId) => skippedPairs.contains((file, accountId)),
    );
    _files.clear();
    _sizes.clear();
    _notify();
    return batch;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_accountSubscription.cancel());
    unawaited(_providerSubscription.cancel());
    unawaited(_settingsSubscription.cancel());
    super.dispose();
  }

  bool _contains(UploadSource file) => _files.any(
    (f) =>
        identical(f, file) ||
        (f is FileUploadSource &&
            file is FileUploadSource &&
            f.path == file.path &&
            f.name == file.name),
  );

  Future<void> _resolveSize(UploadSource file) async {
    int? size;
    try {
      size = await file.resolveLength();
    } on Object {
      size = null;
    }
    if (_disposed || !_files.any((f) => identical(f, file))) return;
    _sizes[file] = size;
    _notify();
  }

  UploadRejection? _check(UploadSource file, CloudAccount account) {
    final size = _sizes[file];
    return _limitsOf(account).check(
      extension: file.extension,
      size: size == null ? null : DataSize(size),
    );
  }

  ProviderLimits _limitsOf(CloudAccount account) {
    try {
      return upcloud.connect(account.id).limits;
    } on Object {
      return upcloud.provider(account.providerId)?.defaultLimits ??
          ProviderLimits.none;
    }
  }

  List<CloudAccount> _uploadAccounts() => [
    for (final account in upcloud.accounts)
      if (upcloud
              .provider(account.providerId)
              ?.capabilities
              .contains(Capability.upload) ??
          false)
        account,
  ];

  Set<String> _validIds(Iterable<String> ids) => {
    for (final id in ids)
      if (_accounts.any((a) => a.id == id)) id,
  };

  void _onAccounts(List<CloudAccount> _) {
    if (_disposed) return;
    _accounts = _uploadAccounts();
    _selected = _validIds(_selected);
    if (!_selectionEdited && _selected.isEmpty && _accounts.length == 1) {
      _selected = {_accounts.single.id};
    }
    _notify();
  }

  void _onSettings(UploadSettings settings) {
    if (_disposed) return;
    if (!_folderEdited) _folderPath = settings.defaultFolderPath ?? '';
    if (!_visibilityEdited) _visibility = settings.defaultVisibility;
    _notify();
  }

  void _onSelectionChanged() {
    _selectionEdited = true;
    _lastSelection[upcloud] = {..._selected};
    _notify();
  }

  /// Notifies listeners. [skipped] is computed again unless the change
  /// cannot affect it ([limitsChanged] is false).
  void _notify({bool limitsChanged = true}) {
    if (_disposed) return;
    if (limitsChanged) _skipped = null;
    notifyListeners();
  }
}
