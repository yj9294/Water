import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water/core/storage/app_storage.dart';
import 'package:water/features/hydration/models/activity_level.dart';
import 'package:water/features/hydration/providers/hydration_provider.dart';

void main() {
  Future<HydrationProvider> buildProvider({
    Map<String, Object> initialValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final prefs = await SharedPreferences.getInstance();
    return HydrationProvider(AppStorage(prefs));
  }

  test('starts from stored profile without demo hydration records', () async {
    final provider = await buildProvider();

    expect(provider.weightKg, 65);
    expect(provider.activityLevel, ActivityLevel.moderate);
    expect(provider.dailyTargetMl, (35 * 65 * 1.4).round());
    expect(provider.records, isEmpty);
    expect(provider.todayConsumedMl, 0);
  });

  test('adds water records and persists them', () async {
    final provider = await buildProvider();

    await provider.addWater(250);
    await provider.addWater(500);

    expect(provider.todayConsumedMl, 750);
    expect(provider.latestTodayRecord?.amountMl, 500);
    expect(provider.weekProgress.any((value) => value > 0), isTrue);
    expect(provider.historicalSummaries.first.consumedMl, 750);

    final reloaded = await buildProvider(
      initialValues: {
        'hydration.records': '''
[{"id":"1","amountMl":750,"createdAt":"2026-06-26T10:00:00.000","weightKg":65,"targetMl":3185}]
''',
      },
    );
    expect(reloaded.records.single.amountMl, 750);
  });

  test('ignores custom water amounts outside supported range', () async {
    final provider = await buildProvider();

    await provider.addWater(20);
    await provider.addWater(2500);

    expect(provider.records, isEmpty);
    expect(provider.todayConsumedMl, 0);
  });

  test('updates target settings and saves profile values', () async {
    final provider = await buildProvider();

    await provider.updateWeight(70);
    await provider.updateActivityLevel(ActivityLevel.heavy);
    await provider.updateQuickAmount(1, 350);
    await provider.saveTargetSettings();

    expect(provider.dailyTargetMl, (35 * 70 * 1.6).round());
    expect(provider.quickAmounts, [150, 350, 500]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('hydration.weight_kg'), 70);
    expect(prefs.getString('hydration.activity_level'), 'heavy');
    expect(prefs.getString('hydration.quick_amounts_ml'), '[150,350,500]');
  });

  test('falls back safely when persisted values are malformed', () async {
    final provider = await buildProvider(
      initialValues: {
        'hydration.quick_amounts_ml': 'not-json',
        'hydration.records': '{"bad":true}',
      },
    );

    expect(provider.quickAmounts, [150, 250, 500]);
    expect(provider.records, isEmpty);
  });

  test('clamps custom quick amount settings to supported range', () async {
    final provider = await buildProvider();

    await provider.updateQuickAmount(0, 10);
    await provider.updateQuickAmount(1, 2500);

    expect(provider.quickAmounts, [50, 2000, 500]);
  });
}
