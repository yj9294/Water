import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/storage/app_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/activity_level.dart';
import '../models/daily_hydration_summary.dart';
import '../models/hydration_record.dart';

class HydrationProvider extends ChangeNotifier {
  HydrationProvider(this._storage) {
    _load();
  }

  final AppStorage _storage;

  double _weightKg = 65;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  List<int> _quickAmounts = const [150, 250, 500];
  List<HydrationRecord> _records = [];
  int _todayConsumedMl = 0;
  HydrationRecord? _latestTodayRecord;
  List<DailyHydrationSummary> _historicalSummaries = const [];
  List<double> _weekProgress = const [0, 0, 0, 0, 0, 0, 0];

  double get weightKg => _weightKg;
  ActivityLevel get activityLevel => _activityLevel;
  List<int> get quickAmounts => List.unmodifiable(_quickAmounts);
  List<HydrationRecord> get records => List.unmodifiable(_records);

  int get dailyTargetMl =>
      (35 * _weightKg * _activityLevel.coefficient).round();

  String get todayKey => DateFormatter.ymd(DateTime.now());

  int get todayConsumedMl => _todayConsumedMl;

  double get todayProgress {
    if (dailyTargetMl <= 0) return 0;
    return todayConsumedMl / dailyTargetMl;
  }

  DailyHydrationSummary get todaySummary => DailyHydrationSummary(
    dateKey: todayKey,
    weightKg: _weightKg,
    targetMl: dailyTargetMl,
    consumedMl: todayConsumedMl,
  );

  HydrationRecord? get latestTodayRecord => _latestTodayRecord;

  List<DailyHydrationSummary> get historicalSummaries =>
      List.unmodifiable(_historicalSummaries);

  List<double> get weekProgress => List.unmodifiable(_weekProgress);

  void _recalculateDerivedState() {
    _todayConsumedMl = _records
        .where((record) => record.dateKey == todayKey)
        .fold(0, (sum, record) => sum + record.amountMl);

    final todayRecords =
        _records.where((record) => record.dateKey == todayKey).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _latestTodayRecord = todayRecords.isEmpty ? null : todayRecords.first;

    final grouped = <String, List<HydrationRecord>>{};
    for (final record in _records) {
      grouped.putIfAbsent(record.dateKey, () => []).add(record);
    }

    _historicalSummaries = grouped.entries.map((entry) {
      final sorted = [...entry.value]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = sorted.first;
      final consumed = sorted.fold<int>(
        0,
        (sum, record) => sum + record.amountMl,
      );
      return DailyHydrationSummary(
        dateKey: entry.key,
        weightKg: latest.weightKg,
        targetMl: latest.targetMl,
        consumedMl: consumed,
      );
    }).toList()..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    _weekProgress = List.generate(7, (index) {
      final key = DateFormatter.ymd(start.add(Duration(days: index)));
      final consumed = _records
          .where((record) => record.dateKey == key)
          .fold<int>(0, (sum, record) => sum + record.amountMl);
      return min(1, consumed / max(1, dailyTargetMl));
    });
  }

  Future<void> addWater(int amountMl) async {
    if (amountMl < 50 || amountMl > 2000) return;
    final record = HydrationRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: amountMl,
      createdAt: DateTime.now(),
      weightKg: _weightKg,
      targetMl: dailyTargetMl,
    );
    _records = [..._records, record];
    _recalculateDerivedState();
    notifyListeners();
    await _saveRecords();
  }

  Future<void> updateWeight(double value) async {
    _weightKg = value.clamp(20, 300);
    _recalculateDerivedState();
    await _storage.setWeightKg(_weightKg);
    notifyListeners();
  }

  Future<void> updateActivityLevel(ActivityLevel level) async {
    _activityLevel = level;
    _recalculateDerivedState();
    await _storage.setActivityLevel(level.id);
    notifyListeners();
  }

  Future<void> updateQuickAmount(int index, int value) async {
    if (index < 0 || index >= _quickAmounts.length) return;
    final next = [..._quickAmounts];
    next[index] = value.clamp(50, 2000);
    _quickAmounts = next;
    await _storage.setQuickAmounts(_quickAmounts);
    notifyListeners();
  }

  Future<void> saveTargetSettings() async {
    await Future.wait([
      _storage.setWeightKg(_weightKg),
      _storage.setActivityLevel(_activityLevel.id),
      _storage.setQuickAmounts(_quickAmounts),
    ]);
    notifyListeners();
  }

  void _load() {
    _weightKg = _storage.getWeightKg();
    _activityLevel = ActivityLevel.fromId(_storage.getActivityLevel());
    _quickAmounts = _storage.getQuickAmounts();
    _records = _storage.getRecords().map(HydrationRecord.fromJson).toList();
    _recalculateDerivedState();
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    await _storage.setRecords(
      _records.map((record) => record.toJson()).toList(),
    );
  }
}
