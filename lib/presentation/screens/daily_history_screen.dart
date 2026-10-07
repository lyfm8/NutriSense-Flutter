import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/daily_summary.dart';
import '../../data/models/food_entry_item.dart';
import 'meal_detail_screen.dart';

class DailyHistoryScreen extends StatefulWidget {
  const DailyHistoryScreen({super.key});

  @override
  State<DailyHistoryScreen> createState() => _DailyHistoryScreenState();
}

class _DailyHistoryScreenState extends State<DailyHistoryScreen> {
  final _apiService = ApiService();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  DailySummary _summary = DailySummary.empty;

  // Lưu lượng calo của từng bữa ăn trong ngày
  Map<String, int> _mealCalories = {
    'BREAKFAST': 0, 'LUNCH': 0, 'SNACK': 0, 'DINNER': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final difference = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference == 0) {
      return 'Hôm nay, ${DateFormat('d \'Tháng\' M').format(date)}';
    } else if (difference == -1) {
      return 'Hôm qua, ${DateFormat('d \'Tháng\' M').format(date)}';
    } else {
      return DateFormat('EEEE, d \'Tháng\' M, yyyy', 'vi_VN').format(date);
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final dateStr = _formatDateForApi(_selectedDate);
      final summary = await _apiService.getDailySummary(userId, dateStr);

      // BỔ SUNG LẤY DỮ LIỆU TỪNG BỮA ĂN
      final Map<String, int> mealCals = {
        'BREAKFAST': 0, 'LUNCH': 0, 'SNACK': 0, 'DINNER': 0,
      };

      int sumCal(List<FoodEntryItem> items) =>
          items.fold<double>(0.0, (sum, e) => sum + e.displayCalories).toInt();

      for (final mealType in ['BREAKFAST', 'LUNCH', 'SNACK', 'DINNER']) {
        try {
          final items = await _apiService.getMealItems(
            userId: userId, date: dateStr, mealType: mealType,
          );
          mealCals[mealType] = sumCal(items);
        } catch (e) {
          debugPrint('[DailyHistory] getMealItems($mealType) ERROR: $e');
        }
      }

      if (mounted) {
        setState(() {
          _summary = summary;
          _mealCalories = mealCals;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[DailyHistory] ERROR: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
              primary: AppColors.blue600,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            )
                : const ColorScheme.light(
              primary: AppColors.blue600,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  void _navigateToMealDetail(String mealType, String mealName) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => MealDetailScreen(
          mealType: mealType,
          mealName: mealName,
          date: _formatDateForApi(_selectedDate),
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.blue600,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.blue600),
                    onPressed: () => _changeDate(-1),
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      _formatDisplayDate(_selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.blue600),
                    onPressed: _selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                        ? () => _changeDate(1)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.blue600),
                ),
              )
            else if ((_summary.totalCalories == null || _summary.totalCalories == 0) &&
                (_summary.totalWaterMl == null || _summary.totalWaterMl == 0))
            // Empty State
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: AppColors.gray400),
                      const SizedBox(height: 16),
                       Text(
                        'Chưa có dữ liệu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 8),
                       Text(
                        'Ngày này bạn không ghi nhận bữa ăn hay nước uống nào.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [AppColors.indigo600, AppColors.blue600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng nạp', style: TextStyle(color: AppColors.white90, fontSize: 14)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_summary.totalCalories ?? 0}',
                                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6.0, left: 4.0),
                                child: Text('kcal', style: TextStyle(color: AppColors.white90, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMacroItem('Protein', '${_summary.totalProteinG?.round() ?? 0}g'),
                              _buildMacroItem('Carbs', '${_summary.totalCarbsG?.round() ?? 0}g'),
                              _buildMacroItem('Chất béo', '${_summary.totalFatG?.round() ?? 0}g'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.white20, thickness: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.water_drop, color: Colors.cyanAccent, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${_summary.totalWaterMl ?? 0} ml', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.restaurant, color: Colors.orangeAccent, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${_summary.numMeals ?? 0} bữa', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                   Text(
                      'Chi tiết bữa ăn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                  ),
                  const SizedBox(height: 12),

                  // Hiển thị danh sách các bữa ăn
                  _buildMealItem('Bữa sáng', 'BREAKFAST', Icons.wb_sunny_outlined),
                  _buildMealItem('Bữa trưa', 'LUNCH', Icons.lunch_dining_outlined),
                  _buildMealItem('Bữa phụ', 'SNACK', Icons.apple_outlined),
                  _buildMealItem('Bữa tối', 'DINNER', Icons.nights_stay_outlined),
                ],
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildMacroItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.white80, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMealItem(String mealName, String mealType, IconData icon) {
    final cal = _mealCalories[mealType] ?? 0;

    // Nếu ngày trong quá khứ mà bữa đó = 0 calo thì bỏ qua không hiển thị (giống bản Android cũ)
    // Nếu muốn hiển thị tất cả dù trống thì bỏ dòng if này đi
    if (cal == 0) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToMealDetail(mealType, mealName),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).cardColor),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.blue600, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mealName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 2),
                     Text('Bấm để xem chi tiết', style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text('$cal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue600)),
                    const Text('kcal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}