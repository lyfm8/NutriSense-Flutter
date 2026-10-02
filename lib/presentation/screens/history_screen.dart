import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'daily_history_screen.dart';
import 'report_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        body: Column(
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 0),
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
                      const Icon(Icons.history, color: AppColors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Lịch sử & Báo cáo',
                        style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Theo dõi hành trình dinh dưỡng của bạn',
                    style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  
                  // TabBar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: TabBar(
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.0, color: AppColors.white),
                        insets: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      labelColor: AppColors.white,
                      unselectedLabelColor: AppColors.white.withOpacity(0.6),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      tabs: const [
                        Tab(text: 'Theo ngày'),
                        Tab(text: 'Báo cáo'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // TabBarView
            const Expanded(
              child: TabBarView(
                children: [
                  DailyHistoryScreen(),
                  ReportScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
