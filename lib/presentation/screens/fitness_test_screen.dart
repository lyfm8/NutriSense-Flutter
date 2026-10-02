import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FitnessTestScreen extends StatelessWidget {
  const FitnessTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.cyan600, AppColors.blue600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bài test thể lực',
                        style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Đánh giá sức khỏe của bạn',
                        style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildExerciseCard('Hít đất', 'Số lần hít đất liên tục', Icons.fitness_center, AppColors.blue600),
                _buildExerciseCard('Chạy 1km', 'Thời gian chạy 1km', Icons.directions_run, AppColors.cyan600),
                _buildExerciseCard('Plank', 'Thời gian giữ tư thế plank', Icons.timer, AppColors.indigo400),
                _buildExerciseCard('Gập bụng', 'Số lần gập bụng / 1 phút', Icons.trending_up, AppColors.indigo600),
              ]),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.chevron_left, color: AppColors.blue600),
                          ),
                          Expanded(
                            child: const Text(
                              'Hôm nay',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.chevron_right, color: AppColors.blue600),
                          ),
                        ],
                      ),
                    ),
                    const DefaultTabController(
                      length: 5,
                      child: TabBar(
                        isScrollable: true,
                        labelColor: AppColors.blue600,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.blue600,
                        tabs: [
                          Tab(text: 'Tất cả'),
                          Tab(text: 'Hít đất'),
                          Tab(text: 'Chạy'),
                          Tab(text: 'Plank'),
                          Tab(text: 'Gập bụng'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
