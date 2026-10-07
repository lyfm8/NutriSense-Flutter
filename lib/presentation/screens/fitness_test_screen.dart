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
  List<ExerciseTest> _allRecentTests = [];

  // Biến lưu ngày đang được chọn để lọc
  DateTime? _selectedFilterDate;

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
          _allRecentTests = tests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load fitness error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm hiển thị DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blue600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  void _showAddTestDialog(String exerciseType) {
    final ctrl1 = TextEditingController(); // Dành cho số lần hoặc quãng đường
    final ctrlMin = TextEditingController(); // Nhập Phút
    final ctrlSec = TextEditingController(); // Nhập Giây

    String label1 = '';
    bool needsTime = false;

    if (exerciseType == 'Hít đất' || exerciseType == 'Gập bụng') {
      label1 = 'Số lần';
      needsTime = true;
      ctrlMin.text = '1'; // Mặc định 1 phút
      ctrlSec.text = '0';
    } else if (exerciseType == 'Chạy bộ') {
      label1 = 'Quãng đường (km)';
      needsTime = true;
      ctrl1.text = '1'; // Mặc định 1km
    } else if (exerciseType == 'Plank') {
      needsTime = true; // Plank chỉ cần nhập thời gian
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ghi nhận $exerciseType', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label1.isNotEmpty)
              TextField(
                  controller: ctrl1,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: label1)
              ),
            if (needsTime) ...[
              if (label1.isNotEmpty) const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thời gian thực hiện', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrlMin,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Phút',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: ctrlSec,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Giây',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
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

              // Xử lý thời gian tổng cộng (giây)
              int m = int.tryParse(ctrlMin.text) ?? 0;
              int s = int.tryParse(ctrlSec.text) ?? 0;
              int totalSeconds = (m * 60) + s;

              if (totalSeconds <= 0 && needsTime) totalSeconds = 60; // Tránh lỗi chia cho 0

              String apiTestType = 'others';
              double apiValue = 0;
              String apiUnit = '';
              String apiNotes = '';

              if (exerciseType == 'Hít đất') {
                apiTestType = 'pushups';
                apiValue = double.tryParse(ctrl1.text) ?? 0;
                apiUnit = 'lần';
                apiNotes = 'Hít đất trong $totalSeconds s';
              } else if (exerciseType == 'Gập bụng') {
                apiTestType = 'situps';
                apiValue = double.tryParse(ctrl1.text) ?? 0;
                apiUnit = 'lần';
                apiNotes = 'Gập bụng trong $totalSeconds s';
              } else if (exerciseType == 'Chạy bộ') {
                apiTestType = 'running_1km';
                apiValue = totalSeconds.toDouble(); // Lưu số giây chạy vào value
                apiUnit = 'giây';
                double dist = double.tryParse(ctrl1.text) ?? 0;
                apiNotes = 'Chạy $dist km'; // Lưu cự ly vào ghi chú
              } else if (exerciseType == 'Plank') {
                apiTestType = 'plank_seconds';
                apiValue = totalSeconds.toDouble();
                apiUnit = 'giây';
                apiNotes = 'Plank';
              }

              final test = ExerciseTest(
                userId: userId,
                testDate: DateTime.now().toIso8601String().split('T')[0],
                testType: apiTestType,
                value: apiValue,
                unit: apiUnit,
                notes: apiNotes,
              );

              setState(() => _isLoading = true);
              try {
                await _apiService.logFitnessTest(test);
                _selectedFilterDate = null; // Reset lọc để hiển thị ngay data mới
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

  // Trích xuất số từ chuỗi notes (VD: "Hít đất trong 60 s" -> 60)
  double _extractNumberFromNotes(String notes) {
    final RegExp regExp = RegExp(r'([\d.]+)');
    final match = regExp.firstMatch(notes);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  // HÀM ĐÁNH GIÁ CHUẨN
  Map<String, dynamic> _getEvaluation(ExerciseTest test) {
    String type = test.testType ?? '';
    double val = test.value ?? 0;
    String notes = test.notes ?? '';

    String rating = 'Chưa rõ';
    Color color = AppColors.gray500;

    if (type == 'pushups') {
      double timeSeconds = _extractNumberFromNotes(notes);
      if (timeSeconds <= 0) timeSeconds = 60;
      double normalizedReps = (val / timeSeconds) * 60; // Chuẩn hóa về 1 phút

      if (normalizedReps >= 40) { rating = 'Xuất sắc'; color = Colors.green; }
      else if (normalizedReps >= 30) { rating = 'Tốt'; color = Colors.blue; }
      else if (normalizedReps >= 20) { rating = 'Trung bình'; color = Colors.orange; }
      else { rating = 'Yếu'; color = Colors.red; }
    }
    else if (type == 'situps') {
      double timeSeconds = _extractNumberFromNotes(notes);
      if (timeSeconds <= 0) timeSeconds = 60;
      double normalizedReps = (val / timeSeconds) * 60;

      if (normalizedReps >= 45) { rating = 'Xuất sắc'; color = Colors.green; }
      else if (normalizedReps >= 35) { rating = 'Tốt'; color = Colors.blue; }
      else if (normalizedReps >= 25) { rating = 'Trung bình'; color = Colors.orange; }
      else { rating = 'Yếu'; color = Colors.red; }
    }
    else if (type == 'plank_seconds') {
      if (val >= 120) { rating = 'Xuất sắc'; color = Colors.green; }
      else if (val >= 90) { rating = 'Tốt'; color = Colors.blue; }
      else if (val >= 45) { rating = 'Trung bình'; color = Colors.orange; }
      else { rating = 'Yếu'; color = Colors.red; }
    }
    else if (type == 'running_1km' || notes.contains('Chạy')) {
      double distKm = _extractNumberFromNotes(notes);
      if (distKm <= 0) distKm = 1.0;
      if (val > 0) {
        double pace = val / distKm; // Thời gian cho 1km
        if (pace <= 270) { rating = 'Xuất sắc'; color = Colors.green; }
        else if (pace <= 360) { rating = 'Tốt'; color = Colors.blue; }
        else if (pace <= 450) { rating = 'Trung bình'; color = Colors.orange; }
        else { rating = 'Yếu'; color = Colors.red; }
      }
    }

    return {'rating': rating, 'color': color};
  }

  // Hàm chuyển đổi giây thành chuỗi Phút:Giây thân thiện
  String _formatTimeFromSeconds(int totalSecs) {
    int m = totalSecs ~/ 60;
    int s = totalSecs % 60;
    if (m > 0 && s > 0) return '$m phút $s giây';
    if (m > 0) return '$m phút';
    return '$s giây';
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo ngày
    List<ExerciseTest> displayTests = _allRecentTests;
    if (_selectedFilterDate != null) {
      String filterDateStr = DateFormat('yyyy-MM-dd').format(_selectedFilterDate!);
      displayTests = displayTests.where((test) => test.testDate == filterDateStr).toList();
    }

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
                _buildExerciseCard('Hít đất', 'Sức mạnh thân trên', Icons.fitness_center, AppColors.blue600, () => _showAddTestDialog('Hít đất')),
                _buildExerciseCard('Chạy bộ', 'Kiểm tra tim mạch', Icons.directions_run, AppColors.cyan600, () => _showAddTestDialog('Chạy bộ')),
                _buildExerciseCard('Plank', 'Sức bền cơ lõi', Icons.timer, AppColors.indigo400, () => _showAddTestDialog('Plank')),
                _buildExerciseCard('Gập bụng', 'Sức bền cơ bụng', Icons.trending_up, AppColors.indigo600, () => _showAddTestDialog('Gập bụng')),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lịch sử bài test',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          // Nút Lọc theo ngày
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedFilterDate != null ? AppColors.blue100 : AppColors.gray100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: _selectedFilterDate != null ? AppColors.blue600 : AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedFilterDate != null ? DateFormat('dd/MM').format(_selectedFilterDate!) : 'Tất cả',
                                    style: TextStyle(
                                        color: _selectedFilterDate != null ? AppColors.blue600 : AppColors.textSecondary,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  if (_selectedFilterDate != null) ...[
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedFilterDate = null),
                                      child: const Icon(Icons.close, size: 16, color: AppColors.blue600),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator(color: AppColors.blue600)),
                      )
                    else if (displayTests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                            child: Text(
                              _selectedFilterDate != null ? 'Không có dữ liệu trong ngày này.' : 'Chưa có dữ liệu bài test nào.',
                              style: const TextStyle(color: AppColors.textSecondary),
                            )
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayTests.length,
                        itemBuilder: (context, index) {
                          final test = displayTests[index];

                          // Tạo chuỗi hiển thị chi tiết thân thiện
                          String details = '';
                          if (test.unit == 'giây') {
                            String timeStr = _formatTimeFromSeconds(test.value?.toInt() ?? 0);
                            if (test.testType == 'running_1km') {
                              details = '${test.notes} trong $timeStr';
                            } else {
                              details = timeStr;
                            }
                          } else {
                            details = '${test.value?.toInt() ?? 0} ${test.unit ?? ''}';
                            if (test.notes != null && test.notes!.contains('trong')) {
                              int totalSecs = _extractNumberFromNotes(test.notes!).toInt();
                              String timeStr = _formatTimeFromSeconds(totalSecs);
                              details += ' (trong $timeStr)';
                            }
                          }

                          // Lấy kết quả đánh giá
                          final eval = _getEvaluation(test);

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppColors.gray100,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Icon(
                                  test.testType == 'pushups' ? Icons.fitness_center :
                                  (test.testType == 'running_1km' || (test.notes?.contains('Chạy') ?? false)) ? Icons.directions_run :
                                  test.testType == 'plank_seconds' ? Icons.timer : Icons.trending_up,
                                  color: eval['color']
                              ),
                            ),
                            title: Text(test.notes?.split(' trong').first ?? 'Bài test', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(details, style: const TextStyle(color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (eval['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: eval['color'] as Color),
                                  ),
                                  child: Text(
                                    eval['rating'],
                                    style: TextStyle(color: eval['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                                test.testDate != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(test.testDate!)) : '',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)
                            ),
                            isThreeLine: true,
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