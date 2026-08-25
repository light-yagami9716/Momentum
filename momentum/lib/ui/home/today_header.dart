import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../state/habits_provider.dart';
import '../widgets/streak_ring.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
    required this.provider,
    required this.use24Hour,
  });

  final HabitsProvider provider;
  final bool use24Hour;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheduled = provider.todayScheduledCount;
    final completed = provider.todayCompletedCount;
    final progress = provider.todayProgress;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall!
                    .copyWith(color: palette.accent, letterSpacing: 1.4),
              ),
              const SizedBox(height: 6),
              Text('Today', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatDateLong(AppDateUtils.today()),
                style: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: palette.textSecondary),
              ),
              const SizedBox(height: 10),
              Text(
                scheduled == 0
                    ? 'No habits scheduled'
                    : completed == scheduled
                    ? 'All habits complete'
                    : '$completed of $scheduled done',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: completed == scheduled && scheduled > 0
                      ? palette.success
                      : palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        StreakRing(
          progress: progress,
          color: palette.accent,
          size: 84,
          strokeWidth: 8,
          child: Text(
            scheduled == 0 ? '—' : '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium!
                .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
      ],
    );
  }
}
