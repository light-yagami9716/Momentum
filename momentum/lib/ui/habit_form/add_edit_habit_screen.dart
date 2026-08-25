import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_icon.dart';
import '../../state/habits_provider.dart';
import '../../state/settings_provider.dart';
import '../widgets/habit_icon_chip.dart';
import '../widgets/section_header.dart';

class AddEditHabitScreen extends StatefulWidget {
  const AddEditHabitScreen({super.key, this.habitId});

  final String? habitId;

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late String _iconKey;
  late int _colorIndex;
  late HabitFrequency _frequency;
  late Set<int> _days;
  late bool _reminderEnabled;
  late int _reminderMinutes;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _load(Habit? habit) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = habit?.name ?? '';
    _iconKey = habit?.iconKey ?? 'water_drop';
    _colorIndex = habit?.colorIndex ?? 0;
    _frequency = habit?.frequency ?? HabitFrequency.daily;
    _days = habit == null ? <int>{} : habit.days.toSet();
    _reminderEnabled = habit?.reminderMinutes != null;
    _reminderMinutes = habit?.reminderMinutes ?? 8 * 60;
  }

  Future<void> _pickReminderTime() async {
    final use24Hour = context.read<SettingsProvider>().use24Hour;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _reminderMinutes ~/ 60,
        minute: _reminderMinutes % 60,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: use24Hour),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderMinutes = picked.hour * 60 + picked.minute;
      });
    }
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Give your habit a name';
    if (name.length < 3) return 'Names need at least 3 characters';
    if (name.length > 30) return 'Keep the name under 30 characters';
    if (context.read<HabitsProvider>().isNameTaken(
      name,
      exceptId: widget.habitId,
    )) {
      return 'You already have a habit with this name';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frequency == HabitFrequency.specificDays && _days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one day of the week')),
      );
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<HabitsProvider>();

    if (widget.habitId == null) {
      await provider.addHabit(
        name: _nameController.text,
        iconKey: _iconKey,
        colorIndex: _colorIndex,
        frequency: _frequency,
        days: _days.toList()..sort(),
        reminderMinutes: _reminderEnabled ? _reminderMinutes : null,
      );
    } else {
      await provider.updateHabit(
        widget.habitId!,
        name: _nameController.text,
        iconKey: _iconKey,
        colorIndex: _colorIndex,
        frequency: _frequency,
        days: _days.toList()..sort(),
        reminderMinutes: _reminderEnabled ? _reminderMinutes : null,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    final habit = widget.habitId == null
        ? null
        : provider.habitById(widget.habitId!);
    _load(habit);
    if (widget.habitId != null && habit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final palette = context.palette;
    final isEdit = widget.habitId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit habit' : 'New habit')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _PreviewCard(
                name: _nameController.text.isEmpty
                    ? 'Your habit'
                    : _nameController.text,
                iconKey: _iconKey,
                colorIndex: _colorIndex,
                frequency: _frequency,
                days: _days,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                  hintText: 'e.g. Drink water, Read 20 pages',
                  counterText: '',
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 28),
              const SectionHeader(kicker: 'Personality', title: 'Icon'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final icon in HabitIcon.catalog)
                    GestureDetector(
                      onTap: () => setState(() => _iconKey = icon.key),
                      child: HabitIconChip(
                        iconKey: icon.key,
                        colorIndex: _colorIndex,
                        size: 48,
                        iconSize: 24,
                        selected: icon.key == _iconKey,
                        neutral: icon.key != _iconKey,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const SectionHeader(kicker: 'Personality', title: 'Colour'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < HabitColors.count; i++)
                    _ColorOption(
                      color: HabitColors.at(i),
                      selected: i == _colorIndex,
                      onTap: () => setState(() => _colorIndex = i),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const SectionHeader(kicker: 'Rhythm', title: 'Frequency'),
              const SizedBox(height: 14),
              SegmentedButton<HabitFrequency>(
                segments: const [
                  ButtonSegment(
                    value: HabitFrequency.daily,
                    label: Text('Every day'),
                    icon: Icon(Icons.today_outlined),
                  ),
                  ButtonSegment(
                    value: HabitFrequency.specificDays,
                    label: Text('Custom'),
                    icon: Icon(Icons.date_range_outlined),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (selection) => setState(() {
                  _frequency = selection.first;
                }),
              ),
              if (_frequency == HabitFrequency.specificDays) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var day = 1; day <= 7; day++)
                      FilterChip(
                        label: Text(
                          AppDateUtils.weekdayLabel(day, short: true),
                        ),
                        selected: _days.contains(day),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _days.add(day);
                          } else {
                            _days.remove(day);
                          }
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              const SectionHeader(kicker: 'Nudge', title: 'Reminder'),
              const SizedBox(height: 6),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.notifications_none_rounded,
                        color: palette.textSecondary,
                      ),
                      title: const Text('Daily reminder'),
                      subtitle: const Text(
                        'A gentle nudge at your chosen time',
                      ),
                      value: _reminderEnabled,
                      onChanged: (value) =>
                          setState(() => _reminderEnabled = value),
                    ),
                    if (_reminderEnabled)
                      ListTile(
                        leading: Icon(
                          Icons.schedule_rounded,
                          color: palette.textSecondary,
                        ),
                        title: const Text('Remind me at'),
                        trailing: Text(
                          AppDateUtils.formatTime(
                            _reminderMinutes,
                            use24Hour: context
                                .watch<SettingsProvider>()
                                .use24Hour,
                          ),
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: palette.accent),
                        ),
                        onTap: _pickReminderTime,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Save changes' : 'Create habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.name,
    required this.iconKey,
    required this.colorIndex,
    required this.frequency,
    required this.days,
  });

  final String name;
  final String iconKey;
  final int colorIndex;
  final HabitFrequency frequency;
  final Set<int> days;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = switch (frequency) {
      HabitFrequency.daily => 'Every day',
      HabitFrequency.specificDays =>
        days.isEmpty
            ? 'Pick your days'
            : days
                  .map((day) => AppDateUtils.weekdayLabel(day, short: true))
                  .join(' '),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            HabitIconChip(iconKey: iconKey, colorIndex: colorIndex),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium!
                        .copyWith(color: palette.textTertiary),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: HabitColors.at(colorIndex).withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 24,
                color: HabitColors.at(colorIndex).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
            : null,
      ),
    );
  }
}
