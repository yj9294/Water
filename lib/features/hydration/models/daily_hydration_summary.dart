class DailyHydrationSummary {
  const DailyHydrationSummary({
    required this.dateKey,
    required this.weightKg,
    required this.targetMl,
    required this.consumedMl,
  });

  final String dateKey;
  final double weightKg;
  final int targetMl;
  final int consumedMl;

  double get completionRate {
    if (targetMl <= 0) return 0;
    return consumedMl / targetMl;
  }
}
