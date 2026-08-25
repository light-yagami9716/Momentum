import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/utils/app_date_utils.dart';
import '../core/utils/id_generator.dart';
import '../data/logic/streak_engine.dart';
import '../data/models/habit.dart';
import '../data/services/notification_service.dart';
import '../data/services/persistence_service.dart';

class DayCompletion {
  const DayCompletion({
    required this.day,
    required this.completed,
    required this.scheduled,
  });

  final DateTime day;
  final bool completed;
  final bool scheduled;
}

class HabitSummary {
  const HabitSummary({
    required this.habit,
    required this.currentStreak,
    required this.longestStreak,
    required this.rate30d,
    required this.totalCompletions,
  });

  final Habit habit;
  final int currentStreak;
  final int longestStreak;
  final double rate30d;
  final int totalCompletions;
}

class HabitsProvider extends ChangeNotifier {
  HabitsProvider(this._persistence, [NotificationScheduler? scheduler])
    : _scheduler = scheduler ?? NoopNotificationScheduler() {
    _habits = _persistence.readHabits().map(Habit.fromJson).toList();
    _completions = {
      for (final entry in _persistence.readCompletions().entries)
        entry.key: (entry.value as List)
            .whereType<String>()
            .where((key) => RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key))
            .toSet(),
    };
  }

  final PersistenceService _persistence;
  final NotificationScheduler _scheduler;

  late List<Habit> _habits;
  late Map<String, Set<String>> _completions;

  Future<void> bootstrap() async {
    await _scheduler.initialize();
    for (final habit in _habits) {
      await _scheduler.scheduleHabitReminder(habit);
    }
  }

  List<Habit> get habits =>
      _habits.where((habit) => !habit.archived).toList(growable: false);

  List<Habit> get archivedHabits =>
      _habits.where((habit) => habit.archived).toList(growable: false);

  Habit? habitById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  bool isNameTaken(String name, {String? exceptId}) {
    final normalized = name.trim().toLowerCase();
    return _habits.any(
      (habit) =>
          habit.id != exceptId && habit.name.trim().toLowerCase() == normalized,
    );
  }

  bool isCompleted(String habitId, DateTime day) {
    return _completions[habitId]?.contains(AppDateUtils.dateKey(day)) ?? false;
  }

  int currentStreakOf(Habit habit) {
    return StreakEngine.currentStreak(
      habit,
      _completions[habit.id] ?? const {},
      AppDateUtils.today(),
    );
  }

  int longestStreakOf(Habit habit) {
    return StreakEngine.longestStreak(
      habit,
      _completions[habit.id] ?? const {},
      AppDateUtils.today(),
    );
  }

  int totalCompletionsOf(Habit habit) {
    return _completions[habit.id]?.length ?? 0;
  }

  double completionRateOf(Habit habit, {int windowDays = 30}) {
    return StreakEngine.completionRate(
      habit,
      _completions[habit.id] ?? const {},
      AppDateUtils.today(),
      windowDays: windowDays,
    );
  }

  HabitSummary summaryOf(Habit habit) {
    return HabitSummary(
      habit: habit,
      currentStreak: currentStreakOf(habit),
      longestStreak: longestStreakOf(habit),
      rate30d: completionRateOf(habit),
      totalCompletions: totalCompletionsOf(habit),
    );
  }

  int get todayScheduledCount {
    final today = AppDateUtils.today();
    return habits.where((habit) => habit.isScheduledOn(today)).length;
  }

  int get todayCompletedCount {
    final today = AppDateUtils.today();
    return habits
        .where(
          (habit) => habit.isScheduledOn(today) && isCompleted(habit.id, today),
        )
        .length;
  }

  double get todayProgress {
    final scheduled = todayScheduledCount;
    if (scheduled == 0) return 0;
    return todayCompletedCount / scheduled;
  }

  int get totalCompletionsAllTime =>
      _completions.values.map((set) => set.length).fold(0, (a, b) => a + b);

  HabitSummary? get bestHabit {
    HabitSummary? best;
    for (final habit in habits) {
      final summary = summaryOf(habit);
      if (best == null || summary.currentStreak > best.currentStreak) {
        best = summary;
      }
    }
    return best;
  }

  HabitSummary? get habitNeedingAttention {
    HabitSummary? worst;
    for (final habit in habits) {
      final summary = summaryOf(habit);
      if (worst == null || summary.rate30d < worst.rate30d) {
        worst = summary;
      }
    }
    return worst;
  }

  List<DayCompletion> weekSeries(DateTime anchor, int days) {
    final today = AppDateUtils.today();
    final start = AppDateUtils.addDays(
      AppDateUtils.normalize(anchor),
      -(days - 1),
    );
    return List.generate(days, (index) {
      final day = AppDateUtils.addDays(start, index);
      final scheduled = habits.any((habit) => habit.isScheduledOn(day));
      final completed = habits.any(
        (habit) => habit.isScheduledOn(day) && isCompleted(habit.id, day),
      );
      return DayCompletion(
        day: day,
        completed: completed,
        scheduled: scheduled || day.isBefore(today),
      );
    });
  }

  double heatmapIntensity(DateTime day) {
    final scheduled = habits
        .where((habit) => habit.isScheduledOn(day))
        .toList(growable: false);
    if (scheduled.isEmpty) return 0;

    var completed = 0;
    for (final habit in scheduled) {
      if (isCompleted(habit.id, day)) completed++;
    }
    return completed / scheduled.length;
  }

  Future<void> addHabit({
    required String name,
    required String iconKey,
    required int colorIndex,
    required HabitFrequency frequency,
    required List<int> days,
    int? reminderMinutes,
  }) async {
    final habit = Habit(
      id: IdGenerator.newId(),
      name: name.trim(),
      iconKey: iconKey,
      colorIndex: colorIndex,
      frequency: frequency,
      days: frequency == HabitFrequency.daily ? [] : days,
      createdDate: AppDateUtils.today(),
      reminderMinutes: reminderMinutes,
    );
    _habits = [..._habits, habit];
    notifyListeners();
    await _persistHabits();
    await _scheduler.scheduleHabitReminder(habit);
  }

  Future<void> updateHabit(
    String id, {
    required String name,
    required String iconKey,
    required int colorIndex,
    required HabitFrequency frequency,
    required List<int> days,
    int? reminderMinutes,
  }) async {
    Habit? updated;
    _habits = [
      for (final habit in _habits)
        if (habit.id == id)
          updated = habit.copyWith(
            name: name.trim(),
            iconKey: iconKey,
            colorIndex: colorIndex,
            frequency: frequency,
            days: frequency == HabitFrequency.daily ? [] : days,
            reminderMinutes: reminderMinutes,
          )
        else
          habit,
    ];
    notifyListeners();
    await _persistHabits();
    if (updated != null) {
      await _scheduler.scheduleHabitReminder(updated);
    }
  }

  Future<void> setArchived(String id, bool archived) async {
    Habit? changed;
    _habits = [
      for (final habit in _habits)
        if (habit.id == id)
          changed = habit.copyWith(archived: archived)
        else
          habit,
    ];
    notifyListeners();
    await _persistHabits();
    if (changed != null) {
      await _scheduler.scheduleHabitReminder(changed);
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits = _habits.where((habit) => habit.id != id).toList();
    _completions.remove(id);
    notifyListeners();
    await _persistHabits();
    await _persistCompletions();
    await _scheduler.cancelHabitReminder(id);
  }

  Future<void> toggleCheckIn(String id, DateTime day) async {
    final key = AppDateUtils.dateKey(day);
    final set = _completions[id] ?? <String>{};

    if (set.contains(key)) {
      set.remove(key);
    } else {
      set.add(key);
    }
    _completions[id] = set;
    notifyListeners();
    await _persistCompletions();
  }

  Future<void> _persistHabits() {
    return _persistence.writeHabits(
      _habits.map((habit) => habit.toJson()).toList(),
    );
  }

  Future<void> _persistCompletions() {
    return _persistence.writeCompletions({
      for (final entry in _completions.entries)
        entry.key: entry.value.toList()..sort(),
    });
  }

  String exportJson() {
    final payload = jsonEncode({
      'habits': _habits.map((habit) => habit.toJson()).toList(),
      'completions': {
        for (final entry in _completions.entries)
          entry.key: entry.value.toList()..sort(),
      },
      'exportedAt': DateTime.now().toIso8601String(),
    });
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(payload));
  }

  Future<void> resetAll() async {
    _habits = [];
    _completions = {};
    notifyListeners();
    await _scheduler.cancelAll();
    await _persistence.clearAll();
  }
}
