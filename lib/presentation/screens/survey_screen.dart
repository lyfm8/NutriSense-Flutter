import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/user_profile.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'main_screen.dart';

/// Màn hình khảo sát ban đầu - nhập thông tin cá nhân
/// Tương đương: SurveyActivity.java
///
/// Hiển thị sau lần đăng nhập đầu tiên khi profile chưa có height/weight
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivity;
  String? _selectedGoal;
  bool _isLoading = false;

  final _apiService = ApiService();

  static const _genders = ['Nam', 'Nữ', 'Khác'];
  static const _activities = [
    'Ít vận động (ngồi nhiều)',
    'Vận động nhẹ (1-3 ngày/tuần)',
    'Vận động vừa (3-5 ngày/tuần)',
    'Vận động nhiều (6-7 ngày/tuần)',
    'Vận động rất nhiều (2 buổi/ngày)',
  ];
  static const _goals = [
    'Giảm cân',
    'Tăng cân',
    'Duy trì cân nặng',
    'Tăng cơ bắp',
    'Cải thiện sức khỏe tổng thể',
  ];

  // Map tiếng Việt → code gửi API
  static const _activityCodeMap = {
    'Ít vận động (ngồi nhiều)': 'sedentary',
    'Vận động nhẹ (1-3 ngày/tuần)': 'lightly_active',
    'Vận động vừa (3-5 ngày/tuần)': 'moderately_active',
    'Vận động nhiều (6-7 ngày/tuần)': 'very_active',
    'Vận động rất nhiều (2 buổi/ngày)': 'extra_active',
  };
  static const _goalCodeMap = {
    'Giảm cân': 'lose_weight',
    'Tăng cân': 'gain_weight',
    'Duy trì cân nặng': 'maintain_weight',
    'Tăng cơ bắp': 'build_muscle',
    'Cải thiện sức khỏe tổng thể': 'improve_health',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final heightStr = _heightController.text.trim();
    final weightStr = _weightController.text.trim();

    if (heightStr.isEmpty || weightStr.isEmpty) {
      _showError('Chiều cao và cân nặng là bắt buộc');
      return;
    }

    final height = double.tryParse(heightStr);
    final weight = double.tryParse(weightStr);

    if (height == null || height < 50 || height > 250) {
      _showError('Chiều cao không hợp lệ (50-250 cm)');
      return;
    }
    if (weight == null || weight < 20 || weight > 300) {
      _showError('Cân nặng không hợp lệ (20-300 kg)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('Không tìm thấy user');

      // Convert dd/MM/yyyy (from UI) to yyyy-MM-dd (for Spring Boot API)
      String? apiDate;
      final dobStr = _dobController.text.trim();
      if (dobStr.isNotEmpty) {
        final parts = dobStr.split('/');
        if (parts.length == 3) {
          apiDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        } else {
          apiDate = dobStr; // fallback
        }
      }

      final profile = UserProfile(
        displayName: name.isEmpty ? null : name,
        heightCm: height,
        weightKg: weight,
        gender: _selectedGender?.toLowerCase(),
        dateOfBirth: apiDate,
        activityLevel:
            _activityCodeMap[_selectedActivity ?? ''] ?? _selectedActivity,
        goal: _goalCodeMap[_selectedGoal ?? ''] ?? _selectedGoal,
      );

      await _apiService.updateUserProfile(userId, profile);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Lỗi lưu thông tin. Thử lại sau.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      helpText: 'Chọn ngày sinh',
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _showDropdown(
      String title, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(options[i]),
              onTap: () {
                onSelect(options[i]);
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gray700,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gray400, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hintText,
                style: TextStyle(
                  color: value != null ? AppColors.gray800 : AppColors.gray400,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 32.0),
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.health_and_safety,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Center(
                                child: Text(
                                  'Chào mừng đến với NutriSense',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gray800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'Hãy thiết lập hồ sơ để chúng tôi tạo lộ trình dinh dưỡng dành riêng cho bạn.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tên hiển thị
                              _buildLabel('Tên hiển thị'),
                              CustomTextField(
                                hintText: 'Nhập tên của bạn',
                                startIcon: Icons.person_outline,
                                controller: _nameController,
                              ),

                              // Ngày sinh
                              _buildLabel('Ngày sinh'),
                              GestureDetector(
                                onTap: _selectDate,
                                child: AbsorbPointer(
                                  child: CustomTextField(
                                    hintText: 'Chọn ngày sinh',
                                    startIcon: Icons.cake_outlined,
                                    controller: _dobController,
                                  ),
                                ),
                              ),

                              // Chiều cao và Cân nặng
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Chiều cao (cm)'),
                                        CustomTextField(
                                          hintText: 'VD: 170',
                                          startIcon: Icons.height,
                                          keyboardType: TextInputType.number,
                                          controller: _heightController,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Cân nặng (kg)'),
                                        CustomTextField(
                                          hintText: 'VD: 60',
                                          startIcon:
                                              Icons.monitor_weight_outlined,
                                          keyboardType: TextInputType.number,
                                          controller: _weightController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Giới tính
                              _buildLabel('Giới tính'),
                              _buildDropdownField(
                                hintText: 'Chọn giới tính',
                                icon: Icons.transgender,
                                value: _selectedGender,
                                onTap: () => _showDropdown(
                                  'Chọn giới tính',
                                  _genders,
                                  (val) =>
                                      setState(() => _selectedGender = val),
                                ),
                              ),

                              // Mức độ vận động
                              _buildLabel('Mức độ vận động'),
                              _buildDropdownField(
                                hintText: 'Chọn mức độ vận động',
                                icon: Icons.directions_run,
                                value: _selectedActivity,
                                onTap: () => _showDropdown(
                                  'Mức độ vận động',
                                  _activities,
                                  (val) =>
                                      setState(() => _selectedActivity = val),
                                ),
                              ),

                              // Mục tiêu
                              _buildLabel('Mục tiêu của bạn'),
                              _buildDropdownField(
                                hintText: 'Chọn mục tiêu',
                                icon: Icons.track_changes,
                                value: _selectedGoal,
                                onTap: () => _showDropdown(
                                  'Mục tiêu sức khỏe',
                                  _goals,
                                  (val) =>
                                      setState(() => _selectedGoal = val),
                                ),
                              ),

                              const SizedBox(height: 24),

                              GradientButton(
                                text: 'Hoàn thành & Bắt đầu',
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _handleSubmit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'NutriSense AI',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
