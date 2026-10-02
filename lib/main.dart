import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  // Cần gọi trước khi dùng bất kỳ Flutter plugin nào
  WidgetsFlutterBinding.ensureInitialized();

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
    return MaterialApp(
      title: 'NutriSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
