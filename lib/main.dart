import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';

import 'core/theme/theme_notifier.dart';

void main() async {
  // Cần gọi trước khi dùng bất kỳ Flutter plugin nào
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Locale tiếng Việt cho DateFormat
  await initializeDateFormatting('vi', null);

  // Khởi tạo Firebase (tương đương không cần làm gì trong Android vì
  // google-services.json tự động load, nhưng Flutter cần gọi thủ công)
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
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
