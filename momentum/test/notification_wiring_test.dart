import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/data/models/habit.dart';
import 'package:momentum/data/services/notification_service.dart';
import 'package:momentum/data/services/persistence_service.dart';
import 'package:momentum/state/habits_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingScheduler implements NotificationScheduler {
  final scheduled = <String>[];
  final cancelled = <String>[];
  var cancelAllCalls = 0;
  var initializeCalls = 0;

  @override
  Future<void> initialize() async => initializeCalls++;

  @override
  Future<void> scheduleHabitReminder(Habit habit) async =>
      scheduled.add(habit.id);

  @override
  Future<void> cancelHabitReminder(String habitId) async =>
      cancelled.add(habitId);

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

void main() {
  late RecordingScheduler scheduler;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    scheduler = RecordingScheduler();
  });

  Future<HabitsProvider> buildProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return HabitsProvider(PersistenceService(prefs), scheduler);
  }

  test('creating a habit with a reminder schedules its notification', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
      reminderMinutes: 480,
    );

    expect(scheduler.scheduled, [provider.habits.first.id]);
  });

  test(
    'creating a habit without a reminder still syncs the scheduler',
    () async {
      final provider = await buildProvider();

      await provider.addHabit(
        name: 'Read',
        iconKey: 'book',
        colorIndex: 1,
        frequency: HabitFrequency.daily,
        days: const [],
      );

      expect(scheduler.scheduled, [provider.habits.first.id]);
    },
  );

  test('archiving and deleting cancel or reschedule correctly', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    final habit = provider.habits.first;

    await provider.deleteHabit(habit.id);
    expect(scheduler.cancelled, [habit.id]);
  });

  test('reset clears every scheduled notification', () async {
    final provider = await buildProvider();

    await provider.addHabit(
      name: 'Read',
      iconKey: 'book',
      colorIndex: 1,
      frequency: HabitFrequency.daily,
      days: const [],
    );
    await provider.resetAll();

    expect(scheduler.cancelAllCalls, 1);
  });

  test('loading persisted habits re-registers every reminder', () async {
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);

    await persistence.writeHabits([
      {
        'id': 'a',
        'name': 'One',
        'iconKey': 'book',
        'colorIndex': 0,
        'frequency': 'daily',
        'days': <int>[],
        'createdDate': '2026-08-01',
        'reminderMinutes': 480,
        'archived': false,
      },
      {
        'id': 'b',
        'name': 'Two',
        'iconKey': 'call',
        'colorIndex': 1,
        'frequency': 'daily',
        'days': <int>[],
        'createdDate': '2026-08-02',
        'reminderMinutes': null,
        'archived': false,
      },
    ]);

    final provider = HabitsProvider(persistence, scheduler);
    await provider.bootstrap();

    expect(scheduler.initializeCalls, 1);
    expect(scheduler.scheduled, containsAll(['a', 'b']));
  });
}
