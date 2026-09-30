import 'package:flutter/material.dart';
import '../services/turso_config.dart';
import '../services/turso_sync_service.dart';

class CloudSettingsSheet extends StatefulWidget {
  const CloudSettingsSheet({super.key});

  @override
  State<CloudSettingsSheet> createState() => _CloudSettingsSheetState();
}

class _CloudSettingsSheetState extends State<CloudSettingsSheet> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await TursoConfig.getAuthToken();
    setState(() {
      _tokenController.text = token;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
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
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: brandButtonBg))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_rounded,
                            color: Color(0xFF007AFF), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Turso Cloud Sync',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded,
                          color: secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  TursoConfig.databaseUrl.isNotEmpty
                      ? 'Database: ${TursoConfig.databaseUrl}'
                      : 'Database: Belum dikonfigurasi (.env)',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tokenController,
                  obscureText: true,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Turso Auth Token',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    hintText: 'Bearer eyJhbGci...',
                    hintStyle: TextStyle(
                        color: secondaryTextColor.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: fillBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      await TursoConfig.setAuthToken(_tokenController.text);
                      await TursoSyncService.shared.checkConnection();
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandButtonBg,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Konfigurasi Token',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
