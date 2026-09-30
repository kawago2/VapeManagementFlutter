import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/vape_entities.dart';
import '../repositories/vape_repository.dart';
import 'turso_config.dart';

class TursoSyncService extends ChangeNotifier {
  static final TursoSyncService shared = TursoSyncService();

  bool _isSyncing = false;
  bool _isConnected = false;
  DateTime? _lastSyncDate;
  String _lastSyncStatus = '';

  bool get isSyncing => _isSyncing;
  bool get isConnected => _isConnected;
  DateTime? get lastSyncDate => _lastSyncDate;
  String get lastSyncStatus => _lastSyncStatus;

  TursoSyncService() {
    checkConnection();
  }

  Future<void> checkConnection() async {
    final configured = await TursoConfig.isConfigured();
    _isConnected = configured;
    notifyListeners();
  }

  Future<List<dynamic>> executeSQL(List<String> queries) async {
    final token = await TursoConfig.getAuthToken();
    final dbUrl = await TursoConfig.getDatabaseUrl();
    if (token.isEmpty || dbUrl.isEmpty) {
      throw Exception('Turso Database URL atau Auth Token belum dikonfigurasi');
    }

    String sanitizedDbUrl = dbUrl.trim();
    if (sanitizedDbUrl.endsWith('/')) {
      sanitizedDbUrl = sanitizedDbUrl.substring(0, sanitizedDbUrl.length - 1);
    }
    if (sanitizedDbUrl.startsWith('libsql://')) {
      sanitizedDbUrl = sanitizedDbUrl.replaceFirst('libsql://', 'https://');
    } else if (!sanitizedDbUrl.startsWith('http://') && !sanitizedDbUrl.startsWith('https://')) {
      sanitizedDbUrl = 'https://$sanitizedDbUrl';
    }

    final endpoint = '$sanitizedDbUrl/v2/pipeline';
    final requests = queries.map((q) {
      return {
        'type': 'execute',
        'stmt': {'sql': q}
      };
    }).toList();

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requests': requests,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Turso error HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? [];
    return results;
  }

  Future<void> initializeTables() async {
    const createTanksSQL = """
    CREATE TABLE IF NOT EXISTS tanks (
        id TEXT PRIMARY KEY,
        tank_name TEXT NOT NULL,
        wire_type TEXT NOT NULL,
        coil_installed_date TEXT NOT NULL,
        cotton_replaced_date TEXT NOT NULL,
        active_liquid_name TEXT NOT NULL,
        coil_max_days INTEGER NOT NULL,
        cotton_max_days INTEGER NOT NULL
    );
    """;

    const createBatteriesSQL = """
    CREATE TABLE IF NOT EXISTS batteries (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        brand_and_type TEXT NOT NULL,
        purchased_date TEXT NOT NULL,
        max_days INTEGER NOT NULL,
        notes TEXT
    );
    """;

    const createLiquidsSQL = """
    CREATE TABLE IF NOT EXISTS liquids (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        opened_date TEXT NOT NULL,
        max_days INTEGER NOT NULL,
        nic_mg TEXT NOT NULL,
        volume_ml TEXT NOT NULL
    );
    """;

    await executeSQL([createTanksSQL, createBatteriesSQL, createLiquidsSQL]);
  }

  List<Map<String, String>> _parseRows(dynamic resultItem) {
    if (resultItem is! Map<String, dynamic>) return [];
    final response = resultItem['response'] as Map<String, dynamic>?;
    final result = response?['result'] as Map<String, dynamic>?;
    final cols = result?['cols'] as List<dynamic>? ?? [];
    final rows = result?['rows'] as List<dynamic>? ?? [];

    final colNames = cols.map((c) => c['name']?.toString() ?? '').toList();
    final rowDicts = <Map<String, String>>[];

    for (final row in rows) {
      if (row is! List<dynamic>) continue;
      final dict = <String, String>{};
      for (int i = 0; i < row.length; i++) {
        if (i < colNames.length) {
          final cell = row[i];
          if (cell is Map<String, dynamic> && cell.containsKey('value')) {
            dict[colNames[i]] = cell['value']?.toString() ?? '';
          }
        }
      }
      rowDicts.add(dict);
    }
    return rowDicts;
  }

