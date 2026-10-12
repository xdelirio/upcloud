import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:upcloud/upcloud.dart';

/// A round avatar with the provider icon, or its initial.
class ProviderAvatar extends StatelessWidget {
  /// Creates an avatar for [info].
  const ProviderAvatar({required this.info, this.radius = 22, super.key});

  /// The provider to represent.
  final ProviderInfo info;

  /// Radius of the avatar.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = info.name.trim().isEmpty
        ? '?'
        : info.name.trim().characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(initial, style: TextStyle(fontSize: radius * 0.8)),
    );
    final iconUrl = info.iconUrl;
    if (iconUrl == null) return fallback;
    if (isSvgUrl(iconUrl)) {
      // Logos are often wide: fit them inside the circle.
      return CircleAvatar(
        radius: radius,
        backgroundColor: scheme.surfaceContainerHighest,
        child: Padding(
          padding: EdgeInsets.all(radius * 0.3),
          child: _NetworkSvg(url: iconUrl, fallback: fallback),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        iconUrl.toString(),
        width: radius * 2,
        height: radius * 2,
        // Decode at the displayed size instead of the source resolution.
        cacheWidth: (radius * 2 * MediaQuery.devicePixelRatioOf(context))
            .round(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  /// Downloads SVG icons: returns the document, or `null` when the URL does
  /// not return a valid SVG.
  ///
  /// Replace it in widget tests (which cannot open network connections),
  /// e.g. `ProviderAvatar.svgLoader = (_) async => null;`.
  static Future<String?> Function(Uri url) svgLoader = _downloadSvg;

  static Future<String?> _downloadSvg(Uri url) async {
    try {
      final response = await Dio().getUri<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data;
      return body != null && body.contains('<svg') ? body : null;
    } on Object {
      return null;
    }
  }

  /// Whether [url] points to an SVG image, which `Image.network` cannot
  /// decode.
  @visibleForTesting
  static bool isSvgUrl(Uri url) =>
      url.path.toLowerCase().endsWith('.svg') ||
      (url.scheme == 'data' && url.path.startsWith('image/svg+xml'));
}

/// Downloads and draws an SVG, showing [fallback] while loading or when the
/// URL does not return a valid SVG.
///
/// The bytes are fetched here instead of with `SvgPicture.network`, which
/// reports invalid documents as uncaught errors even with an error builder.
class _NetworkSvg extends StatefulWidget {
  const _NetworkSvg({required this.url, required this.fallback});

  final Uri url;
  final Widget fallback;

  /// Downloads shared by every avatar of the same URL.
  static final _cache = <Uri, Future<String?>>{};

  static Future<String?> _load(Uri url) {
    final cached = _cache[url];
    if (cached != null) return cached;
    final download = ProviderAvatar.svgLoader(url);
    _cache[url] = download;
    // Failures are not kept, so the next avatar tries again.
    unawaited(
      download.then((svg) {
        if (svg == null && identical(_cache[url], download)) {
          unawaited(_cache.remove(url));
        }
      }),
    );
    return download;
  }

  @override
  State<_NetworkSvg> createState() => _NetworkSvgState();
}

class _NetworkSvgState extends State<_NetworkSvg> {
  late Future<String?> _svg = _NetworkSvg._load(widget.url);

  @override
  void didUpdateWidget(_NetworkSvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _svg = _NetworkSvg._load(widget.url);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _svg,
    builder: (context, snapshot) {
      final svg = snapshot.data;
      if (svg == null) return widget.fallback;
      return SvgPicture.string(
        svg,
        errorBuilder: (context, error, stackTrace) => widget.fallback,
      );
    },
  );
}
