import 'package:shared_preferences/shared_preferences.dart';
import '../models/vape_setup.dart';
import 'service_interfaces.dart';

class SharedPrefsStorageService implements IStorageService {
  static const String _storageKey = 'vapecare_setup_data';

  @override
  Future<VapeSetup> loadSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return VapeSetup.fromJson(jsonStr);
      } catch (_) {
        // Fallback default
      }
    }
    return VapeSetup();
  }

  @override
  Future<void> saveSetup(VapeSetup setup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, setup.toJson());
  }
}
