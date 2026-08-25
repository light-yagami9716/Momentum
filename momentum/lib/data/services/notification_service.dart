import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

abstract class NotificationScheduler {
  Future<void> initialize();
  Future<void> scheduleHabitReminder(Habit habit);
  Future<void> cancelHabitReminder(String habitId);
  Future<void> cancelAll();
}

class NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleHabitReminder(Habit habit) async {}

  @override
  Future<void> cancelHabitReminder(String habitId) async {}

  @override
  Future<void> cancelAll() async {}
}

class LocalNotificationScheduler implements NotificationScheduler {
  static const _channelId = 'momentum.reminders';
  static const _channelName = 'Habit reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  @override
  Future<void> initialize() async {
    if (kIsWeb || _ready) return;

    tzdata.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    _ready = true;
  }

  @override
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (kIsWeb || !_ready) return;

    final minutes = habit.reminderMinutes;
    if (minutes == null || habit.archived) {
      await cancelHabitReminder(habit.id);
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily nudges for your habits',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: _idFor(habit.id),
      title: habit.name,
      body: 'Time for ${habit.name}. Keep the streak alive.',
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelHabitReminder(String habitId) async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancel(id: _idFor(habitId));
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancelAll();
  }

  int _idFor(String habitId) {
    return habitId.hashCode & 0x7fffffff;
  }
}
