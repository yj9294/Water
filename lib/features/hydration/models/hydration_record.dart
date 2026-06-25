import '../../../core/utils/date_formatter.dart';

class HydrationRecord {
  const HydrationRecord({
    required this.id,
    required this.amountMl,
    required this.createdAt,
    required this.weightKg,
    required this.targetMl,
  });

  final String id;
  final int amountMl;
  final DateTime createdAt;
  final double weightKg;
  final int targetMl;

  String get dateKey => DateFormatter.ymd(createdAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMl': amountMl,
    'createdAt': createdAt.toIso8601String(),
    'weightKg': weightKg,
    'targetMl': targetMl,
  };

  factory HydrationRecord.fromJson(Map<String, dynamic> json) {
    return HydrationRecord(
      id: json['id'] as String,
      amountMl: json['amountMl'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      targetMl: json['targetMl'] as int,
    );
  }
}
