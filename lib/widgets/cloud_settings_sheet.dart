import 'package:flutter/material.dart';
import '../services/turso_config.dart';
import '../services/turso_sync_service.dart';

class CloudSettingsSheet extends StatefulWidget {
  const CloudSettingsSheet({super.key});

  @override
  State<CloudSettingsSheet> createState() => _CloudSettingsSheetState();
}

class _CloudSettingsSheetState extends State<CloudSettingsSheet> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final url = await TursoConfig.getDatabaseUrl();
    final token = await TursoConfig.getAuthToken();
    setState(() {
      _urlController.text = url;
      _tokenController.text = token;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
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
                const SizedBox(height: 8),
                Text(
                  'Masukkan Database URL dan Auth Token Turso Anda. Konfigurasi ini disimpan secara lokal dan aman.',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Turso Database URL',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    hintText: 'https://db-name-org.turso.io',
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
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenController,
                  obscureText: true,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Turso Auth Token',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    hintText: 'Bearer eyJhbGci... atau token langsung',
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
                      await TursoConfig.setDatabaseUrl(_urlController.text);
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
                    child: const Text('Simpan Konfigurasi Cloud',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
