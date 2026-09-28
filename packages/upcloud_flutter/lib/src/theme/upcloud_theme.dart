import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:upcloud_flutter/src/utils/file_kind.dart';

/// Visual customization of the upcloud_flutter widgets.
///
/// Add it to `ThemeData.extensions` to override the defaults, which are
/// derived from the ambient [ColorScheme]:
///
/// ```dart
/// ThemeData(
///   colorScheme: scheme,
///   extensions: [
///     UpCloudTheme.fromColorScheme(scheme).copyWith(
///       folderColor: Colors.amber,
///     ),
///   ],
/// );
/// ```
@immutable
class UpCloudTheme extends ThemeExtension<UpCloudTheme> {
  /// Creates a theme with explicit values.
  const UpCloudTheme({
    required this.folderColor,
    required this.fileColor,
    required this.videoColor,
    required this.imageColor,
    required this.audioColor,
    required this.archiveColor,
    required this.documentColor,
    required this.codeColor,
    required this.successColor,
    required this.warningColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.gridMaxCrossAxisExtent = 180,
    this.thumbnailSize = 40,
    this.progressHeight = 4,
  });

  /// Default values that harmonize with [scheme].
  factory UpCloudTheme.fromColorScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return UpCloudTheme(
      folderColor: scheme.primary,
      fileColor: scheme.onSurfaceVariant,
      videoColor: dark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
      imageColor: dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      audioColor: dark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
      archiveColor: dark ? const Color(0xFFFFCC80) : const Color(0xFFE65100),
      documentColor: dark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0),
      codeColor: dark ? const Color(0xFF80CBC4) : const Color(0xFF00695C),
      successColor: dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      warningColor: dark ? const Color(0xFFFFB74D) : const Color(0xFFB45F06),
    );
  }

  /// The theme of [context]: the registered extension or the defaults for
  /// its color scheme.
  static UpCloudTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<UpCloudTheme>() ?? _defaults(theme.colorScheme);
  }

  /// Color of folder icons.
  final Color folderColor;

  /// Color of generic file icons.
  final Color fileColor;

  /// Color of video file icons.
  final Color videoColor;

  /// Color of image file icons.
  final Color imageColor;

  /// Color of audio file icons.
  final Color audioColor;

  /// Color of archive file icons.
  final Color archiveColor;

  /// Color of document file icons.
  final Color documentColor;

  /// Color of source code file icons.
  final Color codeColor;

  /// Color used for completed transfers and healthy accounts.
  final Color successColor;

  /// Color of warnings, e.g. uploads skipped by `UploadComposer`.
  final Color warningColor;

  /// Corner radius of grid tiles, thumbnails and cards.
  final BorderRadius borderRadius;

  /// Maximum width of a grid tile in `CloudBrowser`.
  final double gridMaxCrossAxisExtent;

  /// Size of icons and thumbnails in list tiles.
  final double thumbnailSize;

  /// Height of transfer progress bars.
  final double progressHeight;

  /// Icon color for [kind].
  Color colorFor(CloudFileKind kind) => switch (kind) {
    CloudFileKind.folder => folderColor,
    CloudFileKind.video => videoColor,
    CloudFileKind.image => imageColor,
    CloudFileKind.audio => audioColor,
    CloudFileKind.archive => archiveColor,
    CloudFileKind.document => documentColor,
    CloudFileKind.code => codeColor,
    CloudFileKind.other => fileColor,
  };

  @override
  UpCloudTheme copyWith({
    Color? folderColor,
    Color? fileColor,
    Color? videoColor,
    Color? imageColor,
    Color? audioColor,
    Color? archiveColor,
    Color? documentColor,
    Color? codeColor,
    Color? successColor,
    Color? warningColor,
    BorderRadius? borderRadius,
    double? gridMaxCrossAxisExtent,
    double? thumbnailSize,
    double? progressHeight,
  }) => UpCloudTheme(
    folderColor: folderColor ?? this.folderColor,
    fileColor: fileColor ?? this.fileColor,
    videoColor: videoColor ?? this.videoColor,
    imageColor: imageColor ?? this.imageColor,
    audioColor: audioColor ?? this.audioColor,
    archiveColor: archiveColor ?? this.archiveColor,
    documentColor: documentColor ?? this.documentColor,
    codeColor: codeColor ?? this.codeColor,
    successColor: successColor ?? this.successColor,
    warningColor: warningColor ?? this.warningColor,
    borderRadius: borderRadius ?? this.borderRadius,
    gridMaxCrossAxisExtent:
        gridMaxCrossAxisExtent ?? this.gridMaxCrossAxisExtent,
    thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    progressHeight: progressHeight ?? this.progressHeight,
  );

  @override
  UpCloudTheme lerp(covariant UpCloudTheme? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return UpCloudTheme(
      folderColor: c(folderColor, other.folderColor),
      fileColor: c(fileColor, other.fileColor),
      videoColor: c(videoColor, other.videoColor),
      imageColor: c(imageColor, other.imageColor),
      audioColor: c(audioColor, other.audioColor),
      archiveColor: c(archiveColor, other.archiveColor),
      documentColor: c(documentColor, other.documentColor),
      codeColor: c(codeColor, other.codeColor),
      successColor: c(successColor, other.successColor),
      warningColor: c(warningColor, other.warningColor),
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      gridMaxCrossAxisExtent: d(
        gridMaxCrossAxisExtent,
        other.gridMaxCrossAxisExtent,
      ),
      thumbnailSize: d(thumbnailSize, other.thumbnailSize),
      progressHeight: d(progressHeight, other.progressHeight),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UpCloudTheme &&
      other.folderColor == folderColor &&
      other.fileColor == fileColor &&
      other.videoColor == videoColor &&
      other.imageColor == imageColor &&
      other.audioColor == audioColor &&
      other.archiveColor == archiveColor &&
      other.documentColor == documentColor &&
      other.codeColor == codeColor &&
      other.successColor == successColor &&
      other.warningColor == warningColor &&
      other.borderRadius == borderRadius &&
      other.gridMaxCrossAxisExtent == gridMaxCrossAxisExtent &&
      other.thumbnailSize == thumbnailSize &&
      other.progressHeight == progressHeight;

  @override
  int get hashCode => Object.hash(
    folderColor,
    fileColor,
    videoColor,
    imageColor,
    audioColor,
    archiveColor,
    documentColor,
    codeColor,
    successColor,
    warningColor,
    borderRadius,
    gridMaxCrossAxisExtent,
    thumbnailSize,
    progressHeight,
  );
}

UpCloudTheme _defaults(ColorScheme scheme) =>
    UpCloudTheme.fromColorScheme(scheme);
