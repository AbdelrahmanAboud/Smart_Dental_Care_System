import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // ⚡ تهيئة الإشعارات
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local); 
AndroidInitializationSettings androidSettings = const AndroidInitializationSettings('launch_background');
     InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(settings);

    // طلب أذونات Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // 🔹 إشعار فوري
  static Future<void> showInstantNotification({
    int id = 0,
    String title = 'إشعار فوري',
    String body = 'هذا اختبار للإشعار الفوري',
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel_v2',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'launch_background',
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
    print("✅ Instant Notification Shown: ID=$id, Title=$title");
  }

  // 🔹 إشعار مجدول مضبوط
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) {
      print("⏰ Warning: Cannot schedule in the past: $scheduledDate");
      return;
    }

    // تحويل الوقت للتوقيت المحلي بدقة
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.local(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
      scheduledDate.second,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel_v2',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'launch_background',
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Notification Scheduled: ID=$id, Title=$title, Time=$scheduledTZ");
  }

  // 🔹 إلغاء إشعار محدد
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print("❌ Notification Cancelled: ID=$id");
  }

  // 🔹 إلغاء كل الإشعارات
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print("❌ All Notifications Cancelled");
  }
}
