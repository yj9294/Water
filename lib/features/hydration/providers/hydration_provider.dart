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
  bool _healthEnabled = true;

  double get weightKg => _weightKg;
  ActivityLevel get activityLevel => _activityLevel;
  List<int> get quickAmounts => List.unmodifiable(_quickAmounts);
  bool get healthEnabled => _healthEnabled;
  List<HydrationRecord> get records => List.unmodifiable(_records);

  int get dailyTargetMl =>
      (35 * _weightKg * _activityLevel.coefficient).round();

  String get todayKey => DateFormatter.ymd(DateTime.now());

  int get todayConsumedMl => _records
      .where((record) => record.dateKey == todayKey)
      .fold(0, (sum, record) => sum + record.amountMl);

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

  List<DailyHydrationSummary> get historicalSummaries {
    final grouped = <String, List<HydrationRecord>>{};
    for (final record in _records) {
      grouped.putIfAbsent(record.dateKey, () => []).add(record);
    }

    final summaries = grouped.entries.map((entry) {
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

    return summaries;
  }

  List<double> get weekProgress {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final key = DateFormatter.ymd(start.add(Duration(days: index)));
      final consumed = _records
          .where((record) => record.dateKey == key)
          .fold<int>(0, (sum, record) => sum + record.amountMl);
      return min(1, consumed / max(1, dailyTargetMl));
    });
  }

  Future<void> addWater(int amountMl) async {
    final record = HydrationRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: amountMl,
      createdAt: DateTime.now(),
      weightKg: _weightKg,
      targetMl: dailyTargetMl,
    );
    _records = [..._records, record];
    await _saveRecords();
    notifyListeners();
  }

  Future<void> updateWeight(double value) async {
    _weightKg = value.clamp(20, 300);
    await _storage.setWeightKg(_weightKg);
    notifyListeners();
  }

  Future<void> updateActivityLevel(ActivityLevel level) async {
    _activityLevel = level;
    await _storage.setActivityLevel(level.id);
    notifyListeners();
  }

  Future<void> toggleHealthEnabled(bool enabled) async {
    _healthEnabled = enabled;
    await _storage.setHealthEnabled(enabled);
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

  void _load() {
    _weightKg = _storage.getWeightKg();
    _activityLevel = ActivityLevel.fromId(_storage.getActivityLevel());
    _quickAmounts = _storage.getQuickAmounts();
    _healthEnabled = _storage.getHealthEnabled();
    _records = _storage.getRecords().map(HydrationRecord.fromJson).toList();
    _seedDemoDataIfNeeded();
    notifyListeners();
  }

  void _seedDemoDataIfNeeded() {
    if (_records.isNotEmpty) return;
    final now = DateTime.now();
    final target = dailyTargetMl;
    _records = [
      HydrationRecord(
        id: 'seed-1',
        amountMl: 500,
        createdAt: DateTime(now.year, now.month, now.day, 9, 10),
        weightKg: _weightKg,
        targetMl: target,
      ),
      HydrationRecord(
        id: 'seed-2',
        amountMl: 250,
        createdAt: DateTime(now.year, now.month, now.day, 12, 20),
        weightKg: _weightKg,
        targetMl: target,
      ),
      HydrationRecord(
        id: 'seed-3',
        amountMl: 300,
        createdAt: DateTime(now.year, now.month, now.day, 14, 30),
        weightKg: _weightKg,
        targetMl: target,
      ),
      HydrationRecord(
        id: 'seed-4',
        amountMl: max(0, target - 445),
        createdAt: now.subtract(const Duration(days: 1)),
        weightKg: _weightKg,
        targetMl: target,
      ),
      HydrationRecord(
        id: 'seed-5',
        amountMl: target + 75,
        createdAt: now.subtract(const Duration(days: 2)),
        weightKg: _weightKg + 1,
        targetMl: target,
      ),
    ];
  }

  Future<void> _saveRecords() async {
    await _storage.setRecords(
      _records.map((record) => record.toJson()).toList(),
    );
  }
}
