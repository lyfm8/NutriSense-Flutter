import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_client.dart'; // Thay đổi import sang api_client

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = true;
  DateTime _endDate = DateTime.now();
  late DateTime _startDate;

  // Sử dụng Map<String, dynamic> chuẩn để chứa dữ liệu JSON gốc từ Backend
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _startDate = _endDate.subtract(const Duration(days: 6)); // Lấy 7 ngày
    _loadReportData();
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  Future<void> _loadReportData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      final startStr = _formatDateForApi(_startDate);
      final endStr = _formatDateForApi(_endDate);

      // SỬ DỤNG TRỰC TIẾP ApiClient ĐỂ LẤY JSON GỐC TỪ DIO (Bỏ qua class DashboardDto)
      final response = await ApiClient.instance.get(
        'api/reports/dashboard',
        queryParameters: {
          'userId': userId,
          'startDate': startStr,
          'endDate': endStr,
        },
      );

      if (mounted) {
        setState(() {
          // Lấy dữ liệu raw Map an toàn
          _reportData = response.data as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ReportScreen] ERROR: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeWeek(int weeks) {
    setState(() {
      _endDate = _endDate.add(Duration(days: weeks * 7));
      _startDate = _endDate.subtract(const Duration(days: 6));
    });
    _loadReportData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadReportData,
      color: AppColors.blue600,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // Bắt buộc ReportScreen lấy nền hệ thống
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Week Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor), // Màu động cho viền
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor, // Sử dụng màu cardColor đã định nghĩa trong main.dart
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.blue600),
                      onPressed: () => _changeWeek(-1),
                    ),
                    Text(
                      'Tuần: ${_formatDateForDisplay(_startDate)} - ${_formatDateForDisplay(_endDate)}',
                      // MỚI
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.blue600),
                      onPressed: _endDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                          ? () => _changeWeek(1)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.blue600),
                )
              else if (_reportData != null)
                Column(
                  children: [
                    // Tổng quan Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        // MỚI
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.assessment, color: AppColors.blue600),
                                const SizedBox(width: 8),
                                Text('Trung bình mỗi ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildAvgItem('Calo', '${_reportData!['avgCalories'] ?? 0}', 'kcal', AppColors.orange600),
                                _buildAvgItem('Nước', '${((_reportData!['avgWaterLiters'] ?? 0) as num).toStringAsFixed(1)}', 'Lít', AppColors.cyan600),
                                _buildAvgItem('Protein', '${((_reportData!['avgProtein'] ?? 0) as num).round()}', 'g', AppColors.rose600),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biểu đồ Calo 7 ngày
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Biểu đồ Nạp Calo trong tuần', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: _buildBarChart(_reportData!['chartData'] as List<dynamic>?),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Macro Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng Đa lượng chất (Tuần)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 16),
                            _buildProgressRow('🥩 Protein', _reportData!['totalProtein'], _reportData!['targetProtein'], AppColors.orange600, AppColors.orange100),
                            _buildProgressRow('🍚 Carbs', _reportData!['totalCarbs'], _reportData!['targetCarbs'], AppColors.amber600, AppColors.yellow100),
                            _buildProgressRow('🥑 Chất béo', _reportData!['totalFat'], _reportData!['targetFat'], AppColors.rose600, AppColors.red100),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  // MỚI
  Widget _buildAvgItem(String title, String value, String unit, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(unit, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 10)),
      ],
    );
  }

  Widget _buildProgressRow(String title, dynamic total, dynamic target, Color color, Color bgColor) {
    final double t = total != null ? (total as num).toDouble() : 0.0;
    final double tar = target != null ? (target as num).toDouble() : 1.0;
    final progress = tar > 0 ? (t / tar).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // MỚI (Loại bỏ 'const' trước TextStyle và thêm Theme color)
              Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              Text('${t.round()} / ${tar.round()}g', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic>? chartDataList) {
    if (chartDataList == null || chartDataList.isEmpty) return const SizedBox();

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < chartDataList.length; i++) {
      final dynamic item = chartDataList[i];
      double cal = 0;

      // Do lấy raw JSON nên chắc chắn item là Map
      if (item is Map) {
        cal = (item['calories'] as num?)?.toDouble() ?? 0.0;
      }

      if (cal > maxY) maxY = cal;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: cal,
              color: AppColors.blue600,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY * 1.2 : 2000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartDataList.length) {
                  final dynamic item = chartDataList[value.toInt()];
                  String dateStr = '';

                  if (item is Map) {
                    dateStr = item['date'] ?? '';
                  }

                  if(dateStr.isNotEmpty) {
                    try {
                      final date = DateTime.parse(dateStr);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd/MM').format(date),
                          // MỚI
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 10),
                        ),
                      );
                    } catch(e) {
                      // Bỏ qua lỗi parse date
                    }
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          // MỚI
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}