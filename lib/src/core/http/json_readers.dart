import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

// Lenient readers for APIs that mix types ("1" vs 1, "" vs null, ...).
//
// Use them directly in hand written mappers or through the converters
// below in json_serializable DTOs.

/// Reads an int from an int, double, bool or numeric string.
int? readInt(Object? value) => switch (value) {
  final int v => v,
  final double v => v.round(),
  final bool v => v ? 1 : 0,
  final String v =>
    int.tryParse(v.trim()) ?? double.tryParse(v.trim())?.round(),
  _ => null,
};

/// Reads a double from a number or numeric string.
double? readDouble(Object? value) => switch (value) {
  final num v => v.toDouble(),
  final String v => double.tryParse(v.trim()),
  _ => null,
};

/// Reads a bool from a bool, `0/1`, `"yes"/"no"`, `"true"/"false"`...
bool? readBool(Object? value) => switch (value) {
  final bool v => v,
  final num v => v != 0,
  final String v => switch (v.trim().toLowerCase()) {
    '1' || 'true' || 'yes' || 'y' || 'on' => true,
    '0' || 'false' || 'no' || 'n' || 'off' || '' => false,
    _ => null,
  },
  _ => null,
};

/// Reads a non empty string from a string or number.
String? readString(Object? value) => switch (value) {
  final String v when v.isNotEmpty => v,
  final num v => v.toString(),
  _ => null,
};

/// Reads an absolute URI. Protocol relative URIs (`//host/x`) get `https`.
Uri? readUri(Object? value) {
  final text = readString(value)?.trim();
  if (text == null || text.isEmpty) return null;
  final uri = Uri.tryParse(text.startsWith('//') ? 'https:$text' : text);
  return uri != null && uri.hasScheme ? uri : null;
}

/// Reads a date from ISO 8601, `yyyy-MM-dd HH:mm:ss` or a unix timestamp
/// (seconds or milliseconds). Dates without offset are treated as UTC.
DateTime? readDateTime(Object? value) {
  if (value is DateTime) return value;
  final asInt = value is num ? value.toInt() : null;
  final text = readString(value)?.trim();
  final epoch = asInt ?? (text == null ? null : int.tryParse(text));
  if (epoch != null) {
    if (epoch <= 0) return null;
    final ms = epoch < 100000000000 ? epoch * 1000 : epoch;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }
  if (text == null || text.startsWith('0000')) return null;
  final normalized = text.contains('T') ? text : text.replaceFirst(' ', 'T');
  final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(normalized);
  return DateTime.tryParse(hasOffset ? normalized : '${normalized}Z');
}

/// Reads a duration expressed in seconds, or as `HH:MM:SS` / `MM:SS`.
Duration? readSecondsDuration(Object? value) {
  final text = readString(value)?.trim();
  if (text != null && text.contains(':')) {
    final parts = text.split(':').map(int.tryParse).toList();
    if (parts.any((p) => p == null)) return null;
    var seconds = 0;
    for (final part in parts) {
      seconds = seconds * 60 + part!;
    }
    return Duration(seconds: seconds);
  }
  final seconds = readDouble(value);
  if (seconds == null || seconds < 0) return null;
  return Duration(milliseconds: (seconds * 1000).round());
}

/// Reads a list, returning an empty list for anything else.
List<Object?> readList(Object? value) =>
    value is List ? value.cast<Object?>() : const [];

/// Reads a JSON object, returning `null` for anything else.
Map<String, Object?>? readMap(Object? value) =>
    value is Map ? value.cast<String, Object?>() : null;

/// Reads a JSON object already decoded or sent as text (some APIs answer
/// JSON with a `text/html` or `text/xml` content type), returning `null`
/// for anything else.
Map<String, Object?>? readJsonObject(Object? data) {
  if (data is! String) return readMap(data);
  final text = data.trim();
  if (!text.startsWith('{')) return null;
  try {
    return readMap(jsonDecode(text));
  } on FormatException {
    return null;
  }
}

/// Reads a percentage (`55`, `"55"`, `"55%"`) as a fraction between 0 and 1.
double? readPercent(Object? value) {
  final percent = readDouble(
    value is String ? value.replaceAll('%', '') : value,
  );
  return percent == null ? null : (percent / 100).clamp(0, 1).toDouble();
}

/// The entries of [json] whose key is not in [known], without `null`
/// values: what a mapper keeps in the `extra` of a model.
Map<String, Object?> readExtra(Map<String, Object?> json, Set<String> known) =>
    {
      for (final MapEntry(:key, :value) in json.entries)
        if (value != null && !known.contains(key)) key: value,
    };

/// json_serializable converter using [readInt].
final class LenientIntConverter implements JsonConverter<int?, Object?> {
  /// Creates the converter.
  const LenientIntConverter();

  @override
  int? fromJson(Object? json) => readInt(json);

  @override
  Object? toJson(int? object) => object;
}

/// json_serializable converter using [readDouble].
final class LenientDoubleConverter implements JsonConverter<double?, Object?> {
  /// Creates the converter.
  const LenientDoubleConverter();

  @override
  double? fromJson(Object? json) => readDouble(json);

  @override
  Object? toJson(double? object) => object;
}

/// json_serializable converter using [readBool].
final class LenientBoolConverter implements JsonConverter<bool?, Object?> {
  /// Creates the converter.
  const LenientBoolConverter();

  @override
  bool? fromJson(Object? json) => readBool(json);

  @override
  Object? toJson(bool? object) => object;
}

/// json_serializable converter using [readString].
final class LenientStringConverter implements JsonConverter<String?, Object?> {
  /// Creates the converter.
  const LenientStringConverter();

  @override
  String? fromJson(Object? json) => readString(json);

  @override
  Object? toJson(String? object) => object;
}

/// json_serializable converter using [readDateTime].
final class LenientDateTimeConverter
    implements JsonConverter<DateTime?, Object?> {
  /// Creates the converter.
  const LenientDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) => readDateTime(json);

  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}

/// json_serializable converter using [readUri].
final class LenientUriConverter implements JsonConverter<Uri?, Object?> {
  /// Creates the converter.
  const LenientUriConverter();

  @override
  Uri? fromJson(Object? json) => readUri(json);

  @override
  Object? toJson(Uri? object) => object?.toString();
}
