import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _weightKey = 'hydration.weight_kg';
  static const _activityKey = 'hydration.activity_level';
  static const _quickAmountsKey = 'hydration.quick_amounts_ml';
  static const _recordsKey = 'hydration.records';
  static const _healthKey = 'hydration.health_enabled';

  double getWeightKg() => _prefs.getDouble(_weightKey) ?? 65;

  Future<void> setWeightKg(double value) => _prefs.setDouble(_weightKey, value);

  String getActivityLevel() => _prefs.getString(_activityKey) ?? 'moderate';

  Future<void> setActivityLevel(String value) =>
      _prefs.setString(_activityKey, value);

  List<int> getQuickAmounts() {
    final encoded = _prefs.getString(_quickAmountsKey);
    if (encoded == null) return const [150, 250, 500];
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded.cast<int>();
  }

  Future<void> setQuickAmounts(List<int> values) =>
      _prefs.setString(_quickAmountsKey, jsonEncode(values));

  bool getHealthEnabled() => _prefs.getBool(_healthKey) ?? true;

  Future<void> setHealthEnabled(bool value) =>
      _prefs.setBool(_healthKey, value);

  List<Map<String, dynamic>> getRecords() {
    final encoded = _prefs.getString(_recordsKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> setRecords(List<Map<String, dynamic>> records) =>
      _prefs.setString(_recordsKey, jsonEncode(records));
}
