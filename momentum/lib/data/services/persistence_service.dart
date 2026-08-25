import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  PersistenceService(this._prefs);

  final SharedPreferences _prefs;

  static const _habitsKey = 'momentum.habits';
  static const _completionsKey = 'momentum.completions';
  static const _themeModeKey = 'momentum.themeMode';
  static const _onboardedKey = 'momentum.onboarded';
  static const _use24HourKey = 'momentum.use24Hour';
  static const _weekStartsMondayKey = 'momentum.weekStartsMonday';

  List<Map<String, dynamic>> readHabits() {
    final raw = _prefs.getString(_habitsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> writeHabits(List<Map<String, dynamic>> habits) {
    return _prefs.setString(_habitsKey, jsonEncode(habits));
  }

  Map<String, dynamic> readCompletions() {
    final raw = _prefs.getString(_completionsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value is List ? value : []),
    );
  }

  Future<void> writeCompletions(Map<String, dynamic> completions) {
    return _prefs.setString(_completionsKey, jsonEncode(completions));
  }

  String? readThemeMode() => _prefs.getString(_themeModeKey);

  Future<void> writeThemeMode(String mode) {
    return _prefs.setString(_themeModeKey, mode);
  }

  bool readOnboarded() => _prefs.getBool(_onboardedKey) ?? false;

  Future<void> writeOnboarded(bool value) {
    return _prefs.setBool(_onboardedKey, value);
  }

  bool readUse24Hour() => _prefs.getBool(_use24HourKey) ?? false;

  Future<void> writeUse24Hour(bool value) {
    return _prefs.setBool(_use24HourKey, value);
  }

  bool readWeekStartsMonday() => _prefs.getBool(_weekStartsMondayKey) ?? true;

  Future<void> writeWeekStartsMonday(bool value) {
    return _prefs.setBool(_weekStartsMondayKey, value);
  }

  Future<void> clearAll() => _prefs.clear();
}
