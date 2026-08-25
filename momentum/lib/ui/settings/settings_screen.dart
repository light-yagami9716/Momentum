import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/habits_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset all data'),
          content: const Text(
            'This deletes every habit, check-in, and preference. There is no way back.',
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
              child: const Text('Reset everything'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<HabitsProvider>().resetAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('All data cleared')));
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final export = context.read<HabitsProvider>().exportJson();
    await Clipboard.setData(ClipboardData(text: export));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data copied to the clipboard as JSON')),
      );
    }
  }

  void _showArchived(BuildContext context) {
    final provider = context.read<HabitsProvider>();
    final palette = context.palette;
    final archived = provider.archivedHabits;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Archived habits',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (archived.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Nothing archived yet. Long-press a habit on the Today screen to archive it.',
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.bodyMedium!
                          .copyWith(color: palette.textSecondary),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: archived.length,
                      itemBuilder: (listContext, index) {
                        final habit = archived[index];
                        return ListTile(
                          leading: Icon(
                            Icons.inventory_2_outlined,
                            color: palette.textTertiary,
                          ),
                          title: Text(habit.name),
                          subtitle: Text(
                            '${provider.totalCompletionsOf(habit)} check-ins kept',
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              provider.setArchived(habit.id, false);
                              Navigator.of(sheetContext).pop();
                            },
                            child: const Text('Restore'),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            const SectionHeader(kicker: 'Preferences', title: 'Settings'),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: 'Appearance',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applies instantly and is remembered.',
                      style: Theme.of(context).textTheme.labelMedium!
                          .copyWith(color: palette.textTertiary),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined),
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {themeProvider.mode},
                      onSelectionChanged: (selection) =>
                          themeProvider.setMode(selection.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              title: 'Formats',
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      Icons.schedule_outlined,
                      color: palette.textSecondary,
                    ),
                    title: const Text('24-hour time'),
                    subtitle: const Text('Show reminder times as 08:30'),
                    value: settings.use24Hour,
                    onChanged: settings.setUse24Hour,
                  ),
                  Divider(
                    height: 1,
                    color: palette.border,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week starts on',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Monday')),
                            ButtonSegment(value: false, label: Text('Sunday')),
                          ],
                          selected: {settings.weekStartsMonday},
                          onSelectionChanged: (selection) =>
                              settings.setWeekStartsMonday(selection.first),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              title: 'Habits',
              child: ListTile(
                leading: Icon(
                  Icons.inventory_2_outlined,
                  color: palette.textSecondary,
                ),
                title: const Text('Archived habits'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showArchived(context),
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              title: 'Data',
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.ios_share_rounded,
                      color: palette.textSecondary,
                    ),
                    title: const Text('Export data'),
                    subtitle: const Text('Copy all habits and history as JSON'),
                    onTap: () => _exportData(context),
                  ),
                  Divider(
                    height: 1,
                    color: palette.border,
                    indent: 16,
                    endIndent: 16,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.restart_alt_outlined,
                      color: palette.danger,
                    ),
                    title: Text(
                      'Reset all data',
                      style: TextStyle(color: palette.danger),
                    ),
                    subtitle: Text(
                      'Delete every habit and check-in',
                      style: TextStyle(color: palette.textTertiary),
                    ),
                    onTap: () => _confirmReset(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SettingsGroup(
              title: 'About',
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('Momentum'),
                    subtitle: Text(
                      'Version 1.0.0 · Offline-first habit tracker',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.cloud_off_outlined),
                    title: Text('Your data stays on this device'),
                    subtitle: Text(
                      'No accounts, no servers, no tracking. Everything lives in local storage.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall!
                .copyWith(color: palette.textTertiary, letterSpacing: 1.4),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}
