import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vape_entities.dart';

class EditTankSetupSheet extends StatefulWidget {
  final TankSetup? tank;
  final List<String> availableLiquids;
  final ValueChanged<TankSetup> onSave;

  const EditTankSetupSheet({
    super.key,
    this.tank,
    required this.availableLiquids,
    required this.onSave,
  });

  @override
  State<EditTankSetupSheet> createState() => _EditTankSetupSheetState();
}

class _EditTankSetupSheetState extends State<EditTankSetupSheet> {
  late TextEditingController _nameController;
  late TextEditingController _wireController;
  late DateTime _coilDate;
  late DateTime _cottonDate;
  late String _activeLiquid;
  late int _coilMaxDays;
  late int _cottonMaxDays;

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    final t = widget.tank;
    _nameController = TextEditingController(text: t?.tankName ?? '');
    _wireController =
        TextEditingController(text: t?.wireType ?? 'Coil Teko Baby Alien (0.35Ω)');
    _coilDate = t?.coilInstalledDate ?? DateTime.now();
    _cottonDate = t?.cottonReplacedDate ?? DateTime.now();
    _activeLiquid = t?.activeLiquidName ??
        (widget.availableLiquids.isNotEmpty ? widget.availableLiquids.first : '');
    _coilMaxDays = t?.coilMaxDays ?? 14;
    _cottonMaxDays = t?.cottonMaxDays ?? 4;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wireController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final res = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (res != null) setState(() => onPicked(res));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final fillBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = const Color(0xFF8E8E93);
    final brandButtonBg = isDark ? const Color(0xFF0A84FF) : const Color(0xFF0C3866);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.tank == null ? 'Tambah Tank Setup' : 'Edit Tank Setup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: secondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Nama Tank / RTA / RDA',
                labelStyle: TextStyle(color: secondaryTextColor),
                filled: true,
                fillColor: fillBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wireController,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Tipe Kawat / Koil',
                labelStyle: TextStyle(color: secondaryTextColor),
                filled: true,
                fillColor: fillBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active Liquid Dropdown
            DropdownButtonFormField<String>(
              initialValue: widget.availableLiquids.contains(_activeLiquid)
                  ? _activeLiquid
                  : null,
              dropdownColor: sheetBg,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Liquid Terisi',
                labelStyle: TextStyle(color: secondaryTextColor),
                filled: true,
                fillColor: fillBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: widget.availableLiquids.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _activeLiquid = val);
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Koil Terpasang Sejak',
                  style: TextStyle(color: primaryTextColor, fontSize: 14)),
              subtitle: Text(_dateFormat.format(_coilDate),
                  style: TextStyle(color: secondaryTextColor)),
              trailing: Icon(Icons.calendar_today_rounded,
                  color: secondaryTextColor, size: 18),
              onTap: () => _pickDate(_coilDate, (d) => _coilDate = d),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Kapas Diganti Sejak',
                  style: TextStyle(color: primaryTextColor, fontSize: 14)),
              subtitle: Text(_dateFormat.format(_cottonDate),
                  style: TextStyle(color: secondaryTextColor)),
              trailing: Icon(Icons.calendar_today_rounded,
                  color: secondaryTextColor, size: 18),
              onTap: () => _pickDate(_cottonDate, (d) => _cottonDate = d),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  final newTank = TankSetup(
                    id: widget.tank?.id,
                    tankName: name,
                    wireType: _wireController.text.trim(),
                    coilInstalledDate: _coilDate,
                    cottonReplacedDate: _cottonDate,
                    activeLiquidName: _activeLiquid,
                    coilMaxDays: _coilMaxDays,
                    cottonMaxDays: _cottonMaxDays,
                  );
                  widget.onSave(newTank);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandButtonBg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Setup Tank',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
