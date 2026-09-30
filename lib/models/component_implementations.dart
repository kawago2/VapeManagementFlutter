import 'package:flutter/material.dart';
import 'component_health.dart';
import 'vape_component.dart';

class CottonComponent extends VapeComponent {
  CottonComponent({
    DateTime? lastServicedDate,
    super.maxLifespanDays = 4,
  }) : super(
          id: 'cotton',
          name: 'Kapas (Cotton)',
          description: 'Optimalisasi rasa & serapan liquid',
          icon: Icons.water_drop_rounded,
          canQuickReset: true,
          minLifespan: 1,
          maxLifespan: 30,
          lastServicedDate: lastServicedDate ?? DateTime.now(),
        );

  @override
  ComponentHealth calculateHealth() {
    final used = daysUsed;
    HealthStatus status;
    String statusText;

    if (used >= maxLifespanDays) {
      status = HealthStatus.danger;
      statusText = 'Wajib Ganti Sekarang';
    } else if (used >= (maxLifespanDays * 0.7).floor()) {
      status = HealthStatus.warning;
      statusText = 'Mulai Menurun';
    } else {
      status = HealthStatus.good;
      statusText = 'Masih Prima & Segar';
    }

    return ComponentHealth(
      daysUsed: used,
      maxDays: maxLifespanDays,
      ratio: ratio,
      status: status,
      statusText: statusText,
    );
  }
}

class CoilComponent extends VapeComponent {
  CoilComponent({
    DateTime? lastServicedDate,
    super.maxLifespanDays = 14,
  }) : super(
          id: 'coil',
          name: 'Koil (Coil / Cartridge)',
          description: 'Kesehatan kawat pemanas & cita rasa',
          icon: Icons.electric_bolt_rounded,
          canQuickReset: true,
          minLifespan: 3,
          maxLifespan: 60,
          lastServicedDate: lastServicedDate ?? DateTime.now(),
        );

  @override
  ComponentHealth calculateHealth() {
    final used = daysUsed;
    HealthStatus status;
    String statusText;

    if (used >= maxLifespanDays) {
      status = HealthStatus.danger;
      statusText = 'Rasa Gosong / Overdue';
    } else if (used >= (maxLifespanDays * 0.75).floor()) {
      status = HealthStatus.warning;
      statusText = 'Mulai Keruh / Perlu Cek';
    } else {
      status = HealthStatus.good;
      statusText = 'Rasa & Cloud Optimal';
    }

    return ComponentHealth(
      daysUsed: used,
      maxDays: maxLifespanDays,
      ratio: ratio,
      status: status,
      statusText: statusText,
    );
  }
}

class BatteryComponent extends VapeComponent {
  BatteryComponent({
    DateTime? lastServicedDate,
    super.maxLifespanDays = 365,
  }) : super(
          id: 'battery',
          name: 'Baterai (Battery Cell)',
          description: 'Siklus usia sel baterai eksternal/internal',
          icon: Icons.battery_charging_full_rounded,
          canQuickReset: false,
          minLifespan: 60,
          maxLifespan: 730,
          lastServicedDate: lastServicedDate ?? DateTime.now(),
        );

  @override
  ComponentHealth calculateHealth() {
    final used = daysUsed;
    HealthStatus status;
    String statusText;

    if (used >= maxLifespanDays) {
      status = HealthStatus.danger;
      statusText = 'Lewat Siklus Aman';
    } else if (used >= (maxLifespanDays * 0.85).floor()) {
      status = HealthStatus.warning;
      statusText = 'Kapasitas Menurun';
    } else {
      status = HealthStatus.good;
      statusText = 'Performa Sel Prima';
    }

    return ComponentHealth(
      daysUsed: used,
      maxDays: maxLifespanDays,
      ratio: ratio,
      status: status,
      statusText: statusText,
    );
  }
}
