import 'dart:convert';
import 'vape_component.dart';
import 'component_implementations.dart';

class VapeSetup {
  String deviceName;
  final List<VapeComponent> components;

  VapeSetup({
    this.deviceName = 'Daily Mod',
    List<VapeComponent>? components,
  }) : components = components ??
            [
              CottonComponent(),
              CoilComponent(),
              BatteryComponent(),
            ];

  T? getComponent<T extends VapeComponent>() {
    for (final c in components) {
      if (c is T) return c;
    }
    return null;
  }

  VapeComponent? findById(String id) {
    for (final c in components) {
      if (c.id == id) return c;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'components': components.map((c) => c.toMap()).toList(),
    };
  }

  factory VapeSetup.fromMap(Map<String, dynamic> map) {
    final deviceName = map['deviceName'] ?? 'Daily Mod';
    final rawComponents = map['components'] as List<dynamic>?;

    final cotton = CottonComponent();
    final coil = CoilComponent();
    final battery = BatteryComponent();

    if (rawComponents != null) {
      for (final item in rawComponents) {
        if (item is Map<String, dynamic>) {
          final id = item['id'];
          final dateStr = item['lastServicedDate'];
          final maxDays = item['maxLifespanDays'] as int?;
          final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

          if (id == 'cotton' && date != null) {
            cotton.lastServicedDate = date;
            if (maxDays != null) cotton.maxLifespanDays = maxDays;
          } else if (id == 'coil' && date != null) {
            coil.lastServicedDate = date;
            if (maxDays != null) coil.maxLifespanDays = maxDays;
          } else if (id == 'battery' && date != null) {
            battery.lastServicedDate = date;
            if (maxDays != null) battery.maxLifespanDays = maxDays;
          }
        }
      }
    } else {
      // Backward compatibility for legacy format
      if (map['cottonLastReplaced'] != null) {
        cotton.lastServicedDate = DateTime.tryParse(map['cottonLastReplaced']) ?? DateTime.now();
      }
      if (map['cottonMaxDays'] != null) cotton.maxLifespanDays = map['cottonMaxDays'];

      if (map['coilLastReplaced'] != null) {
        coil.lastServicedDate = DateTime.tryParse(map['coilLastReplaced']) ?? DateTime.now();
      }
      if (map['coilMaxDays'] != null) coil.maxLifespanDays = map['coilMaxDays'];

      if (map['batteryPurchased'] != null) {
        battery.lastServicedDate = DateTime.tryParse(map['batteryPurchased']) ?? DateTime.now();
      }
      if (map['batteryMaxDays'] != null) battery.maxLifespanDays = map['batteryMaxDays'];
    }

    return VapeSetup(
      deviceName: deviceName,
      components: [cotton, coil, battery],
    );
  }

  String toJson() => json.encode(toMap());

  factory VapeSetup.fromJson(String source) =>
      VapeSetup.fromMap(json.decode(source) as Map<String, dynamic>);
}
