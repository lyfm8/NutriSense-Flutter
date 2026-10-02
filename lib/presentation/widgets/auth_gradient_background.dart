import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AuthGradientBackground extends StatelessWidget {
  final Widget child;

  const AuthGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue50, AppColors.blue100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
