import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // ⚡ تهيئة الإشعارات (تُستدعى في initState أو main)
  static Future<void> init() async {
    // 1. تهيئة المناطق الزمنية
    tz.initializeTimeZones();

    try {
      // محاولة ضبط التوقيت المحلي للجهاز
      tz.setLocalLocation(tz.local);
    } catch (e) {
      print("⏰ Timezone localization error: $e");
      // في حالة فشل التحديد التلقائي، سيستخدم التوقيت العالمي UTC كمرجع افتراضي
    }

    // 2. إعدادات الأندرويد (الأيقونة الافتراضية)
    // ملاحظة: تم استخدام ic_launcher لأنها مدعومة افتراضياً في كل المشاريع
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. إعدادات الـ iOS (Darwin)
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. تفعيل التهيئة مع ميزة التفاعل عند الضغط
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("🔔 Notification clicked with payload: ${details.payload}");
        // هنا يمكنك إضافة كود للتنقل لصفحة معينة عند الضغط على الإشعار
      },
    );

    // 5. طلب أذونات Android 13+ (POST_NOTIFICATIONS & EXACT_ALARM)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    print("🚀 Notification System Initialized Successfully");
  }

  // 🔹 إشعار فوري (للاختبار)
  static Future<void> showInstantNotification({
    int id = 0,
    String title = 'Instant Reminder',
    String body = 'This is a test notification from Smart Dental System',
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medical_reminders_v1', // Channel ID
          'Medical Reminders',    // Channel Name
          channelDescription: 'Dental care and treatment alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // 🔹 إشعار مجدول بدقة (المستخدم في الـ Reminders)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // التأكد من أن الموعد ليس في الماضي
    if (scheduledDate.isBefore(DateTime.now())) {
      print("⚠️ Cannot schedule in the past: $scheduledDate");
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local), // تحويل دقيق للمنطقة الزمنية
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medical_reminders_v1',
          'Medical Reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          fullScreenIntent: true, // لإظهار الإشعار حتى لو الموبايل مقفول (اختياري)
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // العمل حتى في وضع توفير الطاقة
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("📅 Scheduled: ID=$id, Title=$title at $scheduledDate");
  }

  // 🔹 إلغاء إشعار محدد (يُستدعى عند الضغط على Done)
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print("🗑️ Notification Cancelled: ID=$id");
  }

  // 🔹 إلغاء كل الإشعارات
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print("🗑️ All Notifications Cleared");
  }
}