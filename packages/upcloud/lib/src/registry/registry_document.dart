import 'dart:convert';

import 'package:upcloud/src/core/http/json_readers.dart';

/// Newest registry format this version of the package understands.
const supportedRegistrySchema = 1;

/// The contents of a `providers.json` registry file.
///
/// ```json
/// {
///   "schemaVersion": 1,
///   "updatedAt": "2026-09-27T00:00:00Z",
///   "providers": [ { "id": "streamhg", "driver": "xvs", ... } ]
/// }
/// ```
///
/// Provider entries are kept as raw JSON so unknown fields and entries for
/// drivers added in newer versions survive a round trip.
final class RegistryDocument {
  /// Creates a document.
  RegistryDocument({
    required this.providers,
    this.schemaVersion = supportedRegistrySchema,
    this.updatedAt,
  });

  /// Parses a registry file. Throws [FormatException] if it is malformed.
  factory RegistryDocument.parse(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw FormatException('Invalid registry JSON: ${e.message}');
    }
    final map = readMap(json);
    if (map == null) {
      throw const FormatException('The registry must be a JSON object');
    }
    return RegistryDocument.fromJson(map);
  }

  /// Reads a registry from decoded JSON.
  factory RegistryDocument.fromJson(Map<String, Object?> json) {
    final providers = json['providers'];
    if (providers is! List) {
      throw const FormatException('The registry has no "providers" list');
    }
    return RegistryDocument(
      schemaVersion: readInt(json['schemaVersion']) ?? 1,
      updatedAt: readDateTime(json['updatedAt']),
      providers: [
        for (final entry in providers)
          if (readMap(entry) case final map?) Map<String, Object?>.of(map),
      ],
    );
  }

  /// Format version. Documents newer than [supportedRegistrySchema] are
  /// rejected by `ProviderRegistry`.
  final int schemaVersion;

  /// When the document was last edited.
  final DateTime? updatedAt;

  /// Raw provider entries (see `ProviderConfig`).
  final List<Map<String, Object?>> providers;

  /// Whether this version of the package can read the document.
  bool get isSupported => schemaVersion <= supportedRegistrySchema;

  /// Entry with [id], or `null`.
  Map<String, Object?>? entry(String id) =>
      providers.where((p) => p['id'] == id).firstOrNull;

  /// JSON representation.
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    if (updatedAt case final date?) 'updatedAt': date.toUtc().toIso8601String(),
    'providers': providers,
  };

  /// Encodes the document, indented for humans when [pretty] is true.
  String encode({bool pretty = true}) => pretty
      ? const JsonEncoder.withIndent('  ').convert(toJson())
      : jsonEncode(toJson());
}

/// Applies [patch] to [base]: keys in [patch] replace those in [base],
/// nested objects are merged recursively and `null` values remove keys.
Map<String, Object?> mergeJson(
  Map<String, Object?> base,
  Map<String, Object?> patch,
) {
  final result = Map<String, Object?>.of(base);
  for (final MapEntry(:key, :value) in patch.entries) {
    final current = result[key];
    if (value == null) {
      result.remove(key);
    } else if (value is Map && current is Map) {
      result[key] = mergeJson(
        current.cast<String, Object?>(),
        value.cast<String, Object?>(),
      );
    } else {
      result[key] = value;
    }
  }
  return result;
}

/// Returns the smallest patch that turns [base] into [target] with
/// [mergeJson]. Keys missing in [target] are set to `null`.
Map<String, Object?> diffJson(
  Map<String, Object?> base,
  Map<String, Object?> target,
) {
  final patch = <String, Object?>{};
  for (final MapEntry(:key, :value) in target.entries) {
    if (value == null) continue;
    final current = base[key];
    if (value is Map && current is Map) {
      final nested = diffJson(
        current.cast<String, Object?>(),
        value.cast<String, Object?>(),
      );
      if (nested.isNotEmpty) patch[key] = nested;
    } else if (!jsonEquals(current, value)) {
      patch[key] = value;
    }
  }
  for (final MapEntry(:key, :value) in base.entries) {
    if (value != null && target[key] == null) patch[key] = null;
  }
  return patch;
}

/// Deep equality for decoded JSON values.
bool jsonEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !jsonEquals(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!jsonEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is num && b is num) return a == b;
  return a == b;
}

/// Returns [json] without `null` values, recursively.
Map<String, Object?> compactJson(Map<String, Object?> json) => {
  for (final MapEntry(:key, :value) in json.entries)
    if (value != null)
      key: value is Map ? compactJson(value.cast<String, Object?>()) : value,
};
