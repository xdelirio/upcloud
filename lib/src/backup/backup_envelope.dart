import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:upcloud/src/backup/argon2id_params.dart';
import 'package:upcloud/src/backup/isolate_web.dart'
    if (dart.library.io) 'package:upcloud/src/backup/isolate_io.dart';
import 'package:upcloud/src/core/errors.dart';

/// Value of the `format` field of backup files.
const backupFormat = 'upcloud-backup';

/// Newest backup format version this version of the package reads; it is
/// also the version it writes.
const supportedBackupVersion = 1;

const _kdfAlgorithm = 'argon2id';
const _cipherAlgorithm = 'aes-256-gcm';
const _keyLength = 32;
const _saltLength = 16;
const _nonceLength = 12;
const _macLength = 16;

/// Key derivations cheaper than this (KiB × passes, e.g. in tests) run in
/// place: starting an isolate would cost more than the derivation.
const _inPlaceCost = 4096;

final _cipher = DartAesGcm.with256bits();

/// What a backup file says about itself, readable without the password
/// (see `UpCloud.inspectBackup`).
final class BackupInfo {
  /// Creates the description of a backup.
  const BackupInfo({
    required this.version,
    required this.createdAt,
    required this.kdf,
  });

  /// Version of the backup format.
  final int version;

  /// When the backup was made, or `null` if the file does not say.
  final DateTime? createdAt;

  /// Cost of the key derivation of this backup.
  final Argon2idParams kdf;

  @override
  String toString() =>
      'BackupInfo(version: $version, createdAt: $createdAt, kdf: $kdf)';
}

/// Encrypts [payload] with [password] and returns the backup file: a JSON
/// envelope describing the format, the key derivation and the cipher, with
/// the encrypted payload in `data`.
///
/// The key is derived with Argon2id ([kdf], random 16 bytes salt) off the
/// main isolate when possible; the payload is encrypted with AES-256-GCM
/// (random 12 bytes nonce), authenticating the rest of the envelope as
/// associated data.
Future<String> sealBackup(
  Map<String, Object?> payload, {
  required String password,
  required Argon2idParams kdf,
  DateTime? createdAt,
  Random? random,
}) async {
  if (!kdf.isValid) throw ArgumentError.value(kdf, 'kdf', 'out of range');
  final rng = random ?? Random.secure();
  final header = _Envelope(
    version: supportedBackupVersion,
    createdAt: _timestamp(createdAt ?? DateTime.now()),
    kdf: kdf,
    salt: _randomBytes(rng, _saltLength),
    nonce: _randomBytes(rng, _nonceLength),
    data: Uint8List(0),
  );
  final key = await _deriveKey(password, header.salt, kdf);
  final box = await _cipher.encrypt(
    utf8.encode(jsonEncode(payload)),
    secretKey: SecretKeyData(key),
    nonce: header.nonce,
    aad: header.aad,
  );
  return header
      .withData(Uint8List.fromList(box.concatenation(nonce: false)))
      .encode();
}

/// Decrypts a backup made by [sealBackup].
///
/// Throws [InvalidBackupException] when [source] is not a backup, is
/// damaged or needs a newer version, and [WrongBackupPasswordException]
/// when [password] is wrong or the file was modified.
Future<(BackupInfo, Map<String, Object?>)> openBackup(
  String source, {
  required String password,
}) async {
  final envelope = _Envelope.parse(source);
  final key = await _deriveKey(password, envelope.salt, envelope.kdf);
  final data = envelope.data;
  final box = SecretBox(
    Uint8List.sublistView(data, 0, data.length - _macLength),
    nonce: envelope.nonce,
    mac: Mac(Uint8List.sublistView(data, data.length - _macLength)),
  );
  final List<int> clearText;
  try {
    clearText = await _cipher.decrypt(
      box,
      secretKey: SecretKeyData(key),
      aad: envelope.aad,
    );
  } on SecretBoxAuthenticationError {
    throw const WrongBackupPasswordException();
  }
  // No cause is attached below: parse errors would carry the decrypted
  // text, which contains secrets.
  final Object? payload;
  try {
    payload = jsonDecode(utf8.decode(clearText));
  } on FormatException {
    throw const InvalidBackupException(
      'The backup content is not valid JSON',
      reason: InvalidBackupReason.corrupted,
    );
  }
  if (payload is! Map<String, Object?>) {
    throw const InvalidBackupException(
      'The backup content is not a JSON object',
      reason: InvalidBackupReason.corrupted,
    );
  }
  return (envelope.info, payload);
}

/// Reads the envelope of a backup without decrypting it.
///
/// Throws [InvalidBackupException] like [openBackup].
BackupInfo inspectBackupEnvelope(String source) => _Envelope.parse(source).info;

/// The visible part of a backup file.
final class _Envelope {
  _Envelope({
    required this.version,
    required this.createdAt,
    required this.kdf,
    required this.salt,
    required this.nonce,
    required this.data,
  });

