import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _weightKey = 'hydration.weight_kg';
  static const _activityKey = 'hydration.activity_level';
  static const _quickAmountsKey = 'hydration.quick_amounts_ml';
  static const _recordsKey = 'hydration.records';

  double getWeightKg() => _prefs.getDouble(_weightKey) ?? 65;

  Future<void> setWeightKg(double value) => _prefs.setDouble(_weightKey, value);

  String getActivityLevel() => _prefs.getString(_activityKey) ?? 'moderate';

  Future<void> setActivityLevel(String value) =>
      _prefs.setString(_activityKey, value);

  List<int> getQuickAmounts() {
    final encoded = _prefs.getString(_quickAmountsKey);
    if (encoded == null) return const [150, 250, 500];
    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      final values = decoded
          .map((value) => (value as num).round().clamp(50, 2000))
          .toList();
      return values.length == 3 ? values : const [150, 250, 500];
    } catch (_) {
      return const [150, 250, 500];
    }
  }

  Future<void> setQuickAmounts(List<int> values) =>
      _prefs.setString(_quickAmountsKey, jsonEncode(values));

  List<Map<String, dynamic>> getRecords() {
    final encoded = _prefs.getString(_recordsKey);
    if (encoded == null) return const [];
    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> setRecords(List<Map<String, dynamic>> records) =>
      _prefs.setString(_recordsKey, jsonEncode(records));
}