  Future<void> pullDataFromCloud(VapeRepository repository) async {
    await initializeTables();

    final results = await executeSQL([
      "SELECT id, tank_name, wire_type, coil_installed_date, cotton_replaced_date, active_liquid_name, coil_max_days, cotton_max_days FROM tanks ORDER BY tank_name ASC;",
      "SELECT id, code, brand_and_type, purchased_date, max_days, notes FROM batteries ORDER BY code ASC;",
      "SELECT id, name, opened_date, max_days, nic_mg, volume_ml FROM liquids ORDER BY name ASC;"
    ]);

    if (results.length < 3) return;

    // 1. Tanks
    final tankRows = _parseRows(results[0]);
    final cloudTanks = <TankSetup>[];
    for (final row in tankRows) {
      final id = row['id'];
      final name = row['tank_name'];
      if (id == null || id.isEmpty || name == null) continue;

      cloudTanks.add(TankSetup(
        id: id,
        tankName: name,
        wireType: row['wire_type'] ?? '',
        coilInstalledDate: parseFlexibleDate(row['coil_installed_date']),
        cottonReplacedDate: parseFlexibleDate(row['cotton_replaced_date']),
        activeLiquidName: row['active_liquid_name'] ?? '',
        coilMaxDays: int.tryParse(row['coil_max_days'] ?? '14') ?? 14,
        cottonMaxDays: int.tryParse(row['cotton_max_days'] ?? '4') ?? 4,
      ));
    }
    await repository.replaceAllTanks(cloudTanks);

    // 2. Batteries
    final batRows = _parseRows(results[1]);
    final cloudBatteries = <BatteryItem>[];
    for (final row in batRows) {
      final id = row['id'];
      final code = row['code'];
      if (id == null || id.isEmpty || code == null) continue;

      cloudBatteries.add(BatteryItem(
        id: id,
        code: code,
        brandAndType: row['brand_and_type'] ?? '',
        purchasedDate: parseFlexibleDate(row['purchased_date']),
        maxDays: int.tryParse(row['max_days'] ?? '365') ?? 365,
        notes: row['notes'] ?? '',
      ));
    }
    await repository.replaceAllBatteries(cloudBatteries);

    // 3. Liquids
    final liqRows = _parseRows(results[2]);
    final cloudLiquids = <LiquidItem>[];
    for (final row in liqRows) {
      final id = row['id'];
      final name = row['name'];
      if (id == null || id.isEmpty || name == null) continue;

      cloudLiquids.add(LiquidItem(
        id: id,
        name: name,
        openedDate: parseFlexibleDate(row['opened_date']),
        maxDays: int.tryParse(row['max_days'] ?? '90') ?? 90,
        nicMg: row['nic_mg'] ?? '3mg',
        volumeMl: row['volume_ml'] ?? '60ml',
      ));
    }
    await repository.replaceAllLiquids(cloudLiquids);
  }

  Future<void> pushLocalDataToCloud(
    List<TankSetup> tanks,
    List<BatteryItem> batteries,
    List<LiquidItem> liquids,
  ) async {
    await initializeTables();
    final queries = <String>[];

    // 1. Tanks Upsert (Delete existing record by name to prevent duplicate rows with different IDs)
    for (final tank in tanks) {
      final coilDate = tank.coilInstalledDate.toDateString();
      final cottonDate = tank.cottonReplacedDate.toDateString();
      final safeName = tank.tankName.replaceAll("'", "''");
      final safeWire = tank.wireType.replaceAll("'", "''");
      final safeLiquid = tank.activeLiquidName.replaceAll("'", "''");

      queries.add("DELETE FROM tanks WHERE LOWER(TRIM(tank_name)) = LOWER(TRIM('$safeName')) AND id != '${tank.id}';");
      queries.add(
        "INSERT OR REPLACE INTO tanks (id, tank_name, wire_type, coil_installed_date, cotton_replaced_date, active_liquid_name, coil_max_days, cotton_max_days) VALUES ('${tank.id}', '$safeName', '$safeWire', '$coilDate', '$cottonDate', '$safeLiquid', ${tank.coilMaxDays}, ${tank.cottonMaxDays});",
      );
    }

    // 2. Batteries Upsert (Delete existing record by code to prevent duplicate rows with different IDs)
    for (final bat in batteries) {
      final buyDate = bat.purchasedDate.toDateString();
      final safeCode = bat.code.replaceAll("'", "''");
      final safeBrand = bat.brandAndType.replaceAll("'", "''");
      final safeNotes = bat.notes.replaceAll("'", "''");

      queries.add("DELETE FROM batteries WHERE LOWER(TRIM(code)) = LOWER(TRIM('$safeCode')) AND id != '${bat.id}';");
      queries.add(
        "INSERT OR REPLACE INTO batteries (id, code, brand_and_type, purchased_date, max_days, notes) VALUES ('${bat.id}', '$safeCode', '$safeBrand', '$buyDate', ${bat.maxDays}, '$safeNotes');",
      );
    }

    // 3. Liquids Upsert (Delete existing record by name to prevent duplicate rows with different IDs)
    for (final liq in liquids) {
      final openDate = liq.openedDate.toDateString();
      final safeName = liq.name.replaceAll("'", "''");
      final safeNic = liq.nicMg.replaceAll("'", "''");
      final safeVol = liq.volumeMl.replaceAll("'", "''");

      queries.add("DELETE FROM liquids WHERE LOWER(TRIM(name)) = LOWER(TRIM('$safeName')) AND id != '${liq.id}';");
      queries.add(
        "INSERT OR REPLACE INTO liquids (id, name, opened_date, max_days, nic_mg, volume_ml) VALUES ('${liq.id}', '$safeName', '$openDate', ${liq.maxDays}, '$safeNic', '$safeVol');",
      );
    }

    if (queries.isNotEmpty) {
      await executeSQL(queries);
    }
  }

