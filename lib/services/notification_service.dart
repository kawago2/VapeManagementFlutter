import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/vape_setup.dart';
import '../models/component_implementations.dart';
import 'service_interfaces.dart';

class LocalNotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int cottonNotificationId = 101;
  static const int coilNotificationId = 102;

  @override
  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  @override
  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  @override
  Future<void> scheduleReminders(VapeSetup setup) async {
    await cancelReminder(cottonNotificationId);
    await cancelReminder(coilNotificationId);

    final cotton = setup.getComponent<CottonComponent>();
    if (cotton != null) {
      final cottonDueDate = cotton.lastServicedDate.add(
        Duration(days: cotton.maxLifespanDays),
      );
      final scheduledCottonTime = DateTime(
        cottonDueDate.year,
        cottonDueDate.month,
        cottonDueDate.day,
        9,
        0,
      );

      if (scheduledCottonTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: cottonNotificationId,
          title: '⚠️ Waktunya Ganti Kapas!',
          body:
              'Kapas ${setup.deviceName} sudah mencapai batas ${cotton.maxLifespanDays} hari. Ganti sekarang untuk cita rasa maksimal!',
          scheduledDate: scheduledCottonTime,
        );
      }
    }

    final coil = setup.getComponent<CoilComponent>();
    if (coil != null) {
      final coilDueDate = coil.lastServicedDate.add(
        Duration(days: coil.maxLifespanDays),
      );
      final scheduledCoilTime = DateTime(
        coilDueDate.year,
        coilDueDate.month,
        coilDueDate.day,
        9,
        0,
      );

      if (scheduledCoilTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: coilNotificationId,
          title: '⚡ Waktunya Ganti Koil!',
          body:
              'Koil ${setup.deviceName} sudah terpakai ${coil.maxLifespanDays} hari. Waspada dry-hit dan kerak karbon!',
          scheduledDate: scheduledCoilTime,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'vapecare_reminders',
      'Pengingat Perawatan Vape',
      channelDescription:
          'Pengingat penggantian kapas dan koil vape secara berkala',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
