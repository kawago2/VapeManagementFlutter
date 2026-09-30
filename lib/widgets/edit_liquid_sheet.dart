import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vape_entities.dart';

class EditLiquidSheet extends StatefulWidget {
  final LiquidItem? liquid;
  final ValueChanged<LiquidItem> onSave;

  const EditLiquidSheet({
    super.key,
    this.liquid,
    required this.onSave,
  });

  @override
  State<EditLiquidSheet> createState() => _EditLiquidSheetState();
}

class _EditLiquidSheetState extends State<EditLiquidSheet> {
  late TextEditingController _nameController;
  late TextEditingController _nicController;
  late TextEditingController _volController;
  late DateTime _openedDate;
  late int _maxDays;

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    final l = widget.liquid;
    _nameController = TextEditingController(text: l?.name ?? '');
    _nicController = TextEditingController(text: l?.nicMg ?? '3mg');
    _volController = TextEditingController(text: l?.volumeMl ?? '60ml');
    _openedDate = l?.openedDate ?? DateTime.now();
    _maxDays = l?.maxDays ?? 90;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _volController.dispose();
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
                  widget.liquid == null ? 'Tambah Liquid' : 'Edit Liquid',
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
                labelText: 'Nama Liquid',
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nicController,
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Nikotin (mis: 3mg)',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      filled: true,
                      fillColor: fillBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _volController,
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Volume (mis: 60ml)',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      filled: true,
                      fillColor: fillBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Tanggal Buka Segel',
                  style: TextStyle(color: primaryTextColor, fontSize: 14)),
              subtitle: Text(_dateFormat.format(_openedDate),
                  style: TextStyle(color: secondaryTextColor)),
              trailing: Icon(Icons.calendar_today_rounded,
                  color: secondaryTextColor, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _openedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (d != null) setState(() => _openedDate = d);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  final newLiq = LiquidItem(
                    id: widget.liquid?.id,
                    name: name,
                    nicMg: _nicController.text.trim(),
                    volumeMl: _volController.text.trim(),
                    openedDate: _openedDate,
                    maxDays: _maxDays,
                  );
                  widget.onSave(newLiq);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandButtonBg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Liquid',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
