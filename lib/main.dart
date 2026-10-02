import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
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
