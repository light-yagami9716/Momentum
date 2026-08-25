import 'package:flutter/foundation.dart';

import '../data/services/persistence_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._persistence) {
    _onboarded = _persistence.readOnboarded();
    _use24Hour = _persistence.readUse24Hour();
    _weekStartsMonday = _persistence.readWeekStartsMonday();
  }

  final PersistenceService _persistence;

  late bool _onboarded;
  late bool _use24Hour;
  late bool _weekStartsMonday;

  bool get onboarded => _onboarded;
  bool get use24Hour => _use24Hour;
  bool get weekStartsMonday => _weekStartsMonday;

  Future<void> completeOnboarding() async {
    if (_onboarded) return;
    _onboarded = true;
    notifyListeners();
    await _persistence.writeOnboarded(true);
  }

  Future<void> setUse24Hour(bool value) async {
    if (_use24Hour == value) return;
    _use24Hour = value;
    notifyListeners();
    await _persistence.writeUse24Hour(value);
  }

  Future<void> setWeekStartsMonday(bool value) async {
    if (_weekStartsMonday == value) return;
    _weekStartsMonday = value;
    notifyListeners();
    await _persistence.writeWeekStartsMonday(value);
  }
}
