import 'package:flutter/material.dart';

import '../../core/constants/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../data/models/habit.dart';
import '../widgets/check_ring_button.dart';
import '../widgets/habit_icon_chip.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.completedToday,
    required this.onToggle,
    required this.onLongPress,
  });

  final Habit habit;
  final int streak;
  final bool completedToday;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  String get _frequencyLabel {
    return switch (habit.frequency) {
      HabitFrequency.daily => 'Every day',
      HabitFrequency.specificDays =>
        habit.days
            .map((day) => AppDateUtils.weekdayLabel(day, short: false))
            .join(', '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final habitColor = HabitColors.at(habit.colorIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                HabitIconChip(
                  iconKey: habit.iconKey,
                  colorIndex: habit.colorIndex,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (streak > 0) ...[
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: palette.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$streak-day streak',
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: palette.warning),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: palette.textTertiary),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              _frequencyLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: palette.textTertiary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedOpacity(
                  duration: AppMotion.base,
                  opacity: completedToday ? 1 : 0.55,
                  child: CheckRingButton(
                    completed: completedToday,
                    color: habitColor,
                    onTap: onToggle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