  factory _Envelope.parse(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException {
      throw const InvalidBackupException(
        'The file is not JSON',
        reason: InvalidBackupReason.notABackup,
      );
    }
    if (json is! Map<String, Object?> || json['format'] != backupFormat) {
      throw const InvalidBackupException(
        'The file is not an upcloud backup',
        reason: InvalidBackupReason.notABackup,
      );
    }
    final version = json['version'];
    if (version is! int || version < 1) {
      throw _corrupted('Invalid version');
    }
    if (version > supportedBackupVersion) {
      throw InvalidBackupException(
        'Backup version $version is newer than $supportedBackupVersion: '
        'update the app to restore it',
        reason: InvalidBackupReason.unsupported,
      );
    }
    if (json['encrypted'] != true) throw _corrupted('Not encrypted');
    final createdAt = json['createdAt'];
    if (createdAt != null && createdAt is! String) {
      throw _corrupted('Invalid createdAt');
    }

    final kdf = json['kdf'];
    if (kdf is! Map<String, Object?>) throw _corrupted('Missing kdf');
    if (kdf['algorithm'] != _kdfAlgorithm) {
      throw const InvalidBackupException(
        'Unsupported key derivation algorithm',
        reason: InvalidBackupReason.unsupported,
      );
    }
    final params = Argon2idParams(
      memoryKiB: _int(kdf['memoryKiB'], 'kdf.memoryKiB'),
      iterations: _int(kdf['iterations'], 'kdf.iterations'),
      parallelism: _int(kdf['parallelism'], 'kdf.parallelism'),
    );
    if (!params.isValid) {
      throw const InvalidBackupException(
        'Key derivation parameters out of the supported range',
        reason: InvalidBackupReason.unsupported,
      );
    }
    final salt = _bytes(kdf['salt'], 'kdf.salt');
    if (salt.length < 8 || salt.length > 64) {
      throw _corrupted('Invalid kdf.salt');
    }

    final cipher = json['cipher'];
    if (cipher is! Map<String, Object?>) throw _corrupted('Missing cipher');
    if (cipher['algorithm'] != _cipherAlgorithm) {
      throw const InvalidBackupException(
        'Unsupported cipher',
        reason: InvalidBackupReason.unsupported,
      );
    }
    final nonce = _bytes(cipher['nonce'], 'cipher.nonce');
    if (nonce.length != _nonceLength) throw _corrupted('Invalid cipher.nonce');
    final data = _bytes(json['data'], 'data');
    if (data.length < _macLength) throw _corrupted('Truncated data');

    return _Envelope(
      version: version,
      createdAt: createdAt as String?,
      kdf: params,
      salt: salt,
      nonce: nonce,
      data: data,
    );
  }

  final int version;
  final String? createdAt;
  final Argon2idParams kdf;
  final Uint8List salt;
  final Uint8List nonce;

  /// Cipher text followed by the 16 bytes GCM tag.
  final Uint8List data;

  BackupInfo get info => BackupInfo(
    version: version,
    createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
    kdf: kdf,
  );

  /// Every field but `data`, in a fixed order.
  Map<String, Object?> get _header => {
    'format': backupFormat,
    'version': version,
    'createdAt': createdAt,
    'encrypted': true,
    'kdf': {
      'algorithm': _kdfAlgorithm,
      'memoryKiB': kdf.memoryKiB,
      'iterations': kdf.iterations,
      'parallelism': kdf.parallelism,
      'salt': base64Encode(salt),
    },
    'cipher': {'algorithm': _cipherAlgorithm, 'nonce': base64Encode(nonce)},
  };

  /// Associated data of the cipher: the header encoded as compact JSON, so
  /// changing the format, version, date or key derivation parameters makes
  /// decryption fail.
  Uint8List get aad => utf8.encode(jsonEncode(_header));

  _Envelope withData(Uint8List data) => _Envelope(
    version: version,
    createdAt: createdAt,
    kdf: kdf,
    salt: salt,
    nonce: nonce,
    data: data,
  );

  String encode() =>
      const JsonEncoder.withIndent('  ')
          .convert({..._header, 'data': base64Encode(data)});
}

Future<List<int>> _deriveKey(
  String password,
  List<int> salt,
  Argon2idParams params,
) {
  final bytes = utf8.encode(password);
  if (canRunIsolated && params.memoryKiB * params.iterations > _inPlaceCost) {
    return runIsolated(() => _argon2id(bytes, salt, params, isolated: true));
  }
  return _argon2id(bytes, salt, params, isolated: false);
}

Future<List<int>> _argon2id(
  List<int> password,
  List<int> salt,
  Argon2idParams params, {
  required bool isolated,
}) async {
  final algorithm = DartArgon2id(
    memory: params.memoryKiB,
    iterations: params.iterations,
    parallelism: params.parallelism,
    hashLength: _keyLength,
    // No helper isolates: the derivation already runs in its own isolate,
    // or it is tiny, or there are none (web).
    maxIsolates: 0,
    // A worker isolate has nothing else to do; in place, pause regularly
    // so the event loop keeps running.
    blocksPerProcessingChunk: isolated ? 0 : null,
  );
  final key = await algorithm.deriveKey(
    secretKey: SecretKeyData(password),
    nonce: salt,
  );
  return await key.extractBytes();
}

/// [time] in UTC, to the second.
String _timestamp(DateTime time) {
  final utc = time.toUtc();
  return DateTime.utc(
    utc.year,
    utc.month,
    utc.day,
    utc.hour,
    utc.minute,
    utc.second,
  ).toIso8601String();
}

Uint8List _randomBytes(Random random, int length) =>
    Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));

int _int(Object? value, String field) =>
    value is int ? value : throw _corrupted('Invalid $field');

Uint8List _bytes(Object? value, String field) {
  if (value is String) {
    try {
      return base64.decode(value);
    } on FormatException {
      // Reported below.
    }
  }
  throw _corrupted('Invalid $field');
}

InvalidBackupException _corrupted(String message) =>
    InvalidBackupException(message, reason: InvalidBackupReason.corrupted);
