enum HealthStatus {
  good,
  warning,
  danger,
}

class ComponentHealth {
  final int daysUsed;
  final int maxDays;
  final double ratio;
  final HealthStatus status;
  final String statusText;

  const ComponentHealth({
    required this.daysUsed,
    required this.maxDays,
    required this.ratio,
    required this.status,
    required this.statusText,
  });
}
