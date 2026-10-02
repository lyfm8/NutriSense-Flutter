import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/daily_summary.dart';

class DailyHistoryScreen extends StatefulWidget {
  const DailyHistoryScreen({super.key});

  @override
  State<DailyHistoryScreen> createState() => _DailyHistoryScreenState();
}

class _DailyHistoryScreenState extends State<DailyHistoryScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  final List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      final now = DateTime.now();
      final List<Map<String, dynamic>> data = [];

      // Fetch last 7 days
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        
        final summary = await _apiService.getDailySummary(userId, dateStr);
        data.add({
          'date': date,
          'summary': summary,
        });
      }

      if (mounted) {
        setState(() {
          _historyData.clear();
          _historyData.addAll(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load history error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDayName(DateTime date) {
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    
    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Hôm qua';
    
    return DateFormat('EEEE', 'vi').format(date);
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue600))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: AppColors.blue600,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _historyData.length,
                itemBuilder: (context, index) {
                  final item = _historyData[index];
                  final date = item['date'] as DateTime;
                  final summary = item['summary'] as DailySummary;
                  
                  return _buildDailyCard(
                    dayName: _formatDayName(date),
                    date: DateFormat('d MMMM, yyyy', 'vi').format(date),
                    cal: (summary.totalCalories ?? 0).toInt().toString(),
                    water: (summary.totalWaterMl ?? 0).toInt().toString(),
                    meals: '-', // Meal count is not in DailySummary currently
                  );
                },
              ),
            ),
    );
  }

  Widget _buildDailyCard({
    required String dayName, 
    required String date, 
    required String cal, 
    required String water, 
    required String meals,
  }) {
    return Card(
      elevation: 4,
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
                // Meals Info (Placeholder or fetched from other source if needed)
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
          ],
        ),
      ),
    );
  }
}
