import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/user_profile.dart';
import '../../core/theme/theme_notifier.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  UserProfile? _profile;

  // Local settings state
  bool _waterReminder = true;
  bool _mealReminder = true;
  bool _sleepReminder = false;
  bool _aiReminder = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _darkMode = appThemeNotifier.value == ThemeMode.dark;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        _handleLogout();
        return;
      }

      final profile = await _apiService.getUserProfile(userId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load profile error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile(UserProfile updatedProfile) async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;
      
      final profile = await _apiService.updateUserProfile(userId, updatedProfile);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;
    
    final nameCtrl = TextEditingController(text: _profile!.displayName ?? '');
    final heightCtrl = TextEditingController(text: _profile!.heightCm?.toString() ?? '');
    final weightCtrl = TextEditingController(text: _profile!.weightKg?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên hiển thị')),
            const SizedBox(height: 12),
            TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Chiều cao (cm)')),
            const SizedBox(height: 12),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cân nặng (kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: AppColors.gray500))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateProfile(UserProfile(
                userId: _profile!.userId,
                authUid: _profile!.authUid,
                email: _profile!.email,
                displayName: nameCtrl.text,
                avatarUrl: _profile!.avatarUrl,
                heightCm: double.tryParse(heightCtrl.text),
                weightKg: double.tryParse(weightCtrl.text),
                gender: _profile!.gender,
                dateOfBirth: _profile!.dateOfBirth,
                activityLevel: _profile!.activityLevel,
                goal: _profile!.goal,
                dailyCalorieGoal: _profile!.dailyCalorieGoal,
                waterGoalMl: _profile!.waterGoalMl,
              ));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog() {
    if (_profile == null) return;
    
    final calCtrl = TextEditingController(text: _profile!.dailyCalorieGoal?.toString() ?? '');
    final waterCtrl = TextEditingController(text: _profile!.waterGoalMl?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật mục tiêu', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calo mỗi ngày (kcal)')),
            const SizedBox(height: 12),
            TextField(controller: waterCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nước mỗi ngày (ml)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: AppColors.gray500))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateProfile(UserProfile(
                userId: _profile!.userId,
                authUid: _profile!.authUid,
                email: _profile!.email,
                displayName: _profile!.displayName,
                avatarUrl: _profile!.avatarUrl,
                heightCm: _profile!.heightCm,
                weightKg: _profile!.weightKg,
                gender: _profile!.gender,
                dateOfBirth: _profile!.dateOfBirth,
                activityLevel: _profile!.activityLevel,
                goal: _profile!.goal,
                dailyCalorieGoal: int.tryParse(calCtrl.text),
                waterGoalMl: int.tryParse(waterCtrl.text),
              ));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await SessionManager.clearSession();
    // Assuming Firebase Auth is used, we'd call FirebaseAuth.instance.signOut() here.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue600))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppColors.blue600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
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
                              const Icon(Icons.workspace_premium, color: AppColors.white),
                              const SizedBox(width: 8),
                              const Text(
                                'Cá nhân',
                                style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quản lý thông tin và cài đặt',
                            style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // User Info Card
                          Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppColors.gray200,
                                        child: Icon(Icons.person, size: 40, color: AppColors.gray400),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _profile?.displayName ?? 'Thành viên mới', 
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _profile?.email ?? 'user@nutrisense.vn', 
                                                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold)
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _showEditProfileDialog,
                                        icon: const Icon(Icons.edit, color: AppColors.blue600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildMetricBox('Chiều cao', '${_profile?.heightCm?.toInt() ?? 0} cm', Icons.straighten, AppColors.blue600, AppColors.blue100),
                                      const SizedBox(width: 8),
                                      _buildMetricBox('Cân nặng', '${_profile?.weightKg?.toInt() ?? 0} kg', Icons.monitor_weight, AppColors.cyan600, AppColors.cyan100),
                                      const SizedBox(width: 8),
                                      _buildMetricBox('BMI', _profile?.bmi?.toStringAsFixed(1) ?? 'N/A', Icons.track_changes, AppColors.sky500, AppColors.sky100),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Goal Card
                          Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: AppColors.indigo600, borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.flag, color: AppColors.white, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Mục tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildGoalRow('Calo mỗi ngày', 'Dựa trên mức độ hoạt động', '${_profile?.dailyCalorieGoal ?? 2000} kcal', Icons.local_fire_department, AppColors.orange100, _showEditGoalDialog),
                                  const SizedBox(height: 12),
                                  _buildGoalRow('Nước mỗi ngày', 'Khuyến nghị cho bạn', '${_profile?.waterGoalMl ?? 2000} ml', Icons.water_drop, AppColors.blue100, _showEditGoalDialog),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Reminders Card
                          Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: AppColors.amber500, borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.notifications, color: AppColors.white, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Nhắc nhở', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSwitchRow('Uống nước', 'Nhắc nhở uống nước', '08:00', _waterReminder, (v) => setState(() => _waterReminder = v), AppColors.blue100),
                                  const SizedBox(height: 12),
                                  _buildSwitchRow('Bữa ăn', 'Nhắc giờ ăn chính', '11:30', _mealReminder, (v) => setState(() => _mealReminder = v), AppColors.orange100),
                                  const SizedBox(height: 12),
                                  _buildSwitchRow('Giấc ngủ', 'Nhắc giờ đi ngủ', '22:00', _sleepReminder, (v) => setState(() => _sleepReminder = v), AppColors.indigo100),
                                  const SizedBox(height: 12),
                                  _buildSwitchRow('Trợ lý AI', 'Tổng kết dinh dưỡng', '21:00', _aiReminder, (v) => setState(() => _aiReminder = v), AppColors.cyan100),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Utilities Card
                          Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: AppColors.purple500, borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Tiện ích', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildMenuRow('Bài test thể lực', 'Đánh giá sức khỏe', Icons.fitness_center, AppColors.blue600),
                                  const SizedBox(height: 8),
                                  _buildMenuRow('Thư giãn và giấc ngủ', 'Cải thiện tinh thần', Icons.dark_mode, AppColors.indigo600),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Settings Card
                          Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: AppColors.gray600, borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.settings, color: AppColors.white, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Cài đặt hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSwitchRowSimple('Giao diện hệ thống', 'Chuyển chế độ sáng/tối', _darkMode, (v) {
                                    setState(() {
                                      _darkMode = v;
                                      appThemeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                                    });
                                  }, AppColors.gray100),
                                  const SizedBox(height: 12),
                                  _buildValueRowSimple('Âm thanh nhắc nhở', 'Nhạc chuông hệ thống', 'Mặc định', AppColors.gray100),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _handleLogout,
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.red.withOpacity(0.1),
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Đăng xuất', style: TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String title, String subtitle, String value, IconData icon, Color bgColor, VoidCallback onEdit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 20, color: AppColors.blue600), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, String time, bool value, ValueChanged<bool> onChanged, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.blue600)),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.blue600),
        ],
      ),
    );
  }
  
  Widget _buildSwitchRowSimple(String title, String subtitle, bool value, ValueChanged<bool> onChanged, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.blue600),
        ],
      ),
    );
  }
  
  Widget _buildValueRowSimple(String title, String subtitle, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.blue600)),
        ],
      ),
    );
  }

  Widget _buildMenuRow(String title, String subtitle, IconData icon, Color iconColor) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }
}