  Future<void> pushSingleTank(TankSetup tank) async {
    if (!isConnected) return;
    try {
      final coilDate = tank.coilInstalledDate.toDateString();
      final cottonDate = tank.cottonReplacedDate.toDateString();
      final safeName = tank.tankName.replaceAll("'", "''");
      final safeWire = tank.wireType.replaceAll("'", "''");
      final safeLiquid = tank.activeLiquidName.replaceAll("'", "''");

      await executeSQL([
        "DELETE FROM tanks WHERE LOWER(TRIM(tank_name)) = LOWER(TRIM('$safeName')) AND id != '${tank.id}';",
        "INSERT OR REPLACE INTO tanks (id, tank_name, wire_type, coil_installed_date, cotton_replaced_date, active_liquid_name, coil_max_days, cotton_max_days) VALUES ('${tank.id}', '$safeName', '$safeWire', '$coilDate', '$cottonDate', '$safeLiquid', ${tank.coilMaxDays}, ${tank.cottonMaxDays});",
      ]);
    } catch (_) {}
  }

  Future<void> deleteCloudTank(String id) async {
    if (!isConnected) return;
    try {
      await executeSQL(["DELETE FROM tanks WHERE id = '$id';"]);
    } catch (_) {}
  }

  Future<void> pushSingleBattery(BatteryItem bat) async {
    if (!isConnected) return;
    try {
      final buyDate = bat.purchasedDate.toDateString();
      final safeCode = bat.code.replaceAll("'", "''");
      final safeBrand = bat.brandAndType.replaceAll("'", "''");
      final safeNotes = bat.notes.replaceAll("'", "''");

      await executeSQL([
        "DELETE FROM batteries WHERE LOWER(TRIM(code)) = LOWER(TRIM('$safeCode')) AND id != '${bat.id}';",
        "INSERT OR REPLACE INTO batteries (id, code, brand_and_type, purchased_date, max_days, notes) VALUES ('${bat.id}', '$safeCode', '$safeBrand', '$buyDate', ${bat.maxDays}, '$safeNotes');",
      ]);
    } catch (_) {}
  }

  Future<void> deleteCloudBattery(String id) async {
    if (!isConnected) return;
    try {
      await executeSQL(["DELETE FROM batteries WHERE id = '$id';"]);
    } catch (_) {}
  }

  Future<void> pushSingleLiquid(LiquidItem liq) async {
    if (!isConnected) return;
    try {
      final openDate = liq.openedDate.toDateString();
      final safeName = liq.name.replaceAll("'", "''");
      final safeNic = liq.nicMg.replaceAll("'", "''");
      final safeVol = liq.volumeMl.replaceAll("'", "''");

      await executeSQL([
        "DELETE FROM liquids WHERE LOWER(TRIM(name)) = LOWER(TRIM('$safeName')) AND id != '${liq.id}';",
        "INSERT OR REPLACE INTO liquids (id, name, opened_date, max_days, nic_mg, volume_ml) VALUES ('${liq.id}', '$safeName', '$openDate', ${liq.maxDays}, '$safeNic', '$safeVol');",
      ]);
    } catch (_) {}
  }

  Future<void> deleteCloudLiquid(String id) async {
    if (!isConnected) return;
    try {
      await executeSQL(["DELETE FROM liquids WHERE id = '$id';"]);
    } catch (_) {}
  }

  Future<void> syncTwoWay(VapeRepository repository) async {
    _isSyncing = true;
    notifyListeners();

    try {
      // Step 1: Pull from cloud
      await pullDataFromCloud(repository);

      // Step 2: Push local to cloud
      final tanks = await repository.fetchTanks();
      final batteries = await repository.fetchBatteries();
      final liquids = await repository.fetchLiquids();

      await pushLocalDataToCloud(tanks, batteries, liquids);

      _lastSyncDate = DateTime.now();
      _lastSyncStatus = 'Sinkronisasi 2 arah berhasil!';
    } catch (e) {
      _lastSyncStatus = 'Gagal sync: $e';
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
