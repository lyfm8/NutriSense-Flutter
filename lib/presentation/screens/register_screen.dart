import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'survey_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo Container
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          const Text(
                            'Tạo tài khoản mới',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray800,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          const CustomTextField(
                            hintText: 'Email',
                            startIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          const CustomTextField(
                            hintText: 'Mật khẩu (ít nhất 6 ký tự)',
                            startIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          const CustomTextField(
                            hintText: 'Xác nhận mật khẩu',
                            startIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          GradientButton(
                            text: 'Đăng ký',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SurveyScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Đã có tài khoản? ',
                                style: TextStyle(
                                  color: AppColors.gray600,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    color: AppColors.blue600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom App Name
              const Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'NitriSense AI',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
