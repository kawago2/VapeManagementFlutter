import 'package:flutter/material.dart';
import 'component_health.dart';

abstract class VapeComponent {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool canQuickReset;
  final int minLifespan;
  final int maxLifespan;

  DateTime lastServicedDate;
  int maxLifespanDays;

  VapeComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.canQuickReset = true,
    this.minLifespan = 1,
    this.maxLifespan = 60,
    required this.lastServicedDate,
    required this.maxLifespanDays,
  });

  int get daysUsed {
    final now = DateTime.now();
    final fromDate = DateTime(lastServicedDate.year, lastServicedDate.month, lastServicedDate.day);
    final toDate = DateTime(now.year, now.month, now.day);
    final diff = toDate.difference(fromDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get ratio {
    final limit = maxLifespanDays <= 0 ? 1 : maxLifespanDays;
    return (daysUsed / limit).clamp(0.0, 1.0);
  }

  void markServicedToday() {
    lastServicedDate = DateTime.now();
  }

  ComponentHealth calculateHealth();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastServicedDate': lastServicedDate.toIso8601String(),
      'maxLifespanDays': maxLifespanDays,
    };
  }
}
