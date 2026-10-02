import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DailyHistoryScreen extends StatelessWidget {
  const DailyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Lịch sử hàng ngày', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDailyCard('Hôm nay', '4 tháng 4, 2026', '1450', '1200', '3'),
            _buildDailyCard('Hôm qua', '3 tháng 4, 2026', '2200', '2300', '4'),
            _buildDailyCard('Thứ Năm', '2 tháng 4, 2026', '1880', '2100', '4'),
            _buildDailyCard('Thứ Tư', '1 tháng 4, 2026', '2050', '1900', '4'),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyCard(String dayName, String date, String cal, String water, String meals) {
    return Card(
      elevation: 12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            // Top Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(color: AppColors.gray900, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        date,
                        style: const TextStyle(color: AppColors.gray500, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blue600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        cal,
                        style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Middle Row
            Row(
              children: [
                // Water Info
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cyan50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('💧 Nước uống', style: TextStyle(color: AppColors.gray500, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(water, style: const TextStyle(color: AppColors.cyan600, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('ml', style: TextStyle(color: AppColors.cyan600, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // Meals Info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('🍽️ Số bữa ăn', style: TextStyle(color: AppColors.gray500, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(meals, style: const TextStyle(color: AppColors.blue600, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('bữa', style: TextStyle(color: AppColors.blue600, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // View Details Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.gray300),
              ),
              child: const Text('Xem chi tiết', style: TextStyle(color: AppColors.gray700, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
