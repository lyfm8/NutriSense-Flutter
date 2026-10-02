import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                          const SizedBox(height: 8),

                          // Title
                          const Text(
                            'Chào mừng trở lại',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray800,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Đăng nhập để tiếp tục theo dõi sức khỏe của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          const CustomTextField(
                            hintText: 'Email',
                            startIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          const CustomTextField(
                            hintText: 'Mật khẩu',
                            startIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: AppColors.blue600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          GradientButton(
                            text: 'Đăng nhập',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MainScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Divider "Hoặc"
                          Row(
                            children: [
                              Expanded(child: Container(height: 1, color: AppColors.gray200)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Hoặc',
                                  style: TextStyle(
                                    color: AppColors.gray500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(child: Container(height: 1, color: AppColors.gray200)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google Login Button
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata, size: 24, color: AppColors.gray700),
                            label: const Text(
                              'Đăng nhập bằng Google',
                              style: TextStyle(
                                color: AppColors.gray700,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(color: AppColors.gray300),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Chưa có tài khoản? ',
                                style: TextStyle(
                                  color: AppColors.gray600,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Đăng ký',
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
