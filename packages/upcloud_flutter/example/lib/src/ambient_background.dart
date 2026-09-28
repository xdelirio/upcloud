import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Drives the slow drift of every [AmbientBackground] in the app.
///
/// There is a single clock above the navigator, so a pushed route paints
/// exactly the same frame as the route below it.
///
/// The drift is so slow that about 15 updates per second look continuous.
/// A timer is used instead of a ticker on purpose: a ticker would schedule
/// a frame on every vsync, and each frame re-renders the glass surfaces
/// that blur the backdrop. The motion stops when the platform asks to
/// reduce animations and while the app is not visible.
class AmbientMotion extends StatefulWidget {
  const AmbientMotion({required this.child, super.key});

  final Widget child;

  /// Duration of a full loop of the drift.
  static const period = Duration(seconds: 60);

  /// Time between two updates of the drift.
  static const interval = Duration(milliseconds: 66);

  /// The drift phase, from 0 to 1. Stays still without an [AmbientMotion].
  static ValueListenable<double> of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_AmbientMotionScope>()
          ?.phase ??
      const _StillPhase();

  @override
  State<AmbientMotion> createState() => _AmbientMotionState();
}

class _AmbientMotionState extends State<AmbientMotion> {
  final _phase = ValueNotifier<double>(0);
  final _clock = Stopwatch();
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;
  var _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: (_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  /// Runs the clock only while it can be seen.
  void _sync() {
    final state = SchedulerBinding.instance.lifecycleState;
    final visible = state == null || state == AppLifecycleState.resumed;
    if (_reduceMotion || !visible) {
      _timer?.cancel();
      _timer = null;
      _clock.stop();
    } else {
      _clock.start();
      _timer ??= Timer.periodic(AmbientMotion.interval, (_) {
        final period = AmbientMotion.period.inMicroseconds;
        _phase.value = (_clock.elapsedMicroseconds % period) / period;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _AmbientMotionScope(phase: _phase, child: widget.child);
}

class _AmbientMotionScope extends InheritedWidget {
  const _AmbientMotionScope({required this.phase, required super.child});

  final ValueListenable<double> phase;

  @override
  bool updateShouldNotify(_AmbientMotionScope oldWidget) =>
      phase != oldWidget.phase;
}

class _StillPhase implements ValueListenable<double> {
  const _StillPhase();

  @override
  double get value => 0;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

/// A calm backdrop for the whole app: the theme surface tinted by a few
/// large, blurred and slowly drifting color fields derived from the color
/// scheme.
///
/// Glass chrome (tab bar, rail, floating buttons) refracts it, while the
/// content panels stay readable on top of it.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AmbientPainter(
          phase: AmbientMotion.of(context),
          palette: _AmbientPalette.of(scheme),
        ),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}

/// A soft radial color field.
@immutable
class _Blob {
  const _Blob({
    required this.color,
    required this.center,
    required this.drift,
    required this.radius,
    required this.speed,
    required this.phase,
  });

  final Color color;

  /// Resting position, as a fraction of the size.
  final Offset center;

  /// Travel around [center], as a fraction of the size.
  final Offset drift;

  /// Radius, as a fraction of the longest side.
  final double radius;

  /// Whole cycles per loop of the drift (integers keep the loop
  /// seamless).
  final int speed;

  final double phase;
}

@immutable
class _AmbientPalette {
  const _AmbientPalette({required this.base, required this.blobs});

  factory _AmbientPalette.of(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    // Low saturation on purpose: the backdrop must never compete with the
    // content.
    final strength = dark ? 0.16 : 0.12;
    const violet = Color(0xFF7C4DFF);
    const teal = Color(0xFF2BB3A6);
    return _AmbientPalette(
      base: dark ? scheme.surfaceContainerLowest : scheme.surfaceContainerLow,
      blobs: [
        _Blob(
          color: scheme.primary.withValues(alpha: strength),
          center: const Offset(0.1, 0.05),
          drift: const Offset(0.12, 0.08),
          radius: 0.75,
          speed: 1,
          phase: 0,
        ),
        _Blob(
          color: violet.withValues(alpha: strength * 0.7),
          center: const Offset(0.95, 0.35),
          drift: const Offset(0.08, 0.12),
          radius: 0.65,
          speed: 1,
          phase: 2.1,
        ),
        _Blob(
          color: teal.withValues(alpha: strength * 0.7),
          center: const Offset(0.3, 0.95),
          drift: const Offset(0.14, 0.06),
          radius: 0.7,
          speed: 2,
          phase: 4.2,
        ),
      ],
    );
  }

  final Color base;
  final List<_Blob> blobs;

  @override
  bool operator ==(Object other) =>
      other is _AmbientPalette &&
      other.base == base &&
      _sameColors(other.blobs, blobs);

  static bool _sameColors(List<_Blob> a, List<_Blob> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].color != b[i].color) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(base, Object.hashAll(blobs.map((b) => b.color)));
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.phase, required this.palette})
    : _basePaint = Paint()..color = palette.base,
      super(repaint: phase);

  final ValueListenable<double> phase;
  final _AmbientPalette palette;
  final Paint _basePaint;

  // Shaders only depend on the size: they are created once and every frame
  // just translates the canvas.
  Size? _shaderSize;
  final List<Paint> _blobPaints = [];
  final List<double> _radii = [];

  void _prepare(Size size) {
    if (_shaderSize == size) return;
    _shaderSize = size;
    _blobPaints.clear();
    _radii.clear();
    for (final blob in palette.blobs) {
      final radius = size.longestSide * blob.radius;
      _radii.add(radius);
      _blobPaints.add(
        Paint()
          ..shader = RadialGradient(
            colors: [blob.color, blob.color.withValues(alpha: 0)],
            stops: const [0, 1],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas
      ..clipRect(bounds)
      ..drawRect(bounds, _basePaint);
    if (size.isEmpty) return;
    _prepare(size);
    final angle = phase.value * 2 * math.pi;
    for (var i = 0; i < palette.blobs.length; i++) {
      final blob = palette.blobs[i];
      final a = angle * blob.speed + blob.phase;
      final dx = (blob.center.dx + blob.drift.dx * math.sin(a)) * size.width;
      final dy = (blob.center.dy + blob.drift.dy * math.cos(a)) * size.height;
      canvas
        ..save()
        ..translate(dx, dy)
        ..drawCircle(Offset.zero, _radii[i], _blobPaints[i])
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) =>
      oldDelegate.palette != palette || oldDelegate.phase != phase;
}
