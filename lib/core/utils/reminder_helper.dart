import 'dart:async'; // THÊM DÒNG NÀY
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:app_settings/app_settings.dart';
import '../../main.dart';

class ReminderHelper {
  // THÊM DÒNG NÀY: Đường ống (Stream) để lắng nghe sự kiện click thông báo
  static final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  static const int waterId = 1001;
  static const int mealId = 1002;
  static const int sleepId = 1003;
  static const int aiId = 1004;

  // SỬA LẠI THÀNH TÊN KHÁC ĐỂ TRÁNH ĐỤNG ĐỘ VỚI SCHEDULE SCREEN
  static const String channelId = 'health_reminders_channel';
  static const String channelName = 'Nhắc nhở sức khỏe';

  static Future<void> scheduleDailyReminder(int id, String title, String body, TimeOfDay time) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Gồm uống nước, bữa ăn, giấc ngủ, trợ lý AI',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);

    // Xác định payload để biết thông báo nào vừa được bấm
    String payloadType = 'general';
    if (id == aiId) payloadType = 'ai_summary';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payloadType, // Gửi kèm dữ liệu này
    );
  }

  static Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> openSystemSoundSettings() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
          channelId,
          channelName,
          importance: Importance.max,
          description: 'Nhắc nhở lịch trình hàng ngày'
      ),
    );

    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}