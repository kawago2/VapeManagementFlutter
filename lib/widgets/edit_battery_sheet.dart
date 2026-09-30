import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vape_entities.dart';

class EditBatterySheet extends StatefulWidget {
  final BatteryItem? battery;
  final ValueChanged<BatteryItem> onSave;

  const EditBatterySheet({
    super.key,
    this.battery,
    required this.onSave,
  });

  @override
  State<EditBatterySheet> createState() => _EditBatterySheetState();
}

class _EditBatterySheetState extends State<EditBatterySheet> {
  late TextEditingController _codeController;
  late TextEditingController _brandController;
  late TextEditingController _notesController;
  late DateTime _purchasedDate;
  late int _maxDays;

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    final b = widget.battery;
    _codeController = TextEditingController(text: b?.code ?? 'BAT-01');
    _brandController =
        TextEditingController(text: b?.brandAndType ?? 'PVR Battery 18650');
    _notesController = TextEditingController(text: b?.notes ?? '');
    _purchasedDate = b?.purchasedDate ?? DateTime.now();
    _maxDays = b?.maxDays ?? 365;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
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
                  widget.battery == null ? 'Tambah Baterai' : 'Edit Baterai',
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
              controller: _codeController,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Kode Baterai (misal: BAT-01)',
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
              controller: _brandController,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Brand & Tipe (misal: Sony VTC6 18650)',
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
              controller: _notesController,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Tanggal Pembelian',
                  style: TextStyle(color: primaryTextColor, fontSize: 14)),
              subtitle: Text(_dateFormat.format(_purchasedDate),
                  style: TextStyle(color: secondaryTextColor)),
              trailing: Icon(Icons.calendar_today_rounded,
                  color: secondaryTextColor, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _purchasedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (d != null) setState(() => _purchasedDate = d);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final code = _codeController.text.trim();
                  if (code.isEmpty) return;
                  final newBat = BatteryItem(
                    id: widget.battery?.id,
                    code: code,
                    brandAndType: _brandController.text.trim(),
                    notes: _notesController.text.trim(),
                    purchasedDate: _purchasedDate,
                    maxDays: _maxDays,
                  );
                  widget.onSave(newBat);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandButtonBg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Baterai',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
