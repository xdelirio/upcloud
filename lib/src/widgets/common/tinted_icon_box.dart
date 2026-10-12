import 'package:flutter/material.dart';

/// An icon on a rounded square tinted with its own color, as used for file
/// types and transfer states.
class TintedIconBox extends StatelessWidget {
  /// Creates a box of [size] with [icon] drawn in [color].
  const TintedIconBox({
    required this.icon,
    required this.color,
    required this.size,
    super.key,
  });

  /// Icon at the center.
  final IconData icon;

  /// Color of the icon; the background is a faint tint of it.
  final Color color;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(size / 4),
    ),
    child: Icon(icon, color: color, size: size * 0.6),
  );
}
