import 'package:flutter/material.dart';

/// Content of a popup menu item: an icon and a label, optionally in
/// [color] (e.g. the error color of destructive actions).
class MenuRow extends StatelessWidget {
  /// Creates a row with [icon] and [label].
  const MenuRow({
    required this.icon,
    required this.label,
    this.color,
    super.key,
  });

  /// Icon before the label.
  final IconData icon;

  /// Text of the item.
  final String label;

  /// Color of the icon and the label. Defaults to the menu colors.
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          label,
          style: color == null ? null : TextStyle(color: color),
        ),
      ),
    ],
  );
}
