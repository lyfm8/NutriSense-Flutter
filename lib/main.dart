import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/utils/reminder_helper.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';
import 'core/theme/theme_notifier.dart';
import 'package:timezone/timezone.dart' as tz; // THÊM DÒNG NÀY
import 'package:permission_handler/permission_handler.dart'; // THÊM DÒNG NÀY
import 'core/theme/theme_notifier.dart'; // Đảm bảo đường dẫn import chính xác
// Biến toàn cục để sử dụng Local Notifications ở mọi nơi trong app
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // 1. Khởi tạo TimeZone (Rất quan trọng để hẹn giờ đúng)
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

  // 2. Cấu hình Android
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  // 3. Khởi tạo plugin VÀ BẮT SỰ KIỆN BẤM VÀO THÔNG BÁO
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        // Bắn tín hiệu vào Stream, ProfileScreen đang lắng nghe sẽ nhận được tín hiệu này
        ReminderHelper.selectNotificationStream.add(response.payload);
      }
    },
  );

  // 4. Xin quyền Notification & Exact Alarm (Android 13+)
  await Permission.notification.request();

  // Xin quyền Schedule Exact Alarm (Bắt buộc để báo thức nổ đúng phút)
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

void main() async {
  // Cần gọi trước khi dùng bất kỳ Flutter plugin nào
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Locale tiếng Việt cho DateFormat
  await initializeDateFormatting('vi', null);

  // Khởi tạo hệ thống Thông báo (Local Notifications)
  await initNotifications();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NutriSenseApp());
}

class NutriSenseApp extends StatelessWidget {
  const NutriSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'NutriSense',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            // Thêm các cấu hình theme sáng ở đây
          ),
          // Định nghĩa Theme Tối
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            // Nền đen tuyền
            scaffoldBackgroundColor: Colors.black,
            // Các Card sẽ có màu xám tối (Elevated) để nổi bật
            cardColor: const Color(0xFF1E1E1E),
            // Định nghĩa màu chữ cơ bản để thay thế AppColors.textPrimary
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}