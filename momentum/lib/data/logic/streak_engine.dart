import '../../core/utils/app_date_utils.dart';
import '../models/habit.dart';

class StreakEngine {
  const StreakEngine._();

  static int currentStreak(
    Habit habit,
    Set<String> completions,
    DateTime today,
  ) {
    var streak = 0;
    var graceUsed = false;
    var pendingWindowOpen = true;
    var day = AppDateUtils.normalize(today);

    while (!day.isBefore(habit.createdDate)) {
      if (!habit.isScheduledOn(day)) {
        day = AppDateUtils.addDays(day, -1);
        continue;
      }

      final completed = completions.contains(AppDateUtils.dateKey(day));

      if (completed) {
        streak++;
        pendingWindowOpen = false;
      } else if (pendingWindowOpen) {
        pendingWindowOpen = false;
      } else if (!graceUsed && streak > 0) {
        graceUsed = true;
      } else {
        break;
      }

      day = AppDateUtils.addDays(day, -1);
    }

    return streak;
  }

  static int longestStreak(
    Habit habit,
    Set<String> completions,
    DateTime today,
  ) {
    var longest = 0;
    var run = 0;
    var graceUsed = false;
    var day = habit.createdDate;
    final last = AppDateUtils.normalize(today);

    while (!day.isAfter(last)) {
      if (!habit.isScheduledOn(day)) {
        day = AppDateUtils.addDays(day, 1);
        continue;
      }

      final completed = completions.contains(AppDateUtils.dateKey(day));

      if (completed) {
        run++;
        if (run > longest) longest = run;
      } else if (AppDateUtils.isSameDay(day, last)) {
        day = AppDateUtils.addDays(day, 1);
        continue;
      } else if (run > 0 && !graceUsed) {
        graceUsed = true;
      } else {
        run = 0;
        graceUsed = false;
      }

      day = AppDateUtils.addDays(day, 1);
    }

    return longest;
  }

  static int completionsInRange(
    Habit habit,
    Set<String> completions,
    DateTime from,
    DateTime to,
  ) {
    var count = 0;
    var day = AppDateUtils.normalize(from);
    final end = AppDateUtils.normalize(to);

    while (!day.isAfter(end)) {
      if (habit.isScheduledOn(day) &&
          completions.contains(AppDateUtils.dateKey(day))) {
        count++;
      }
      day = AppDateUtils.addDays(day, 1);
    }

    return count;
  }

  static int scheduledDaysInRange(Habit habit, DateTime from, DateTime to) {
    var count = 0;
    var day = AppDateUtils.normalize(from);
    final end = AppDateUtils.normalize(to);

    while (!day.isAfter(end)) {
      if (habit.isScheduledOn(day)) count++;
      day = AppDateUtils.addDays(day, 1);
    }

    return count;
  }

  static double completionRate(
    Habit habit,
    Set<String> completions,
    DateTime today, {
    int windowDays = 30,
  }) {
    final end = AppDateUtils.addDays(AppDateUtils.normalize(today), -1);
    final windowStart = AppDateUtils.addDays(end, -(windowDays - 1));
    final from = windowStart.isBefore(habit.createdDate)
        ? habit.createdDate
        : windowStart;

    final scheduled = scheduledDaysInRange(habit, from, end);
    if (scheduled == 0) return 0;

    final completed = completionsInRange(habit, completions, from, end);
    return completed / scheduled;
  }
}
