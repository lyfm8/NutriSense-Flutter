import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.indigo600, AppColors.blue600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), // Placeholder for back button if needed
                    const Text(
                      'Lịch trình',
                      style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Month Selector
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8, left: 20, right: 20),
                child: Row(
                  children: [
                    const Text(
                      'Tháng 4, 2026',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_month, color: AppColors.blue600),
                  ],
                ),
              ),

              // Calendar Strip
              Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppColors.white90,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(7, (index) {
                        bool isSelected = index == 3;
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.blue600 : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'T${index + 2}',
                                style: TextStyle(
                                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Events
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildEventCategory('Sáng'),
                    _buildEventCategory('Trưa'),
                    _buildEventCategory('Tối'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCategory(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Lịch trình: $title',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }
}
