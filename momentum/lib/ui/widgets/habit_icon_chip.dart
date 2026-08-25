import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/habit_icon.dart';

class HabitIconChip extends StatelessWidget {
  const HabitIconChip({
    super.key,
    required this.iconKey,
    required this.colorIndex,
    this.size = 44,
    this.iconSize = 22,
    this.selected = false,
    this.neutral = false,
  });

  final String iconKey;
  final int colorIndex;
  final double size;
  final double iconSize;
  final bool selected;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = neutral ? palette.textSecondary : HabitColors.at(colorIndex);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? 1 : 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        HabitIcon.iconFor(iconKey),
        size: iconSize,
        color: selected ? Colors.white : color,
      ),
    );
  }
}
