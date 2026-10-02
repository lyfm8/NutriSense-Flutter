import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/daily_summary.dart';
import '../../data/models/food_entry_item.dart';
import '../../data/models/user_profile.dart';
import 'meal_detail_screen.dart';

/// Dashboard chính – Tương đương MainActivity.java
/// Sprint 3.1: kết nối API thật, hiển thị calo/nước/macro động
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();

  // State
  bool _isLoading = true;
  DailySummary _summary = DailySummary.empty;
  UserProfile? _userProfile;
  Map<String, int> _mealCalories = {
    'BREAKFAST': 0,
    'LUNCH': 0,
    'SNACK': 0,
    'DINNER': 0,
  };
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _todayDate = _formatDate(DateTime.now());
    _loadData();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    const weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    const months = ['tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6',
      'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'];
    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      // Gọi song song tất cả API
      final results = await Future.wait([
        _apiService.getDailySummary(userId, _todayDate),
        _apiService.getUserProfile(userId),
        _apiService.getMealItems(userId: userId, date: _todayDate, mealType: 'BREAKFAST'),
        _apiService.getMealItems(userId: userId, date: _todayDate, mealType: 'LUNCH'),
        _apiService.getMealItems(userId: userId, date: _todayDate, mealType: 'SNACK'),
        _apiService.getMealItems(userId: userId, date: _todayDate, mealType: 'DINNER'),
      ]);

      final summary = results[0] as DailySummary;
      final profile = results[1] as UserProfile;
      final breakfast = results[2] as List<FoodEntryItem>;
      final lunch = results[3] as List<FoodEntryItem>;
      final snack = results[4] as List<FoodEntryItem>;
      final dinner = results[5] as List<FoodEntryItem>;

      int sumCal(List<FoodEntryItem> items) =>
          items.fold<double>(0.0, (sum, e) => sum + (e.calories ?? 0.0)).toInt();


      if (mounted) {
        setState(() {
          _summary = summary;
          _userProfile = profile;
          _mealCalories = {
            'BREAKFAST': sumCal(breakfast),
            'LUNCH': sumCal(lunch),
            'SNACK': sumCal(snack),
            'DINNER': sumCal(dinner),
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddWaterDialog() async {
    int selectedAmount = 250;
    final userId = await SessionManager.getUserId();
    if (userId == null || !mounted) return;

    final options = [150, 200, 250, 300, 350, 500];

    await showDialog(
      context: context,
      useRootNavigator: true, // Fix: thoát khỏi context của BottomNav
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.water_drop, color: AppColors.cyan600),
              SizedBox(width: 8),
              Text('Thêm nước uống', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn lượng nước (ml):', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((amount) {
                  final selected = selectedAmount == amount;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedAmount = amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.cyan600 : AppColors.gray100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$amount ml',
                        style: TextStyle(
                          color: selected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _apiService.addWater(userId, selectedAmount);
                  _loadData(); // Reload để cập nhật UI
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể thêm nước. Thử lại sau.')),
                    );
                  }
                }
              },
              child: const Text('Xác nhận', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMealDetail(String mealType, String mealName) {
    Navigator.of(context, rootNavigator: true).push( // Fix: dùng root navigator
      MaterialPageRoute(
        builder: (_) => MealDetailScreen(
          mealType: mealType,
          mealName: mealName,
          date: _todayDate,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;
    final waterGoal = _userProfile?.waterGoalMl ?? 2000;
    final consumed = _summary.totalCalories ?? 0;
    final waterConsumed = _summary.totalWaterMl ?? 0;
    final calorieProgress = calorieGoal > 0 ? (consumed / calorieGoal).clamp(0.0, 1.0) : 0.0;
    final waterProgress = waterGoal > 0 ? (waterConsumed / waterGoal).clamp(0.0, 1.0) : 0.0;

    final proteinGoal = ((calorieGoal * 0.25) / 4).round();
    final carbGoal = ((calorieGoal * 0.50) / 4).round();
    final fatGoal = ((calorieGoal * 0.25) / 9).round();
    final proteinConsumed = (_summary.totalProteinG ?? 0).round();
    final carbConsumed = (_summary.totalCarbsG ?? 0).round();
    final fatConsumed = (_summary.totalFatG ?? 0).round();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.blue600,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.blue600))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                    'NutriSense AI',
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
                                _formatDisplayDate(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (_userProfile?.displayName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.blue50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Xin chào, ${_userProfile!.displayName}!',
                                style: const TextStyle(
                                  color: AppColors.blue600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Calorie Card
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
                                            Text(
                                              '$consumed',
                                              style: const TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                '/ $calorieGoal',
                                                style: const TextStyle(color: AppColors.white90, fontSize: 20),
                                              ),
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
                                value: calorieProgress,
                                backgroundColor: AppColors.white20,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Còn lại: ${(calorieGoal - consumed).clamp(0, calorieGoal)} kcal',
                                    style: const TextStyle(color: AppColors.white90, fontSize: 14),
                                  ),
                                  Text(
                                    '${(calorieProgress * 100).round()}%',
                                    style: const TextStyle(color: AppColors.white80, fontSize: 14),
                                  ),
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
                                        Text(
                                          '$waterConsumed / $waterGoal ml',
                                          style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _showAddWaterDialog,
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
                                value: waterProgress,
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
                              const Text(
                                'Chất dinh dưỡng',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 16),
                              _buildNutrientRow('Protein', proteinConsumed, proteinGoal, AppColors.orange600, AppColors.orange100),
                              const SizedBox(height: 16),
                              _buildNutrientRow('Carbs', carbConsumed, carbGoal, AppColors.amber600, AppColors.yellow100),
                              const SizedBox(height: 16),
                              _buildNutrientRow('Chất béo', fatConsumed, fatGoal, AppColors.rose600, AppColors.red100),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Meals
                      const Text(
                        'Bữa ăn hôm nay',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),

                      _buildMealItem('Bữa sáng', 'BREAKFAST', Icons.wb_sunny_outlined),
                      _buildMealItem('Bữa trưa', 'LUNCH', Icons.lunch_dining_outlined),
                      _buildMealItem('Bữa phụ', 'SNACK', Icons.apple_outlined),
                      _buildMealItem('Bữa tối', 'DINNER', Icons.nights_stay_outlined),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, int consumed, int goal, Color color, Color bgColor) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            Text(
              '${consumed}g / ${goal}g',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: bgColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildMealItem(String mealName, String mealType, IconData icon) {
    final cal = _mealCalories[mealType] ?? 0;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToMealDetail(mealType, mealName),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.blue600, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mealName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      cal > 0 ? 'Bấm để xem chi tiết' : 'Chưa có dữ liệu – Bấm để thêm',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
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
                    Text(
                      '$cal',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue600),
                    ),
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
