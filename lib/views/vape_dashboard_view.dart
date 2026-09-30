import 'package:flutter/material.dart';
import '../models/vape_entities.dart';
import '../repositories/vape_repository.dart';
import '../services/turso_sync_service.dart';
import '../widgets/cloud_settings_sheet.dart';
import '../widgets/compact_item_rows.dart';
import '../widgets/compact_status_bar_view.dart';
import '../widgets/compact_tank_card_view.dart';
import '../widgets/dashboard_filter_bar.dart';
import '../widgets/edit_battery_sheet.dart';
import '../widgets/edit_liquid_sheet.dart';
import '../widgets/edit_tank_setup_sheet.dart';
import '../widgets/quick_reset_dialog.dart';
import '../widgets/section_header_view.dart';

class VapeDashboardView extends StatefulWidget {
  final VapeRepository repository;

  const VapeDashboardView({super.key, required this.repository});

  @override
  State<VapeDashboardView> createState() => _VapeDashboardViewState();
}

class _VapeDashboardViewState extends State<VapeDashboardView> {
  DashboardTab _selectedTab = DashboardTab.overview;

  List<TankSetup> _tanks = [];
  List<BatteryItem> _batteries = [];
  List<LiquidItem> _liquids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDataAndSync();
  }

  Future<void> _initDataAndSync() async {
    // 1. Tampilkan data lokal segera agar UI cepat
    await _loadAllData();

    // 2. Tarik data terbaru dari Cloud jika terhubung
    if (TursoSyncService.shared.isConnected) {
      try {
        await TursoSyncService.shared.pullDataFromCloud(widget.repository);
        await _loadAllData();
      } catch (_) {}
    }
  }

  Future<void> _loadAllData() async {
    final tanks = await widget.repository.fetchTanks();
    final batteries = await widget.repository.fetchBatteries();
    final liquids = await widget.repository.fetchLiquids();

    if (mounted) {
      setState(() {
        _tanks = tanks;
        _batteries = batteries;
        _liquids = liquids;
        _isLoading = false;
      });
    }
  }

  int get _overdueCoilCount =>
      _tanks.where((t) => t.coilHealthStatus.isOverdue).length;

  int get _overdueCottonCount =>
      _tanks.where((t) => t.cottonHealthStatus.isOverdue).length;

  List<String> get _availableLiquidNames =>
      _liquids.map((l) => l.name).toSet().toList();

  Future<void> _showQuickReset({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final confirm = await QuickResetDialog.show(
      context,
      title: title,
      message: message,
    );
    if (confirm == true) {
      onConfirm();
    }
  }

  void _onQuickResetCoil(TankSetup tank) {
    _showQuickReset(
      title: 'Reset Koil Hari Ini?',
      message: 'Perbarui tanggal ganti coil untuk \'${tank.tankName}\' ke hari ini?',
      onConfirm: () async {
        tank.coilInstalledDate = DateTime.now();
        await widget.repository.upsertTank(tank);
        TursoSyncService.shared.pushSingleTank(tank);
        _loadAllData();
      },
    );
  }

  void _onQuickResetCotton(TankSetup tank) {
    _showQuickReset(
      title: 'Reset Kapas Hari Ini?',
      message: 'Perbarui tanggal ganti kapas untuk \'${tank.tankName}\' ke hari ini?',
      onConfirm: () async {
        tank.cottonReplacedDate = DateTime.now();
        await widget.repository.upsertTank(tank);
        TursoSyncService.shared.pushSingleTank(tank);
        _loadAllData();
      },
    );
  }

  void _openTankSheet([TankSetup? tank]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTankSetupSheet(
        tank: tank,
        availableLiquids: _availableLiquidNames,
        onSave: (savedTank) async {
          await widget.repository.upsertTank(savedTank);
          TursoSyncService.shared.pushSingleTank(savedTank);
          _loadAllData();
        },
      ),
    );
  }

  void _openBatterySheet([BatteryItem? battery]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditBatterySheet(
        battery: battery,
        onSave: (savedBat) async {
          await widget.repository.upsertBattery(savedBat);
          TursoSyncService.shared.pushSingleBattery(savedBat);
          _loadAllData();
        },
      ),
    );
  }

  void _openLiquidSheet([LiquidItem? liquid]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditLiquidSheet(
        liquid: liquid,
        onSave: (savedLiq) async {
          await widget.repository.upsertLiquid(savedLiq);
          TursoSyncService.shared.pushSingleLiquid(savedLiq);
          _loadAllData();
        },
      ),
    );
  }

  void _openCloudSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CloudSettingsSheet(),
    );
  }

  Future<void> _triggerCloudSync() async {
    try {
      await TursoSyncService.shared.syncTwoWay(widget.repository);
      await _loadAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sinkronisasi Turso Cloud 2 arah berhasil!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Sinkronisasi gagal: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final brandColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF0C3866);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(
          child: CircularProgressIndicator(color: brandColor),
        ),
      );
    }

    return AnimatedBuilder(
      animation: TursoSyncService.shared,
      builder: (context, _) {
        final syncService = TursoSyncService.shared;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                syncService.isConnected
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_outlined,
                color: syncService.isConnected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFF8E8E93),
                size: 20,
              ),
              tooltip: 'Turso Cloud Settings',
              onPressed: _openCloudSettings,
            ),
            title: Text(
              'Vape Management',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: true,
            actions: [
              if (syncService.isConnected)
                IconButton(
                  icon: syncService.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF007AFF),
                          ),
                        )
                      : const Icon(Icons.sync_rounded,
                          color: Color(0xFF007AFF), size: 20),
                  tooltip: 'Sinkronkan dengan Cloud',
                  onPressed: syncService.isSyncing ? null : _triggerCloudSync,
                ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: PopupMenuButton<String>(
                  color: cardBg,
                  surfaceTintColor: cardBg,
                  tooltip: 'Tambah Data',
                  onSelected: (val) {
                    if (val == 'tank') _openTankSheet();
                    if (val == 'battery') _openBatterySheet();
                    if (val == 'liquid') _openLiquidSheet();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'tank',
                      child: Row(
                        children: [
                          Icon(Icons.grain_rounded,
                              size: 18, color: primaryTextColor),
                          const SizedBox(width: 8),
                          Text('Tambah Tank',
                              style: TextStyle(
                                  color: primaryTextColor, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'battery',
                      child: Row(
                        children: [
                          Icon(Icons.battery_charging_full_rounded,
                              size: 18, color: primaryTextColor),
                          const SizedBox(width: 8),
                          Text('Tambah Baterai',
                              style: TextStyle(
                                  color: primaryTextColor, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'liquid',
                      child: Row(
                        children: [
                          Icon(Icons.water_drop_rounded,
                              size: 18, color: primaryTextColor),
                          const SizedBox(width: 8),
                          Text('Tambah Liquid',
                              style: TextStyle(
                                  color: primaryTextColor, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (TursoSyncService.shared.isConnected) {
                try {
                  await TursoSyncService.shared.pullDataFromCloud(widget.repository);
                } catch (_) {}
              }
              await _loadAllData();
            },
            color: const Color(0xFF007AFF),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                CompactStatusBarView(
                  overdueCoilCount: _overdueCoilCount,
                  overdueCottonCount: _overdueCottonCount,
                ),
                const SizedBox(height: 12),
                DashboardFilterBar(
                  selectedTab: _selectedTab,
                  onTabSelected: (tab) => setState(() => _selectedTab = tab),
                ),
                const SizedBox(height: 6),

                // Tank Section
                if (_selectedTab == DashboardTab.overview ||
                    _selectedTab == DashboardTab.tanks) ...[
                  SectionHeaderView(
                    title: 'TANK & SETUP',
                    count: _tanks.length,
                    onAdd: () => _openTankSheet(),
                  ),
                  if (_tanks.isEmpty)
                    _buildEmptyState('Belum ada tank terpasang.', cardBg)
                  else
                    for (final tank in _tanks)
                      CompactTankCardView(
                        tank: tank,
                        availableLiquids: _availableLiquidNames,
                        onSelectLiquid: (newLiquid) async {
                          tank.activeLiquidName = newLiquid;
                          await widget.repository.upsertTank(tank);
                          _loadAllData();
                        },
                        onEdit: () => _openTankSheet(tank),
                        onDelete: () async {
                          await widget.repository.deleteTank(tank.id);
                          TursoSyncService.shared.deleteCloudTank(tank.id);
                          _loadAllData();
                        },
                        onQuickResetCoil: () => _onQuickResetCoil(tank),
                        onQuickResetCotton: () => _onQuickResetCotton(tank),
                      ),
                ],

                // Battery Section
                if (_selectedTab == DashboardTab.overview ||
                    _selectedTab == DashboardTab.batteries) ...[
                  SectionHeaderView(
                    title: 'BATERAI 18650 & CHARGER',
                    count: _batteries.length,
                    onAdd: () => _openBatterySheet(),
                  ),
                  if (_batteries.isEmpty)
                    _buildEmptyState('Belum ada baterai terdaftar.', cardBg)
                  else
                    for (final bat in _batteries)
                      CompactBatteryRowView(
                        battery: bat,
                        onEdit: () => _openBatterySheet(bat),
                        onDelete: () async {
                          await widget.repository.deleteBattery(bat.id);
                          TursoSyncService.shared.deleteCloudBattery(bat.id);
                          _loadAllData();
                        },
                      ),
                ],

                // Liquid Section
                if (_selectedTab == DashboardTab.overview ||
                    _selectedTab == DashboardTab.liquids) ...[
                  SectionHeaderView(
                    title: 'DAFTAR & USIA LIQUID',
                    count: _liquids.length,
                    onAdd: () => _openLiquidSheet(),
                  ),
                  if (_liquids.isEmpty)
                    _buildEmptyState('Belum ada liquid terdaftar.', cardBg)
                  else
                    for (final liq in _liquids)
                      CompactLiquidRowView(
                        liquid: liq,
                        onEdit: () => _openLiquidSheet(liq),
                        onDelete: () async {
                          await widget.repository.deleteLiquid(liq.id);
                          TursoSyncService.shared.deleteCloudLiquid(liq.id);
                          _loadAllData();
                        },
                      ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
      ),
    );
  }
}
