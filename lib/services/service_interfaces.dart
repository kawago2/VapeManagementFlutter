import '../models/vape_setup.dart';

abstract class IStorageService {
  Future<VapeSetup> loadSetup();
  Future<void> saveSetup(VapeSetup setup);
}

abstract class INotificationService {
  Future<void> init();
  Future<void> scheduleReminders(VapeSetup setup);
  Future<void> cancelReminder(int id);
}
