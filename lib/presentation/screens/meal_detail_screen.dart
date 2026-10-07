import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/food_entry_item.dart';
import 'ai_analysis_screen.dart';

/// Màn hình Chi tiết Bữa ăn – Tương đương MealDetailActivity.java
/// Sprint 3.2: Load danh sách món, xóa món
class MealDetailScreen extends StatefulWidget {
  final String mealType;   // 'BREAKFAST' | 'LUNCH' | 'SNACK' | 'DINNER'
  final String mealName;   // 'Bữa sáng' | 'Bữa trưa' | 'Bữa phụ' | 'Bữa tối'
  final String date;       // 'yyyy-MM-dd'

  const MealDetailScreen({
    super.key,
    required this.mealType,
    required this.mealName,
    required this.date,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final _apiService = ApiService();

  bool _isLoading = true;
  List<FoodEntryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      final items = await _apiService.getMealItems(
        userId: userId,
        date: widget.date,
        mealType: widget.mealType,
      );

      if (mounted) setState(() => _items = items);
    } catch (_) {
      // Hiện empty state nếu lỗi
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(FoodEntryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa món ăn?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa "${item.foodName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteMealItem(item.id!);
      _loadItems(); // Reload
    } catch (e) {
      debugPrint('[MealDetail] Delete item error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa. Thử lại sau: $e')),
        );
      }
    }
  }

  // Tổng dinh dưỡng
  int get _totalCalories => _items.fold<double>(0.0, (sum, e) => sum + e.displayCalories).toInt();
  double get _totalProtein => _items.fold(0.0, (sum, e) => sum + (e.proteinG ?? 0.0));
  double get _totalCarbs => _items.fold(0.0, (sum, e) => sum + (e.carbsG ?? 0.0));
  double get _totalFat => _items.fold(0.0, (sum, e) => sum + (e.fatG ?? 0.0));

  String _formatDisplayDate(String date) {
    final parts = date.split('-');
    if (parts.length < 3) return date;
    return '${int.parse(parts[2])} tháng ${int.parse(parts[1])}, ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadItems,
        color: AppColors.blue600,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header gradient
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
                        Text(
                          widget.mealName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60, top: 4),
                      child: Text(
                        _formatDisplayDate(widget.date),
                        style: const TextStyle(color: AppColors.white80, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Card
              if (_items.isNotEmpty)
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
                                    children: [
                                      Text(
                                        '$_totalCalories',
                                        style: const TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 4),
                                      const Padding(
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
                            _buildNutrientBox('Protein', '${_totalProtein.toStringAsFixed(1)}g'),
                            const SizedBox(width: 8),
                            _buildNutrientBox('Carbs', '${_totalCarbs.toStringAsFixed(1)}g'),
                            const SizedBox(width: 8),
                            _buildNutrientBox('Chất béo', '${_totalFat.toStringAsFixed(1)}g'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Header list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chi tiết món ăn (${_items.length})',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AiAnalysisScreen()),
                        );
                        // Tải lại danh sách món ăn khi quay lại
                        if (mounted) {
                          _loadItems();
                        }
                      },
                      icon: const Icon(Icons.add, color: AppColors.blue600, size: 18),
                      label: const Text('Thêm bằng AI', style: TextStyle(color: AppColors.blue600, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Content
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.blue600),
                )
              else if (_items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu, size: 64, color: AppColors.gray300),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có món ăn nào.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bấm "Thêm" hoặc dùng AI để ghi lại bữa ăn.',
                        style: TextStyle(color: AppColors.gray400, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) => _buildFoodItem(_items[i]),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItem(FoodEntryItem item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.orange100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fastfood_outlined, color: AppColors.orange600, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.foodName,

                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniTag('P: ${(item.proteinG ?? 0).toStringAsFixed(1)}g', AppColors.orange600),
                      const SizedBox(width: 6),
                      _buildMiniTag('C: ${(item.carbsG ?? 0).toStringAsFixed(1)}g', AppColors.amber600),
                      const SizedBox(width: 6),
                      _buildMiniTag('F: ${(item.fatG ?? 0).toStringAsFixed(1)}g', AppColors.rose600),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.displayCalories.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue600,
                  ),
                ),
                Text('kcal', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _deleteItem(item),
              icon: const Icon(Icons.delete_outline, color: AppColors.red600, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
