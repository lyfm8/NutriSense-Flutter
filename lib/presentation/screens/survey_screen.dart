import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'main_screen.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gray700,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo Container
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.health_and_safety,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),

                              // Title
                              const Center(
                                child: Text(
                                  'Chào mừng đến với NitriSense',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gray800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              const Center(
                                child: Text(
                                  'Hãy thiết lập hồ sơ để chúng tôi tạo lộ trình dinh dưỡng dành riêng cho bạn.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Name
                              _buildLabel('Tên hiển thị'),
                              const CustomTextField(
                                hintText: 'Nhập tên của bạn',
                                startIcon: Icons.person_outline,
                              ),

                              // DOB
                              _buildLabel('Ngày sinh'),
                              const CustomTextField(
                                hintText: 'Chọn ngày sinh',
                                startIcon: Icons.cake_outlined,
                              ),

                              // Height and Weight Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Chiều cao (cm)'),
                                        const CustomTextField(
                                          hintText: 'VD: 170',
                                          startIcon: Icons.height,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Cân nặng (kg)'),
                                        const CustomTextField(
                                          hintText: 'VD: 60',
                                          startIcon: Icons.monitor_weight_outlined,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Gender
                              _buildLabel('Giới tính'),
                              const CustomTextField(
                                hintText: 'Chọn giới tính',
                                startIcon: Icons.transgender,
                              ),

                              // Activity Level
                              _buildLabel('Mức độ vận động'),
                              const CustomTextField(
                                hintText: 'Chọn mức độ vận động',
                                startIcon: Icons.directions_run,
                              ),

                              // Goal
                              _buildLabel('Mục tiêu của bạn'),
                              const CustomTextField(
                                hintText: 'Chọn mục tiêu',
                                startIcon: Icons.track_changes,
                              ),

                              const SizedBox(height: 24),
                              
                              // Finish Button
                              GradientButton(
                                text: 'Hoàn thành & Bắt đầu',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom App Name
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'NitriSense AI',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 16,
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
    );
  }
}
