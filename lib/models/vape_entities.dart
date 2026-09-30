import 'package:uuid/uuid.dart';
import 'health_calculator.dart';

extension DateTimeFormatExtension on DateTime {
  /// Formats date to simple 'YYYY-MM-DD' (e.g. 2026-09-30)
  String toDateString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

DateTime parseFlexibleDate(dynamic value) {
  if (value == null) return DateTime.now();
  final str = value.toString().trim();
  if (str.isEmpty) return DateTime.now();
  final parsed = DateTime.tryParse(str);
  if (parsed != null) {
    return DateTime(parsed.toLocal().year, parsed.toLocal().month, parsed.toLocal().day);
  }
  return DateTime.now();
}

// MARK: - 1. Liquid Item
class LiquidItem implements HealthTrackable {
  final String id;
  String name;
  DateTime openedDate;
  int maxDays;
  String nicMg;
  String volumeMl;

  LiquidItem({
    String? id,
    this.name = 'Butterbread Peanut Butter',
    DateTime? openedDate,
    this.maxDays = 90,
    this.nicMg = '3mg',
    this.volumeMl = '60ml',
  })  : id = id ?? const Uuid().v4(),
        openedDate = openedDate ?? DateTime.now();

  @override
  int get daysPassed => HealthCalculator.shared.calculateDaysPassed(openedDate);

  @override
  ComponentHealthStatus get healthStatus =>
      HealthCalculator.shared.calculateHealthStatus(
        startDate: openedDate,
        maxDays: maxDays,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'openedDate': openedDate.toDateString(),
      'maxDays': maxDays,
      'nicMg': nicMg,
      'volumeMl': volumeMl,
    };
  }

  factory LiquidItem.fromMap(Map<String, dynamic> map) {
    return LiquidItem(
      id: map['id'],
      name: map['name'] ?? 'Butterbread Peanut Butter',
      openedDate: parseFlexibleDate(map['openedDate']),
      maxDays: map['maxDays'] ?? 90,
      nicMg: map['nicMg'] ?? '3mg',
      volumeMl: map['volumeMl'] ?? '60ml',
    );
  }
}

// MARK: - 2. Battery Item
class BatteryItem implements HealthTrackable {
  final String id;
  String code;
  String brandAndType;
  DateTime purchasedDate;
  int maxDays;
  String notes;

  BatteryItem({
    String? id,
    this.code = 'BAT-01',
    this.brandAndType = 'PVR Battery 18650',
    DateTime? purchasedDate,
    this.maxDays = 365,
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        purchasedDate = purchasedDate ?? DateTime.now();

  @override
  int get daysPassed =>
      HealthCalculator.shared.calculateDaysPassed(purchasedDate);

  @override
  ComponentHealthStatus get healthStatus =>
      HealthCalculator.shared.calculateHealthStatus(
        startDate: purchasedDate,
        maxDays: maxDays,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'brandAndType': brandAndType,
      'purchasedDate': purchasedDate.toDateString(),
      'maxDays': maxDays,
      'notes': notes,
    };
  }

  factory BatteryItem.fromMap(Map<String, dynamic> map) {
    return BatteryItem(
      id: map['id'],
      code: map['code'] ?? 'BAT-01',
      brandAndType: map['brandAndType'] ?? 'PVR Battery 18650',
      purchasedDate: parseFlexibleDate(map['purchasedDate']),
      maxDays: map['maxDays'] ?? 365,
      notes: map['notes'] ?? '',
    );
  }
}

// MARK: - 3. Tank Setup Entity
class TankSetup {
  final String id;
  String tankName;
  String wireType;
  DateTime coilInstalledDate;
  DateTime cottonReplacedDate;
  String activeLiquidName;

  int coilMaxDays;
  int cottonMaxDays;

  TankSetup({
    String? id,
    this.tankName = 'Tank TRML',
    this.wireType = 'Coil Teko Baby Alien (0.35Ω)',
    DateTime? coilInstalledDate,
    DateTime? cottonReplacedDate,
    this.activeLiquidName = 'Butterbread Peanut Butter',
    this.coilMaxDays = 14,
    this.cottonMaxDays = 4,
  })  : id = id ?? const Uuid().v4(),
        coilInstalledDate = coilInstalledDate ?? DateTime.now(),
        cottonReplacedDate = cottonReplacedDate ?? DateTime.now();

  int get coilDaysPassed =>
      HealthCalculator.shared.calculateDaysPassed(coilInstalledDate);

  int get cottonDaysPassed =>
      HealthCalculator.shared.calculateDaysPassed(cottonReplacedDate);

  ComponentHealthStatus get coilHealthStatus =>
      HealthCalculator.shared.calculateHealthStatus(
        startDate: coilInstalledDate,
        maxDays: coilMaxDays,
      );

  ComponentHealthStatus get cottonHealthStatus =>
      HealthCalculator.shared.calculateHealthStatus(
        startDate: cottonReplacedDate,
        maxDays: cottonMaxDays,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tankName': tankName,
      'wireType': wireType,
      'coilInstalledDate': coilInstalledDate.toDateString(),
      'cottonReplacedDate': cottonReplacedDate.toDateString(),
      'activeLiquidName': activeLiquidName,
      'coilMaxDays': coilMaxDays,
      'cottonMaxDays': cottonMaxDays,
    };
  }

  factory TankSetup.fromMap(Map<String, dynamic> map) {
    return TankSetup(
      id: map['id'],
      tankName: map['tankName'] ?? 'Tank TRML',
      wireType: map['wireType'] ?? 'Coil Teko Baby Alien (0.35Ω)',
      coilInstalledDate: parseFlexibleDate(map['coilInstalledDate']),
      cottonReplacedDate: parseFlexibleDate(map['cottonReplacedDate']),
      activeLiquidName: map['activeLiquidName'] ?? 'Butterbread Peanut Butter',
      coilMaxDays: map['coilMaxDays'] ?? 14,
      cottonMaxDays: map['cottonMaxDays'] ?? 4,
    );
  }
}
