import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/registry/config_problem.dart';

/// Base class of every error thrown by upcloud.
///
/// It is sealed, so callers can exhaustively handle every case:
///
/// ```dart
/// try {
///   await provider.accountInfo();
/// } on UpCloudException catch (e) {
///   final text = switch (e) {
///     AuthenticationException() => 'Invalid API key',
///     RateLimitedException(:final retryAfter) => 'Retry in $retryAfter',
///     _ => e.message,
///   };
/// }
/// ```
sealed class UpCloudException implements Exception {
  const UpCloudException(this.message, {this.cause, this.stackTrace});

  /// Human readable description (usually the provider's message).
  final String message;

  /// Underlying error, if any.
  final Object? cause;

  /// Stack trace of [cause], if any.
  final StackTrace? stackTrace;

  @override
  // Only used for debugging output.
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType: $message';
}

/// The credentials are missing, invalid or expired.
final class AuthenticationException extends UpCloudException {
  /// Creates an authentication error.
  const AuthenticationException(super.message, {super.cause, super.stackTrace});
}

/// The requested file or folder does not exist.
final class NotFoundException extends UpCloudException {
  /// Creates a not found error.
  const NotFoundException(super.message, {super.cause, super.stackTrace});
}

/// The account ran out of storage, bandwidth or request quota.
final class QuotaExceededException extends UpCloudException {
  /// Creates a quota error.
  const QuotaExceededException(super.message, {super.cause, super.stackTrace});
}

/// Too many requests; wait [retryAfter] before trying again.
final class RateLimitedException extends UpCloudException {
  /// Creates a rate limit error.
  const RateLimitedException(
    super.message, {
    this.retryAfter,
    super.cause,
    super.stackTrace,
  });

  /// Suggested wait time, if the provider reported one.
  final Duration? retryAfter;
}

/// An upload was rejected before being sent because it breaks a provider
/// limit.
final class UploadRejectedException extends UpCloudException {
  /// Creates an upload rejection.
  const UploadRejectedException(super.message, {required this.reason});

  /// Why the upload was rejected.
  final UploadRejection reason;
}

/// Why an upload was rejected. See [UploadRejectedException].
sealed class UploadRejection {
  const UploadRejection();
}

/// The file is larger than the provider allows.
final class FileTooLarge extends UploadRejection {
  /// Creates the rejection.
  const FileTooLarge({required this.size, required this.maxSize});

  /// Size of the file.
  final DataSize size;

  /// Maximum size allowed by the provider.
  final DataSize maxSize;
}

/// The file type is not accepted by the provider.
final class ExtensionNotAllowed extends UploadRejection {
  /// Creates the rejection.
  const ExtensionNotAllowed({required this.extension, required this.allowed});

  /// Extension of the file (lowercase, without dot).
  final String extension;

  /// Extensions accepted by the provider.
  final Set<String> allowed;
}

/// The account does not have enough free storage.
final class NotEnoughStorage extends UploadRejection {
  /// Creates the rejection.
  const NotEnoughStorage({required this.size, required this.available});

  /// Size of the file.
  final DataSize size;

  /// Free storage in the account.
  final DataSize available;
}

/// A provider config is not valid (see `ProviderRegistry.save`).
final class InvalidProviderConfigException extends UpCloudException {
  /// Creates the exception for provider [providerId].
  InvalidProviderConfigException(this.providerId, this.problems)
    : super(
        'Invalid provider "$providerId": '
        '${problems.map((p) => p.message).join('; ')}',
      );

  /// Id of the invalid config.
  final String providerId;

  /// What is wrong, never empty.
  final List<ConfigProblem> problems;
}

/// Why a backup file cannot be read. See [InvalidBackupException].
enum InvalidBackupReason {
  /// The file is not a backup made by `UpCloud.exportBackup`.
  notABackup,

  /// The file is a backup, but it is damaged or incomplete.
  corrupted,

  /// The backup was made by a newer version of the package (or uses an
  /// algorithm this version does not know): update the app to restore it.
  unsupported,
}

/// A backup file cannot be read (see `UpCloud.importBackup`).
final class InvalidBackupException extends UpCloudException {
  /// Creates the exception.
  const InvalidBackupException(super.message, {required this.reason});

  /// Why the file cannot be read.
  final InvalidBackupReason reason;
}

/// The password of a backup is wrong, or the backup was modified after it
/// was made: authenticated encryption cannot tell the two apart.
final class WrongBackupPasswordException extends UpCloudException {
  /// Creates the exception.
  const WrongBackupPasswordException([
    super.message = 'Wrong password, or the backup was modified',
  ]);
}

/// The password chosen for a new backup is too short (see
/// `UpCloud.exportBackup`).
final class WeakBackupPasswordException extends UpCloudException {
  /// Creates the exception for passwords shorter than [minLength].
  const WeakBackupPasswordException(this.minLength)
    : super('The backup password needs at least $minLength characters');

  /// Minimum number of characters of a backup password.
  final int minLength;
}

/// Connection problems: timeouts, DNS failures, TLS errors...
final class NetworkException extends UpCloudException {
  /// Creates a network error.
  const NetworkException(super.message, {super.cause, super.stackTrace});
}

/// The operation was cancelled with a `CancellationToken`.
final class CancelledException extends UpCloudException {
  /// Creates a cancellation error.
  const CancelledException([super.message = 'Operation cancelled']);
}

/// The provider does not support the requested operation.
final class UnsupportedOperationException extends UpCloudException {
  /// Creates an unsupported operation error.
  const UnsupportedOperationException(super.message);
}

/// Any other error reported by the provider.
final class ProviderException extends UpCloudException {
  /// Creates a provider error.
  const ProviderException(
    super.message, {
    this.statusCode,
    this.response,
    super.cause,
    super.stackTrace,
  });

  /// Status code reported by the provider (HTTP or API level).
  final int? statusCode;

  /// Raw response body, useful for debugging.
  final Object? response;
}
