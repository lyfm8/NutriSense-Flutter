import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Báo cáo thống kê', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Card
            Card(
              elevation: 12,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppColors.indigo600, AppColors.blue600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.emoji_events, color: AppColors.white),
                        SizedBox(width: 8),
                        Text('Tổng quan 7 ngày', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryItem('Trung bình calo', '1954', 'kcal/ngày'),
                        const SizedBox(width: 8),
                        _buildSummaryItem('Trung bình nước', '2043', 'ml/ngày'),
                        const SizedBox(width: 8),
                        _buildSummaryItem('Trung bình protein', '96', 'g/ngày'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Calories Chart Card
            _buildChartCard('Calo 7 ngày', AppColors.blue600),
            
            // Water Chart Card
            _buildChartCard('Nước uống 7 ngày', AppColors.cyan600),

            // Protein Chart Card
            _buildChartCard('Protein 7 ngày', AppColors.orange600),
            
            // Full Report Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.blue600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Xem báo cáo đầy đủ (AI)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(color: AppColors.white.withOpacity(0.75), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Color barColor) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: AppColors.gray900, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text('[Biểu đồ $title]', style: const TextStyle(color: AppColors.gray400)),
            ),
          ],
        ),
      ),
    );
  }
}
