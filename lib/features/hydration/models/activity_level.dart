enum ActivityLevel {
  sedentary('sedentary', 'Sedentary', 1.1),
  light('light', 'Light', 1.2),
  moderate('moderate', 'Moderate', 1.4),
  heavy('heavy', 'Heavy', 1.6),
  athlete('athlete', 'Athlete', 1.8);

  const ActivityLevel(this.id, this.label, this.coefficient);

  final String id;
  final String label;
  final double coefficient;

  static ActivityLevel fromId(String id) {
    return ActivityLevel.values.firstWhere(
      (level) => level.id == id,
      orElse: () => ActivityLevel.moderate,
    );
  }
}
