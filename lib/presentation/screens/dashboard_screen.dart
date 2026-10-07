import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/daily_summary.dart';
import '../../data/models/food_entry_item.dart';
import '../../data/models/user_profile.dart';
import 'meal_detail_screen.dart';

/// Dashboard chính – Tương đương MainActivity.java
/// Cập nhật: Thêm hiển thị Popup chúc mừng đạt mục tiêu Nước và Calo
class DashboardScreen extends StatefulWidget {
  final bool isActive;

  const DashboardScreen({super.key, this.isActive = true});

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
    'BREAKFAST': 0, 'LUNCH': 0, 'SNACK': 0, 'DINNER': 0,
  };
  String _todayDate = '';

  // Biến lưu Macro cộng dồn để backup
  double _dynProtein = 0;
  double _dynCarbs = 0;
  double _dynFat = 0;

  // Cờ để đánh dấu đã show popup chúc mừng trong phiên hiện tại (tránh show liên tục)
  bool _hasShownWaterCongrats = false;
  bool _hasShownCalorieCongrats = false;

  @override
  void initState() {
    super.initState();
    _todayDate = _formatDate(DateTime.now());
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Reset ngày hiện tại và kiểm tra nếu qua ngày mới
      final currentDate = _formatDate(DateTime.now());
      if (_todayDate != currentDate) {
        _todayDate = currentDate;
        // Chuyển qua ngày mới thì reset cờ chúc mừng
        _hasShownWaterCongrats = false;
        _hasShownCalorieCongrats = false;
      }
      _loadData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    const weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    const months = ['tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6', 'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'];
    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}, ${date.year}';
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

      DailySummary summary = DailySummary.empty;
      UserProfile? profile;
      final Map<String, int> mealCals = {
        'BREAKFAST': 0, 'LUNCH': 0, 'SNACK': 0, 'DINNER': 0,
      };

      try {
        summary = await _apiService.getDailySummary(userId, _todayDate);
      } catch (e) {
        debugPrint('[Dashboard] getDailySummary ERROR: $e');
      }

      try {
        profile = await _apiService.getUserProfile(userId);
      } catch (e) {
        debugPrint('[Dashboard] getUserProfile ERROR: $e');
      }

      int sumCal(List<FoodEntryItem> items) =>
          items.fold<double>(0.0, (sum, e) => sum + e.displayCalories).toInt();

      double tempPro = 0, tempCarb = 0, tempFat = 0;

      for (final mealType in ['BREAKFAST', 'LUNCH', 'SNACK', 'DINNER']) {
        try {
          final items = await _apiService.getMealItems(
            userId: userId, date: _todayDate, mealType: mealType,
          );
          mealCals[mealType] = sumCal(items);

          for (var item in items) {
            tempPro += item.proteinG ?? 0.0;
            tempCarb += item.carbsG ?? 0.0;
            tempFat += item.fatG ?? 0.0;
          }
        } catch (e) {
          debugPrint('[Dashboard] getMealItems($mealType) ERROR: $e');
        }
      }

      if (mounted) {
        setState(() {
          _summary = summary;
          _userProfile = profile;
          _mealCalories = mealCals;
          _dynProtein = tempPro;
          _dynCarbs = tempCarb;
          _dynFat = tempFat;
          _isLoading = false;
        });

        // ================= KIỂM TRA CHÚC MỪNG CALO SAU KHI TẢI DỮ LIỆU =================
        _checkAndShowCalorieCongrats();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM KIỂM TRA VÀ HIỂN THỊ CHÚC MỪNG CALO ---
  void _checkAndShowCalorieCongrats() {
    if (_userProfile == null || _hasShownCalorieCongrats) return;

    final calorieGoal = _userProfile!.dailyCalorieGoal ?? 2000;
    final dynCal = _mealCalories.values.fold(0, (a, b) => a + b);
    final consumed = (_summary.totalCalories ?? 0) > 0 ? _summary.totalCalories! : dynCal;

    // Nếu đạt từ 100% mục tiêu calo
    if (consumed > 0 && consumed >= calorieGoal) {
      _hasShownCalorieCongrats = true;
      _showCongratsDialog(
        title: 'Tuyệt vời! 🥗',
        message: 'Bạn đã đạt mục tiêu Calo trong ngày hôm nay ($consumed / $calorieGoal kcal).\nHãy tiếp tục duy trì thói quen tốt nhé!',
        color: AppColors.orange600,
        icon: Icons.local_fire_department,
      );
    }
  }

  // --- HÀM HIỂN THỊ POPUP NƯỚC ĐÃ SỬA ---
  Future<void> _showAddWaterDialog() async {
    int selectedAmount = 250;
    final userId = await SessionManager.getUserId();
    if (userId == null || !mounted) return;

    final options = [150, 200, 250, 300, 350, 500];

    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.cyan600),
              SizedBox(width: 8),
              Text('Thêm nước uống', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Chọn lượng nước (ml):', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
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
              child: Text('Hủy', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  // Mở loading tạm thời
                  setState(() => _isLoading = true);

                  await _apiService.addWater(userId, selectedAmount);

                  // Lấy dữ liệu mới
                  DailySummary updatedSummary = await _apiService.getDailySummary(userId, _todayDate);

                  if (mounted) {
                    setState(() {
                      _summary = updatedSummary;
                      _isLoading = false;
                    });

                    // ================= KIỂM TRA CHÚC MỪNG NƯỚC SAU KHI THÊM =================
                    _checkAndShowWaterCongrats();
                  }
                } catch (_) {
                  if (mounted) {
                    setState(() => _isLoading = false);
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

  // --- HÀM KIỂM TRA VÀ HIỂN THỊ CHÚC MỪNG NƯỚC ---
  void _checkAndShowWaterCongrats() {
    if (_userProfile == null || _hasShownWaterCongrats) return;

    final waterGoal = _userProfile!.waterGoalMl ?? 2000;
    final waterConsumed = _summary.totalWaterMl ?? 0;

    // Nếu đạt từ 100% mục tiêu nước
    if (waterConsumed > 0 && waterConsumed >= waterGoal) {
      _hasShownWaterCongrats = true;
      _showCongratsDialog(
        title: 'Hoàn thành xuất sắc! 💧',
        message: 'Bạn đã hoàn thành mục tiêu uống đủ $waterGoal ml nước hôm nay.\nCơ thể bạn đang rất biết ơn bạn đó!',
        color: AppColors.cyan600,
        icon: Icons.water_drop,
      );
    }
  }

  // --- DIALOG CHÚC MỪNG CHUNG ---
  void _showCongratsDialog({required String title, required String message, required Color color, required IconData icon}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48)
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToMealDetail(String mealType, String mealName) {
    Navigator.of(context, rootNavigator: true).push(
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
    // ... BÊN DƯỚI ĐÂY LÀ GIAO DIỆN KHÔNG THAY ĐỔI THEO FILE CỦA BẠN ...
    final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;
    final waterGoal = _userProfile?.waterGoalMl ?? 2000;

    final dynCal = _mealCalories.values.fold(0, (a, b) => a + b);
    final consumed = (_summary.totalCalories ?? 0) > 0 ? _summary.totalCalories! : dynCal;
    final waterConsumed = _summary.totalWaterMl ?? 0;

    final proteinConsumed = ((_summary.totalProteinG ?? 0) > 0 ? _summary.totalProteinG! : _dynProtein).round();
    final carbConsumed = ((_summary.totalCarbsG ?? 0) > 0 ? _summary.totalCarbsG! : _dynCarbs).round();
    final fatConsumed = ((_summary.totalFatG ?? 0) > 0 ? _summary.totalFatG! : _dynFat).round();

    final calorieProgress = calorieGoal > 0 ? (consumed / calorieGoal).clamp(0.0, 1.0) : 0.0;
    final waterProgress = waterGoal > 0 ? (waterConsumed / waterGoal).clamp(0.0, 1.0) : 0.0;

    // Sửa lại tỷ lệ phần trăm: 30% Pro, 40% Carbs, 30% Fat
    final proteinGoal = ((calorieGoal * 0.30) / 4).round();
    final carbGoal = ((calorieGoal * 0.40) / 4).round();
    final fatGoal = ((calorieGoal * 0.30) / 9).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.blue600, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'NutriSense AI',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDisplayDate(DateTime.now()),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                    if (_userProfile?.displayName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Xin chào, ${_userProfile!.displayName}!',
                          style: const TextStyle(color: AppColors.blue600, fontWeight: FontWeight.bold, fontSize: 13),
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
                      gradient: const LinearGradient(colors: [AppColors.orange500, AppColors.orange700], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                                      Text('$consumed', style: const TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text('/ $calorieGoal', style: const TextStyle(color: AppColors.white90, fontSize: 20)),
                                      ),
                                    ],
                                  ),
                                  const Text('kcal', style: TextStyle(color: AppColors.white80, fontSize: 14)),
                                ],
                              ),
                            ),
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withOpacity(0.2)),
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
                            Text('Còn lại: ${(calorieGoal - consumed).clamp(0, calorieGoal)} kcal', style: const TextStyle(color: AppColors.white90, fontSize: 14)),
                            Text('${(calorieProgress * 100).round()}%', style: const TextStyle(color: AppColors.white80, fontSize: 14)),
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
                      gradient: const LinearGradient(colors: [AppColors.cyan600, AppColors.blue600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withOpacity(0.2)),
                              child: const Icon(Icons.water_drop, color: AppColors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nước uống', style: TextStyle(color: AppColors.white90, fontSize: 14)),
                                  Text('$waterConsumed / $waterGoal ml', style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _showAddWaterDialog,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.white, shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
                              child: const Text('+', style: TextStyle(color: AppColors.cyan600, fontSize: 24)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: waterProgress, backgroundColor: AppColors.white20, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white), minHeight: 12, borderRadius: BorderRadius.circular(6)),
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chất dinh dưỡng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
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
                Text('Bữa ăn hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
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
            Text(name, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
            Text('${consumed}g / ${goal}g', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, backgroundColor: bgColor, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 12, borderRadius: BorderRadius.circular(6)),
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
                    Text(cal > 0 ? 'Bấm để xem chi tiết' : 'Chưa có dữ liệu – Bấm để thêm', style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text('$cal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue600)),
                    Text('kcal', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
               Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
            ],
          ),
        ),
      ),
    );
  }
}