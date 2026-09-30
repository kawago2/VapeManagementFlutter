import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vape_entities.dart';

abstract class IVapeDataRepository {
  Future<List<TankSetup>> fetchTanks();
  Future<List<BatteryItem>> fetchBatteries();
  Future<List<LiquidItem>> fetchLiquids();

  Future<void> replaceAllTanks(List<TankSetup> tanks);
  Future<void> replaceAllBatteries(List<BatteryItem> batteries);
  Future<void> replaceAllLiquids(List<LiquidItem> liquids);

  Future<void> upsertTank(TankSetup tank);
  Future<void> upsertBattery(BatteryItem battery);
  Future<void> upsertLiquid(LiquidItem liquid);

  Future<void> deleteTank(String id);
  Future<void> deleteBattery(String id);
  Future<void> deleteLiquid(String id);

  Future<void> clearAllLocalData();
}

class VapeRepository implements IVapeDataRepository {
  static const String _tanksKey = 'vapecare_tanks';
  static const String _batteriesKey = 'vapecare_batteries';
  static const String _liquidsKey = 'vapecare_liquids';

  @override
  Future<List<TankSetup>> fetchTanks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tanksKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final tanks = list.map((item) => TankSetup.fromMap(item)).toList();
      tanks.sort((a, b) => a.tankName.toLowerCase().compareTo(b.tankName.toLowerCase()));
      return tanks;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<BatteryItem>> fetchBatteries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_batteriesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final bats = list.map((item) => BatteryItem.fromMap(item)).toList();
      bats.sort((a, b) => a.code.toLowerCase().compareTo(b.code.toLowerCase()));
      return bats;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<LiquidItem>> fetchLiquids() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_liquidsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final liqs = list.map((item) => LiquidItem.fromMap(item)).toList();
      liqs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return liqs;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveTanks(List<TankSetup> tanks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tanks.map((t) => t.toMap()).toList());
    await prefs.setString(_tanksKey, jsonStr);
  }

  Future<void> _saveBatteries(List<BatteryItem> batteries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(batteries.map((b) => b.toMap()).toList());
    await prefs.setString(_batteriesKey, jsonStr);
  }

  Future<void> _saveLiquids(List<LiquidItem> liquids) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(liquids.map((l) => l.toMap()).toList());
    await prefs.setString(_liquidsKey, jsonStr);
  }

  @override
  Future<void> replaceAllTanks(List<TankSetup> tanks) async {
    await _saveTanks(tanks);
  }

  @override
  Future<void> replaceAllBatteries(List<BatteryItem> batteries) async {
    await _saveBatteries(batteries);
  }

  @override
  Future<void> replaceAllLiquids(List<LiquidItem> liquids) async {
    await _saveLiquids(liquids);
  }

  @override
  Future<void> upsertTank(TankSetup tank) async {
    final list = await fetchTanks();
    final idx = list.indexWhere((t) =>
        t.id.toLowerCase() == tank.id.toLowerCase() ||
        t.tankName.trim().toLowerCase() == tank.tankName.trim().toLowerCase());
    if (idx >= 0) {
      list[idx] = tank;
    } else {
      list.add(tank);
    }
    await _saveTanks(list);
  }

  @override
  Future<void> upsertBattery(BatteryItem battery) async {
    final list = await fetchBatteries();
    final idx = list.indexWhere((b) =>
        b.id.toLowerCase() == battery.id.toLowerCase() ||
        b.code.trim().toLowerCase() == battery.code.trim().toLowerCase());
    if (idx >= 0) {
      list[idx] = battery;
    } else {
      list.add(battery);
    }
    await _saveBatteries(list);
  }

  @override
  Future<void> upsertLiquid(LiquidItem liquid) async {
    final list = await fetchLiquids();
    final idx = list.indexWhere((l) =>
        l.id.toLowerCase() == liquid.id.toLowerCase() ||
        l.name.trim().toLowerCase() == liquid.name.trim().toLowerCase());
    if (idx >= 0) {
      list[idx] = liquid;
    } else {
      list.add(liquid);
    }
    await _saveLiquids(list);
  }

  @override
  Future<void> deleteTank(String id) async {
    final list = await fetchTanks();
    list.removeWhere((t) => t.id == id);
    await _saveTanks(list);
  }

  @override
  Future<void> deleteBattery(String id) async {
    final list = await fetchBatteries();
    list.removeWhere((b) => b.id == id);
    await _saveBatteries(list);
  }

  @override
  Future<void> deleteLiquid(String id) async {
    final list = await fetchLiquids();
    list.removeWhere((l) => l.id == id);
    await _saveLiquids(list);
  }

  @override
  Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tanksKey);
    await prefs.remove(_batteriesKey);
    await prefs.remove(_liquidsKey);
  }
}
