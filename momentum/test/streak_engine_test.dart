import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/utils/app_date_utils.dart';
import 'package:momentum/data/logic/streak_engine.dart';
import 'package:momentum/data/models/habit.dart';

void main() {
  final today = DateTime(2026, 8, 25);

  Habit dailyHabit({DateTime? created}) {
    return Habit(
      id: 'h1',
      name: 'Water',
      iconKey: 'water_drop',
      colorIndex: 0,
      frequency: HabitFrequency.daily,
      days: const [],
      createdDate: created ?? DateTime(2026, 7, 1),
    );
  }

  Habit weekdayHabit({DateTime? created}) {
    return Habit(
      id: 'h2',
      name: 'Gym',
      iconKey: 'fitness',
      colorIndex: 2,
      frequency: HabitFrequency.specificDays,
      days: const [1, 3, 5],
      createdDate: created ?? DateTime(2026, 7, 1),
    );
  }

  Set<String> keys(List<DateTime> days) {
    return days.map(AppDateUtils.dateKey).toSet();
  }

  test('current streak counts consecutive completed days', () {
    final completions = keys([
      DateTime(2026, 8, 23),
      DateTime(2026, 8, 24),
      DateTime(2026, 8, 25),
    ]);
    expect(StreakEngine.currentStreak(dailyHabit(), completions, today), 3);
  });

  test('a pending today does not break the streak', () {
    final completions = keys([DateTime(2026, 8, 23), DateTime(2026, 8, 24)]);
    expect(StreakEngine.currentStreak(dailyHabit(), completions, today), 2);
  });

  test('a single missed day is bridged by grace', () {
    final completions = keys([
      DateTime(2026, 8, 20),
      DateTime(2026, 8, 21),
      DateTime(2026, 8, 22),
      DateTime(2026, 8, 23),
      DateTime(2026, 8, 25),
    ]);
    expect(StreakEngine.currentStreak(dailyHabit(), completions, today), 5);
  });

  test('two missed days break the streak', () {
    final completions = keys([
      DateTime(2026, 8, 20),
      DateTime(2026, 8, 21),
      DateTime(2026, 8, 22),
      DateTime(2026, 8, 25),
    ]);
    expect(StreakEngine.currentStreak(dailyHabit(), completions, today), 1);
  });

  test('grace is only granted once per streak', () {
    final completions = keys([
      DateTime(2026, 8, 18),
      DateTime(2026, 8, 19),
      DateTime(2026, 8, 20),
      DateTime(2026, 8, 24),
      DateTime(2026, 8, 25),
    ]);
    expect(StreakEngine.currentStreak(dailyHabit(), completions, today), 2);
  });

  test('streak stops at the creation date', () {
    final habit = dailyHabit(created: DateTime(2026, 8, 24));
    final completions = keys([DateTime(2026, 8, 24), DateTime(2026, 8, 25)]);
    expect(StreakEngine.currentStreak(habit, completions, today), 2);
  });

  test('specific-day habits skip non-scheduled days entirely', () {
    final habit = weekdayHabit();
    final completions = keys([DateTime(2026, 8, 21), DateTime(2026, 8, 24)]);
    expect(StreakEngine.currentStreak(habit, completions, today), 2);
  });

  test(
    'specific-day habit with pending today keeps streak from last session',
    () {
      final habit = weekdayHabit();
      expect(DateTime(2026, 8, 25).weekday, 2);
      final completions = keys([
        DateTime(2026, 8, 19),
        DateTime(2026, 8, 21),
        DateTime(2026, 8, 24),
      ]);
      expect(StreakEngine.currentStreak(habit, completions, today), 3);
    },
  );

  test('missing one scheduled session is bridged for specific-day habits', () {
    final habit = weekdayHabit();
    final completions = keys([
      DateTime(2026, 8, 17),
      DateTime(2026, 8, 19),
      DateTime(2026, 8, 24),
    ]);
    expect(StreakEngine.currentStreak(habit, completions, today), 3);
  });

  test('longest streak finds the best historical run', () {
    final completions = keys([
      DateTime(2026, 7, 10),
      DateTime(2026, 7, 11),
      DateTime(2026, 7, 12),
      DateTime(2026, 7, 13),
      DateTime(2026, 7, 14),
      DateTime(2026, 8, 24),
      DateTime(2026, 8, 25),
    ]);
    expect(StreakEngine.longestStreak(dailyHabit(), completions, today), 5);
  });

  test('longest streak bridges a single missed day too', () {
    final completions = keys([
      DateTime(2026, 7, 10),
      DateTime(2026, 7, 11),
      DateTime(2026, 7, 13),
      DateTime(2026, 7, 14),
      DateTime(2026, 7, 15),
    ]);
    expect(StreakEngine.longestStreak(dailyHabit(), completions, today), 5);
  });

  test('longest streak ignores a pending final day', () {
    final completions = keys([DateTime(2026, 8, 24)]);
    expect(StreakEngine.longestStreak(dailyHabit(), completions, today), 1);
  });

  test('longest streak counts scheduled days only', () {
    final completions = keys([
      DateTime(2026, 7, 6),
      DateTime(2026, 7, 8),
      DateTime(2026, 7, 10),
      DateTime(2026, 7, 13),
      DateTime(2026, 7, 15),
    ]);
    expect(StreakEngine.longestStreak(weekdayHabit(), completions, today), 5);
  });

  test('empty history yields zero streaks', () {
    expect(StreakEngine.currentStreak(dailyHabit(), const {}, today), 0);
    expect(StreakEngine.longestStreak(dailyHabit(), const {}, today), 0);
  });

  test('completions and scheduled counts respect the range', () {
    final habit = weekdayHabit();
    final completions = keys([
      DateTime(2026, 8, 17),
      DateTime(2026, 8, 19),
      DateTime(2026, 8, 21),
      DateTime(2026, 8, 24),
      DateTime(2026, 8, 25),
    ]);
    final from = DateTime(2026, 8, 17);
    final to = DateTime(2026, 8, 23);
    expect(StreakEngine.completionsInRange(habit, completions, from, to), 3);
    expect(StreakEngine.scheduledDaysInRange(habit, from, to), 3);
  });

  test('completion rate covers only finalized days', () {
    final habit = dailyHabit(created: DateTime(2026, 8, 20));
    final completions = keys([
      DateTime(2026, 8, 20),
      DateTime(2026, 8, 21),
      DateTime(2026, 8, 22),
    ]);
    final rate = StreakEngine.completionRate(
      habit,
      completions,
      today,
      windowDays: 30,
    );
    expect(rate, closeTo(3 / 5, 0.0001));
  });

  test('completion rate is zero when nothing was scheduled', () {
    final habit = weekdayHabit(created: DateTime(2026, 8, 22));
    final rate = StreakEngine.completionRate(
      habit,
      const {},
      today,
      windowDays: 30,
    );
    expect(rate, 0);
  });
}
