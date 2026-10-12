import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/transfer/folder_path_resolver.dart';

part 'upload_settings.freezed.dart';
part 'upload_settings.g.dart';

/// Visibility of uploaded files: the default of the upload settings, or
/// the one given to `UpCloud.upload` and `UpCloud.uploadBatch`.
///
/// `UploadOptions.isPublic`, when set, always wins.
enum UploadVisibility {
  /// Keep the default of each provider.
  providerDefault,

  /// Upload files as public.
  public,

  /// Upload files as private.
  private;

  /// The `UploadOptions.isPublic` value of this visibility.
  bool? get isPublic => switch (this) {
    providerDefault => null,
    public => true,
    private => false,
  };
}

/// User preferences for uploads, applied by `TransferManager` and saved by
/// `UpCloud.updateSettings`.
///
/// Out of range values are clamped by [normalized].
@freezed
abstract class UploadSettings with _$UploadSettings {
  /// Creates upload settings.
  const factory UploadSettings({
    /// Uploads running at the same time across all accounts, between
    /// [minConcurrentUploads] and [maxConcurrentUploadsLimit]. Each account
    /// is also limited by its provider (`ProviderLimits`).
    @Default(3) int maxConcurrentUploads,

    /// Automatic retries after a transient failure (network errors, rate
    /// limits, server errors), between 0 and [maxRetries].
    @Default(2) int retries,

    /// Whether to check the free storage of the account before each upload.
    ///
    /// Costs one extra request per upload on providers that report it.
    @Default(true) bool checkStorage,

    /// Seconds after which completed uploads are removed from the queue;
    /// `null` keeps them. Failed and cancelled uploads are always kept.
    int? autoClearAfterSeconds,

    /// Folder path (by name, e.g. `Movies/2026`) used by batch uploads when
    /// no destination is given; `null` is the root folder.
    String? defaultFolderPath,

    /// Visibility of uploads that set neither `UploadOptions.isPublic` nor
    /// an explicit visibility.
    @JsonKey(unknownEnumValue: UploadVisibility.providerDefault)
    @Default(UploadVisibility.providerDefault)
    UploadVisibility defaultVisibility,
  }) = _UploadSettings;

  const UploadSettings._();

  /// Restores settings saved with [toJson]. Missing keys take their
  /// default value.
  factory UploadSettings.fromJson(Map<String, dynamic> json) =>
      _$UploadSettingsFromJson(json);

  /// Lowest accepted [maxConcurrentUploads].
  static const minConcurrentUploads = 1;

  /// Highest accepted [maxConcurrentUploads].
  static const maxConcurrentUploadsLimit = 10;

  /// Highest accepted [retries].
  static const maxRetries = 10;

  /// [autoClearAfterSeconds] as a duration, or `null`.
  Duration? get autoClearAfter {
    final seconds = autoClearAfterSeconds;
    return seconds == null ? null : Duration(seconds: seconds);
  }

  /// A copy with every value in its valid range and a normalized
  /// [defaultFolderPath] (an empty path becomes `null`).
  UploadSettings normalized() {
    final path = defaultFolderPath == null
        ? ''
        : normalizeFolderPath(defaultFolderPath!);
    final autoClear = autoClearAfterSeconds;
    return copyWith(
      maxConcurrentUploads: maxConcurrentUploads.clamp(
        minConcurrentUploads,
        maxConcurrentUploadsLimit,
      ),
      retries: retries.clamp(0, maxRetries),
      autoClearAfterSeconds: autoClear == null ? null : math.max(0, autoClear),
      defaultFolderPath: path.isEmpty ? null : path,
    );
  }
}
