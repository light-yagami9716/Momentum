import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static String dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseKey(String key) {
    return DateTime.parse(key);
  }

  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime today() => normalize(DateTime.now());

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime addDays(DateTime date, int days) {
    return DateTime(date.year, date.month, date.day + days);
  }

  static DateTime firstDayOfWeek(DateTime date, {required bool startsMonday}) {
    final shift = startsMonday ? date.weekday - 1 : date.weekday % 7;
    return addDays(normalize(date), -shift);
  }

  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static String weekdayLabel(int weekday, {required bool short}) {
    const long = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const shortLabels = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return short ? shortLabels[weekday] : long[weekday];
  }

  static String formatTime(int minutesOfDay, {required bool use24Hour}) {
    final hour = minutesOfDay ~/ 60;
    final minute = minutesOfDay % 60;
    if (use24Hour) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    final period = hour >= 12 ? 'PM' : 'AM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display:${minute.toString().padLeft(2, '0')} $period';
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, d MMMM').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }
}
