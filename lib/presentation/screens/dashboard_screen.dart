import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.blue600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'NitriSense AI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thứ Bảy, 4 tháng 4, 2026',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.notifications_none, size: 28),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.red600,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '10+',
                            style: TextStyle(color: AppColors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calories Card
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.orange500, AppColors.orange700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Calo hôm nay', style: TextStyle(color: AppColors.white90, fontSize: 14)),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('0', style: TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text('/ 2000', style: TextStyle(color: AppColors.white90, fontSize: 20)),
                                    ),
                                  ],
                                ),
                                const Text('kcal', style: TextStyle(color: AppColors.white80, fontSize: 14)),
                              ],
                            ),
                          ),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.local_fire_department, color: AppColors.white, size: 40),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0,
                        backgroundColor: AppColors.white20,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Còn lại: 2000 kcal', style: TextStyle(color: AppColors.white90, fontSize: 14)),
                          Icon(Icons.trending_up, color: AppColors.white80, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Water Card
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan600, AppColors.blue600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.water_drop, color: AppColors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nước uống', style: TextStyle(color: AppColors.white90, fontSize: 14)),
                                const Text('0 / 2000 ml', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Text('+', style: TextStyle(color: AppColors.cyan600, fontSize: 24)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0,
                        backgroundColor: AppColors.white20,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nutrients Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chất dinh dưỡng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      
                      // Protein
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Protein', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          Text('0g / 120g', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0,
                        backgroundColor: AppColors.orange100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange600),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 16),

                      // Carbs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Carbs', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          Text('0g / 250g', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0,
                        backgroundColor: AppColors.yellow100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber600),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 16),

                      // Fat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Chất béo', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          Text('0g / 65g', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0,
                        backgroundColor: AppColors.red100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.rose600),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Meals
              const Text('Bữa ăn hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              _buildMealItem('Bữa sáng', 'Bấm vào để xem chi tiết...', '0'),
              _buildMealItem('Bữa trưa', 'Bấm vào để xem chi tiết...', '0'),
              _buildMealItem('Bữa phụ', 'Bấm vào để xem chi tiết...', '0'),
              _buildMealItem('Bữa tối', 'Bấm vào để xem chi tiết...', '0'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealItem(String title, String desc, String cal) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(cal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue600)),
                  const Text('kcal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
