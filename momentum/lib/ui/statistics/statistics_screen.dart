import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../state/habits_provider.dart';
import '../../state/settings_provider.dart';
import '../widgets/habit_icon_chip.dart';
import '../widgets/section_header.dart';
import '../widgets/streak_ring.dart';
import 'month_heatmap.dart';
import 'week_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _month = AppDateUtils.firstDayOfMonth(AppDateUtils.today());

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    final weekStartsMonday = context.watch<SettingsProvider>().weekStartsMonday;
    final palette = context.palette;
    final today = AppDateUtils.today();

    final weekData = [
      for (var i = 6; i >= 0; i--)
        WeekBarData(
          day: AppDateUtils.addDays(today, -i),
          intensity: provider.heatmapIntensity(AppDateUtils.addDays(today, -i)),
        ),
    ];

    final summaries = provider.habits.map(provider.summaryOf).toList();
    final averageRate = summaries.isEmpty
        ? 0.0
        : summaries.map((s) => s.rate30d).reduce((a, b) => a + b) /
              summaries.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(kicker: 'Insights', title: 'Statistics'),
              ),
            ),
            if (summaries.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _StatsEmptyState(),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.7,
                  ),
                  delegate: SliverChildListDelegate([
                    _StatCard(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Total check-ins',
                      value: '${provider.totalCompletionsAllTime}',
                    ),
                    _StatCard(
                      icon: Icons.speed_rounded,
                      label: '30-day rate',
                      value: '${(averageRate * 100).round()}%',
                    ),
                    _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Top streak',
                      value:
                          '${summaries.map((s) => s.currentStreak).reduce((a, b) => a > b ? a : b)}',
                      highlight: palette.success,
                    ),
                    _StatCard(
                      icon: Icons.emoji_events_outlined,
                      label: 'Best habit',
                      value: _truncate(
                        summaries
                            .reduce(
                              (a, b) =>
                                  a.currentStreak >= b.currentStreak ? a : b,
                            )
                            .habit
                            .name,
                        12,
                      ),
                      highlight: palette.accent,
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _PanelCard(
                    title: 'Last 7 days',
                    child: WeekBarChart(data: weekData, today: today),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _PanelCard(
                    title: 'Consistency map',
                    child: MonthHeatmap(
                      month: _month,
                      intensityFor: provider.heatmapIntensity,
                      weekStartsMonday: weekStartsMonday,
                      onPreviousMonth: () => setState(() {
                        _month = DateTime(_month.year, _month.month - 1, 1);
                      }),
                      onNextMonth: () => setState(() {
                        _month = DateTime(_month.year, _month.month + 1, 1);
                      }),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'BY HABIT',
                    style: Theme.of(context).textTheme.labelSmall!
                        .copyWith(color: palette.accent, letterSpacing: 1.4),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                sliver: SliverList.separated(
                  itemCount: summaries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    return _HabitStatRow(summary: summary);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _truncate(String text, int max) {
    return text.length <= max ? text : '${text.substring(0, max - 1)}…';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = highlight ?? palette.textPrimary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: tint.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall!
                        .copyWith(color: palette.textTertiary),
                  ),
                ),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium!
                  .copyWith(color: tint),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _HabitStatRow extends StatelessWidget {
  const _HabitStatRow({required this.summary});

  final HabitSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final habit = summary.habit;
    final habitColor = HabitColors.at(habit.colorIndex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            HabitIconChip(
              iconKey: habit.iconKey,
              colorIndex: habit.colorIndex,
              size: 38,
              iconSize: 19,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${summary.totalCompletions} check-ins · best ${summary.longestStreak}',
                    style: Theme.of(context).textTheme.labelMedium!
                        .copyWith(color: palette.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StreakRing(
              progress: summary.rate30d,
              color: habitColor,
              size: 46,
              strokeWidth: 5,
              child: Text(
                '${(summary.rate30d * 100).round()}',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsEmptyState extends StatelessWidget {
  const _StatsEmptyState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                size: 36,
                color: palette.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No data yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Check in a few habits and your progress will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(color: palette.textSecondary, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}
