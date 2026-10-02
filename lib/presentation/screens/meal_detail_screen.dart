import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.indigo600, AppColors.blue600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Bữa sáng',
                        style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 60, top: 4),
                    child: Text(
                      '4 tháng 4, 2026 - 07:30',
                      style: TextStyle(color: AppColors.white80, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Summary Card
            Card(
              elevation: 8,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: AppColors.blue600,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tổng calo', style: TextStyle(color: AppColors.white80, fontSize: 14)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const [
                                  Text('450', style: TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text('kcal', style: TextStyle(color: AppColors.white80, fontSize: 18)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.local_fire_department, color: AppColors.white, size: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildNutrientBox('Protein', '24g'),
                        const SizedBox(width: 8),
                        _buildNutrientBox('Carbs', '45g'),
                        const SizedBox(width: 8),
                        _buildNutrientBox('Chất béo', '18g'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMicronutrientBox('Chất xơ', '5g'),
                        const SizedBox(width: 8),
                        _buildMicronutrientBox('Vitamin C', '20mg'),
                        const SizedBox(width: 8),
                        _buildMicronutrientBox('Canxi', '150mg'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Detail List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chi tiết món ăn', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('+ Thêm', style: TextStyle(color: AppColors.blue600, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            // Items Container (Empty for now)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Chưa có món ăn nào.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBox(String name, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(name, style: const TextStyle(color: AppColors.white80, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMicronutrientBox(String name, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(name, style: const TextStyle(color: AppColors.white80, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
