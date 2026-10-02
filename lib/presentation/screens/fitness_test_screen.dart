import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/exercise_test.dart';

class FitnessTestScreen extends StatefulWidget {
  const FitnessTestScreen({super.key});

  @override
  State<FitnessTestScreen> createState() => _FitnessTestScreenState();
}

class _FitnessTestScreenState extends State<FitnessTestScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<ExerciseTest> _recentTests = [];

  @override
  void initState() {
    super.initState();
    _loadRecentTests();
  }

  Future<void> _loadRecentTests() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;
      
      final tests = await _apiService.getRecentFitnessTests(userId);
      if (mounted) {
        setState(() {
          _recentTests = tests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load fitness error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddTestDialog(String exerciseType) {
    final ctrl1 = TextEditingController();
    final ctrl2 = TextEditingController();
    
    String label1 = '';
    String label2 = '';
    
    if (exerciseType == 'Hít đất' || exerciseType == 'Gập bụng') {
      label1 = 'Số lần';
    } else if (exerciseType == 'Chạy 1km') {
      label1 = 'Quãng đường (km)';
      label2 = 'Thời gian (giây)';
    } else if (exerciseType == 'Plank') {
      label1 = 'Thời gian (giây)';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ghi nhận $exerciseType', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrl1, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label1)),
            if (label2.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextField(controller: ctrl2, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label2)),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: AppColors.gray500))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final userId = await SessionManager.getUserId();
              if (userId == null) return;

              int? pushUps, sitUps, runTime;
              double? runDist;

              if (exerciseType == 'Hít đất') pushUps = int.tryParse(ctrl1.text);
              if (exerciseType == 'Gập bụng') sitUps = int.tryParse(ctrl1.text);
              if (exerciseType == 'Chạy 1km') {
                runDist = double.tryParse(ctrl1.text);
                runTime = int.tryParse(ctrl2.text);
              }
              if (exerciseType == 'Plank') runTime = int.tryParse(ctrl1.text); // Using runTime to store plank time temporarily

              final test = ExerciseTest(
                userId: userId,
                testDate: DateTime.now().toIso8601String().split('T')[0],
                pushUps: pushUps,
                sitUps: sitUps,
                runDistanceKm: runDist,
                runTimeSeconds: runTime,
                notes: exerciseType,
              );

              setState(() => _isLoading = true);
              try {
                await _apiService.logFitnessTest(test);
                _loadRecentTests();
              } catch (e) {
                debugPrint('Log test error: $e');
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _buildExerciseCard('Hít đất', 'Số lần hít đất liên tục', Icons.fitness_center, AppColors.blue600, () => _showAddTestDialog('Hít đất')),
                _buildExerciseCard('Chạy 1km', 'Thời gian chạy 1km', Icons.directions_run, AppColors.cyan600, () => _showAddTestDialog('Chạy 1km')),
                _buildExerciseCard('Plank', 'Thời gian giữ tư thế plank', Icons.timer, AppColors.indigo400, () => _showAddTestDialog('Plank')),
                _buildExerciseCard('Gập bụng', 'Số lần gập bụng / 1 phút', Icons.trending_up, AppColors.indigo600, () => _showAddTestDialog('Gập bụng')),
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
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Lịch sử bài test',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_recentTests.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('Chưa có dữ liệu bài test nào.')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentTests.length,
                        itemBuilder: (context, index) {
                          final test = _recentTests[index];
                          String details = '';
                          if (test.pushUps != null) details += 'Hít đất: ${test.pushUps} lần ';
                          if (test.sitUps != null) details += 'Gập bụng: ${test.sitUps} lần ';
                          if (test.runDistanceKm != null) details += 'Chạy: ${test.runDistanceKm}km ';
                          if (test.runTimeSeconds != null) details += 'Thời gian: ${test.runTimeSeconds}s';
                          
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: AppColors.blue100, child: Icon(Icons.history, color: AppColors.blue600)),
                            title: Text(test.notes ?? 'Bài test', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(details.trim().isEmpty ? 'Không có dữ liệu chi tiết' : details),
                            trailing: Text(test.testDate ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
      ),
    );
  }
}
