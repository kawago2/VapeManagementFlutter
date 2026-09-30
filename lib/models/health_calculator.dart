import 'dart:math';

enum HealthLevel {
  safe,
  attention,
  overdue,
}

class ComponentHealthStatus {
  final int daysPassed;
  final int maxDays;
  final double usageRatio;

  const ComponentHealthStatus({
    required this.daysPassed,
    required this.maxDays,
    required this.usageRatio,
  });

  int get percentage => (usageRatio * 100).round();
  int get remainingDays => max(0, maxDays - daysPassed);
  bool get isOverdue => daysPassed >= maxDays;

  HealthLevel get statusLevel {
    if (usageRatio >= 1.0) {
      return HealthLevel.overdue;
    } else if (usageRatio >= 0.75) {
      return HealthLevel.attention;
    } else {
      return HealthLevel.safe;
    }
  }
}

abstract class HealthTrackable {
  int get daysPassed;
  ComponentHealthStatus get healthStatus;
}

class HealthCalculator {
  static final HealthCalculator shared = HealthCalculator();

  int calculateDaysPassed(DateTime startDate, [DateTime? referenceDate]) {
    final ref = referenceDate ?? DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(ref.year, ref.month, ref.day);
    final days = end.difference(start).inDays;
    return max(0, days);
  }

  ComponentHealthStatus calculateHealthStatus({
    required DateTime startDate,
    required int maxDays,
    DateTime? referenceDate,
  }) {
    final daysPassed = calculateDaysPassed(startDate, referenceDate);
    final validMaxDays = max(1, maxDays);
    final ratio = daysPassed / validMaxDays;
    return ComponentHealthStatus(
      daysPassed: daysPassed,
      maxDays: validMaxDays,
      usageRatio: ratio,
    );
  }
}
