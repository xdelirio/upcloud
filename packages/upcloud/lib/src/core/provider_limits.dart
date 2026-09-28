import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/data_size.dart';

part 'provider_limits.freezed.dart';

/// Restrictions enforced by a provider.
///
/// Most providers do not expose their limits through the API, so they are
/// declared per provider and can be overridden by the app (for example when
/// the account is premium).
@freezed
abstract class ProviderLimits with _$ProviderLimits {
  /// Creates provider limits. `null` means "no known limit".
  const factory ProviderLimits({
    /// Largest file accepted by a single upload.
    DataSize? maxFileSize,

    /// Accepted extensions (lowercase, without dot). `null` accepts all.
    Set<String>? allowedExtensions,

    /// Uploads that may run at the same time for one account.
    @Default(2) int maxConcurrentUploads,

    /// Minimum time between two API requests.
    Duration? minRequestInterval,
  }) = _ProviderLimits;

  const ProviderLimits._();

  /// No restrictions.
  static const none = ProviderLimits();

  /// Common video extensions, for video hosting providers.
  static const videoExtensions = <String>{
    '3gp', 'asf', 'avi', 'flv', 'm2ts', 'm4v', 'mkv', 'mov', 'mp4', 'mpeg', //
    'mpg', 'mts', 'ogv', 'ts', 'vob', 'webm', 'wmv',
  };

  /// Returns why a file with [extension] and [size] cannot be uploaded, or
  /// `null` if it is accepted.
  ///
  /// [storageLeft] is the free space of the account, when known.
  UploadRejection? check({
    required String extension,
    DataSize? size,
    DataSize? storageLeft,
  }) {
    final allowed = allowedExtensions;
    if (allowed != null && !allowed.contains(extension.toLowerCase())) {
      return ExtensionNotAllowed(extension: extension, allowed: allowed);
    }
    if (size != null) {
      final max = maxFileSize;
      if (max != null && size > max) {
        return FileTooLarge(size: size, maxSize: max);
      }
      if (storageLeft != null && size > storageLeft) {
        return NotEnoughStorage(size: size, available: storageLeft);
      }
    }
    return null;
  }
}
