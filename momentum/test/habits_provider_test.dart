import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/utils/app_date_utils.dart';
import 'package:momentum/data/models/habit.dart';
import 'package:momentum/data/services/persistence_service.dart';
import 'package:momentum/state/habits_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<HabitsProvider> buildProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return HabitsProvider(PersistenceService(prefs));
  }

  test('starts empty', () async {
    final provider = await buildProvider();
    expect(provider.habits, isEmpty);
    expect(provider.todayScheduledCount, 0);
    expect(provider.todayProgress, 0);
  });

  test('adds habits and reports today scheduling', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Drink water',
      iconKey: 'water_drop',
      colorIndex: 0,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    await provider.addHabit(
      name: 'Gym',
      iconKey: 'fitness',
      colorIndex: 2,
      frequency: HabitFrequency.specificDays,
      days: const [1, 3, 5],
    );

    expect(provider.habits.length, 2);
    expect(
      provider.todayScheduledCount,
      provider.habits.every(
            (habit) => habit.isScheduledOn(AppDateUtils.today()),
          )
          ? 2
          : 1,
    );
  });

  test(
    'rejects nothing but detects duplicate names case-insensitively',
    () async {
      final provider = await buildProvider();

      await provider.addHabit(
        name: 'Read',
        iconKey: 'book',
        colorIndex: 1,
        frequency: HabitFrequency.daily,
        days: const [],
      );

      expect(provider.isNameTaken('read'), isTrue);
      expect(provider.isNameTaken('READ '), isTrue);
      expect(
        provider.isNameTaken('read', exceptId: provider.habits.first.id),
        isFalse,
      );
      expect(provider.isNameTaken('Meditate'), isFalse);
    },
  );

  test('check-in toggles update completion state and totals', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;

    expect(provider.todayCompletedCount, 0);

    await provider.toggleCheckIn(habit.id, AppDateUtils.today());
    expect(provider.isCompleted(habit.id, AppDateUtils.today()), isTrue);
    expect(provider.todayCompletedCount, 1);
    expect(provider.todayProgress, 1);
    expect(provider.totalCompletionsAllTime, 1);
    expect(provider.currentStreakOf(habit), 1);

    await provider.toggleCheckIn(habit.id, AppDateUtils.today());
    expect(provider.isCompleted(habit.id, AppDateUtils.today()), isFalse);
    expect(provider.todayCompletedCount, 0);
    expect(provider.totalCompletionsAllTime, 0);
  });

  test('archiving hides a habit from today but keeps history', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, AppDateUtils.today());
    await provider.setArchived(habit.id, true);

    expect(provider.habits, isEmpty);
    expect(provider.archivedHabits.length, 1);
    expect(provider.todayScheduledCount, 0);
    expect(provider.totalCompletionsAllTime, 1);
  });

  test('deleting a habit removes its history', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, AppDateUtils.today());
    await provider.deleteHabit(habit.id);

    expect(provider.habits, isEmpty);
    expect(provider.totalCompletionsAllTime, 0);
  });

  test('updating a habit keeps its completions', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, AppDateUtils.today());

    await provider.updateHabit(
      habit.id,
      name: 'Read books',
      iconKey: 'book',
      colorIndex: 3,
      frequency: HabitFrequency.daily,
      days: const [],
    );

    final updated = provider.habits.first;
    expect(updated.name, 'Read books');
    expect(provider.isCompleted(updated.id, AppDateUtils.today()), isTrue);
    expect(provider.currentStreakOf(updated), 1);
  });

  test('state survives provider reconstruction from persistence', () async {
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);
    final provider = HabitsProvider(persistence);

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.specificDays,
      days: const [2, 4, 6],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, DateTime(2026, 8, 25));

    final restored = HabitsProvider(persistence);
    expect(restored.habits.length, 1);
    expect(restored.habits.first.name, 'Read');
    expect(restored.habits.first.days, const [2, 4, 6]);
    expect(restored.isCompleted(habit.id, DateTime(2026, 8, 25)), isTrue);
  });

  test('week series marks scheduled and completed days', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, AppDateUtils.today());

    final series = provider.weekSeries(AppDateUtils.today(), 7);
    expect(series.length, 7);
    expect(series.last.completed, isTrue);
    expect(series.last.scheduled, isTrue);
    expect(series.first.completed, isFalse);
  });

  test('heatmap intensity reflects the completed share', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, AppDateUtils.today());

    expect(provider.heatmapIntensity(AppDateUtils.today()), 1);
    expect(
      provider.heatmapIntensity(AppDateUtils.addDays(AppDateUtils.today(), -1)),
      0,
    );
  });

  test('best habit and attention seeker are derived correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);
    final created = AppDateUtils.addDays(AppDateUtils.today(), -10);
    final createdKey = AppDateUtils.dateKey(created);

    await persistence.writeHabits([
      {
        'id': 'strong',
        'name': 'Strong',
        'iconKey': 'fitness',
        'colorIndex': 2,
        'frequency': 'daily',
        'days': <int>[],
        'createdDate': createdKey,
        'reminderMinutes': null,
        'archived': false,
      },
      {
        'id': 'weak',
        'name': 'Weak',
        'iconKey': 'bedtime',
        'colorIndex': 3,
        'frequency': 'daily',
        'days': <int>[],
        'createdDate': createdKey,
        'reminderMinutes': null,
        'archived': false,
      },
    ]);

    final provider = HabitsProvider(persistence);
    for (var i = 1; i <= 5; i++) {
      await provider.toggleCheckIn(
        'strong',
        AppDateUtils.addDays(AppDateUtils.today(), -i),
      );
    }

    final best = provider.bestHabit;
    expect(best?.habit.name, 'Strong');
    expect(best?.currentStreak, 5);

    final attention = provider.habitNeedingAttention;
    expect(attention?.habit.name, 'Weak');
    expect(attention?.rate30d, 0);
  });

  test('export produces pretty json and reset clears everything', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;
    await provider.toggleCheckIn(habit.id, AppDateUtils.today());

    final exported = provider.exportJson();
    expect(exported, contains('"name": "Read"'));
    expect(exported, contains('exportedAt'));

    await provider.resetAll();
    expect(provider.habits, isEmpty);
    expect(provider.totalCompletionsAllTime, 0);

    final restored = await buildProvider();
    expect(restored.habits, isEmpty);
  });
}
