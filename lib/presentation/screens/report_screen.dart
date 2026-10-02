import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/dashboard_dto.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  DashboardDto? _dashboard;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      final now = DateTime.now();
      final startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 6)));
      final endDate = DateFormat('yyyy-MM-dd').format(now);

      final dashboard = await _apiService.getDashboardReport(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load report error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue600))
          : RefreshIndicator(
              onRefresh: _loadReport,
              color: AppColors.blue600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                _buildSummaryItem('Trung bình calo', '${_dashboard?.avgCalories?.toInt() ?? 0}', 'kcal/ngày'),
                                const SizedBox(width: 8),
                                _buildSummaryItem('Trung bình nước', '${_dashboard?.avgWater?.toInt() ?? 0}', 'ml/ngày'),
                                const SizedBox(width: 8),
                                _buildSummaryItem('Trung bình protein', '${_dashboard?.avgProtein?.toInt() ?? 0}', 'g/ngày'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Calories Line Chart Card
                    if (_dashboard?.dailyCalories != null && _dashboard!.dailyCalories!.isNotEmpty)
                      _buildCalorieChartCard('Calo 7 ngày', AppColors.blue600, _dashboard!.dailyCalories!),
                    
                    // Macros Pie Chart Card
                    if (_dashboard != null)
                      _buildMacroPieChartCard('Tỉ lệ dinh dưỡng trung bình', _dashboard!),

                    const SizedBox(height: 32),
                  ],
                ),
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

  Widget _buildCalorieChartCard(String title, Color barColor, List<DailyCalorieEntry> dailyCalories) {
    List<FlSpot> spots = [];
    double maxCal = 0;
    
    for (int i = 0; i < dailyCalories.length; i++) {
      double cal = dailyCalories[i].calories ?? 0;
      if (cal > maxCal) maxCal = cal;
      spots.add(FlSpot(i.toDouble(), cal));
    }

    if (maxCal == 0) maxCal = 2500;

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
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (dailyCalories.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxCal * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: barColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: barColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < dailyCalories.length) {
                            String? dateStr = dailyCalories[index].date;
                            if (dateStr != null && dateStr.length >= 10) {
                              // yyyy-MM-dd
                              String day = dateStr.substring(8, 10);
                              String month = dateStr.substring(5, 7);
                              return Text('$day/$month', style: const TextStyle(fontSize: 10));
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 500,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPieChartCard(String title, DashboardDto dashboard) {
    double protein = dashboard.avgProtein ?? 0;
    double carbs = dashboard.avgCarbs ?? 0;
    double fat = dashboard.avgFat ?? 0;
    
    double total = protein + carbs + fat;
    if (total == 0) return const SizedBox();

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
                    color: AppColors.orange600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: AppColors.gray900, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.orange600,
                      value: protein,
                      title: '${((protein/total)*100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.amber600,
                      value: carbs,
                      title: '${((carbs/total)*100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.rose600,
                      value: fat,
                      title: '${((fat/total)*100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIndicator(AppColors.orange600, 'Protein'),
                _buildIndicator(AppColors.amber600, 'Carbs'),
                _buildIndicator(AppColors.rose600, 'Fat'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray700)),
      ],
    );
  }
}
