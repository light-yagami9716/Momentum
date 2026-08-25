import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../state/habits_provider.dart';
import '../../state/settings_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/section_header.dart';
import 'habit_card.dart';
import 'today_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _showHabitMenu(BuildContext context, String habitId) {
    final provider = context.read<HabitsProvider>();
    final habit = provider.habitById(habitId);
    if (habit == null) return Future.value();

    final palette = context.palette;
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit habit'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context)
                      .pushNamed(AppRoutes.editHabit, arguments: habitId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive habit'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await provider.setArchived(habitId, true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${habit.name} archived')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: palette.danger),
                title: Text(
                  'Delete habit',
                  style: TextStyle(color: palette.danger),
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await _confirmDelete(context, habit.name);
                  if (confirmed) await provider.deleteHabit(habitId);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final palette = context.palette;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete habit'),
          content: Text(
            'Delete "$name" and its entire check-in history? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(palette.danger),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    final use24Hour = context.watch<SettingsProvider>().use24Hour;
    final habits = provider.habits;
    final today = AppDateUtils.today();

    final scheduled = habits
        .where((habit) => habit.isScheduledOn(today))
        .toList();
    final notToday = habits
        .where((habit) => !habit.isScheduledOn(today))
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TodayHeader(provider: provider, use24Hour: use24Hour),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: habits.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      children: [
                        if (scheduled.isNotEmpty) ...[
                          SectionHeader(
                            kicker: 'Check in',
                            title: 'Your habits',
                            actionLabel: '${scheduled.length} scheduled',
                          ),
                          const SizedBox(height: 12),
                          ...scheduled.map(
                            (habit) => HabitCard(
                              habit: habit,
                              streak: provider.currentStreakOf(habit),
                              completedToday: provider.isCompleted(
                                habit.id,
                                today,
                              ),
                              onToggle: () async {
                                await provider.toggleCheckIn(habit.id, today);
                                if (context.mounted &&
                                    provider.todayCompletedCount ==
                                        provider.todayScheduledCount &&
                                    provider.todayScheduledCount > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Every habit complete. See you tomorrow.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () =>
                                  _showHabitMenu(context, habit.id),
                            ),
                          ),
                        ],
                        if (notToday.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const SectionHeader(
                            kicker: 'Rest day',
                            title: 'Not today',
                          ),
                          const SizedBox(height: 12),
                          ...notToday.map(
                            (habit) => HabitCard(
                              habit: habit,
                              streak: provider.currentStreakOf(habit),
                              completedToday: provider.isCompleted(
                                habit.id,
                                today,
                              ),
                              onToggle: () =>
                                  provider.toggleCheckIn(habit.id, today),
                              onLongPress: () =>
                                  _showHabitMenu(context, habit.id),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: habits.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.addHabit),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New habit'),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 40,
                color: palette.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text('Start your first streak', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Small actions, repeated consistently, compound into meaningful change. Create your first habit to get going.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium!.copyWith(
                color: palette.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.addHabit),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create a habit'),
            ),
          ],
        ),
      ),
    );
  }
}
