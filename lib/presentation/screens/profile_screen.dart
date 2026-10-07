import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/user_profile.dart';
import '../../core/theme/theme_notifier.dart';
import 'login_screen.dart';
import 'sleep_screen.dart';
import 'fitness_test_screen.dart';
import '../../core/utils/reminder_helper.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  UserProfile? _profile;

  late StreamSubscription _notifSubscription;

  // Trạng thái cho phép chỉnh sửa
  bool _isEditingEnabled = false;

  // Local settings state
  bool _waterReminder = true;
  bool _mealReminder = true;
  bool _sleepReminder = false;
  bool _aiReminder = true;
  bool _darkMode = false;

  // Biến State chứa thời gian
  String _waterTime = AppConstants.defaultWaterTime;
  String _mealTime = AppConstants.defaultMealTime;
  String _sleepTime = AppConstants.defaultSleepTime;
  String _aiTime = AppConstants.defaultAiTime;

  @override
  void initState() {
    super.initState();
    _darkMode = appThemeNotifier.value == ThemeMode.dark;
    _loadProfile();
    _loadRemindersConfig();

    _notifSubscription = ReminderHelper.selectNotificationStream.stream.listen((String? payload) {
      if (payload == 'ai_summary') {
        _showAiSummaryDialog();
      }
    });
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi rời khỏi màn hình để tránh lỗi bộ nhớ
    _notifSubscription.cancel();
    super.dispose();
  }

  // Hàm gọi API và hiển thị kết quả Trợ lý AI
  Future<void> _showAiSummaryDialog() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    // Hiển thị dialog Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.blue600),
            SizedBox(width: 16),
            Expanded(child: Text('AI đang phân tích dữ liệu...')),
          ],
        ),
      ),
    );

    try {
      // Gọi API đến Spring Boot backend
      final reminder = await _apiService.getDailyAiReminder(userId);

      // Đóng dialog loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Text('🤖 '),
                Expanded(child: Text('Trợ lý Dinh Dưỡng AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                // Cố gắng hiển thị detailText, nếu không có thì hiển thị notificationText
                reminder.detailText ?? reminder.notificationText ?? 'Chưa có dữ liệu cho hôm nay.',
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đã hiểu', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Đóng loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể kết nối đến Trợ lý AI. Vui lòng kiểm tra mạng.'), backgroundColor: Colors.red),
        );
      }
    }
  }


  // Đọc cài đặt đã lưu
  Future<void> _loadRemindersConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterReminder = prefs.getBool(AppConstants.keyNotifyWater) ?? true;
      _mealReminder = prefs.getBool(AppConstants.keyNotifyMeal) ?? true;
      _sleepReminder = prefs.getBool(AppConstants.keyNotifySleep) ?? false;
      _aiReminder = prefs.getBool(AppConstants.keyNotifyAi) ?? true;

      _waterTime = prefs.getString(AppConstants.keyTimeWater) ?? AppConstants.defaultWaterTime;
      _mealTime = prefs.getString(AppConstants.keyTimeMeal) ?? AppConstants.defaultMealTime;
      _sleepTime = prefs.getString(AppConstants.keyTimeSleep) ?? AppConstants.defaultSleepTime;
      _aiTime = prefs.getString(AppConstants.keyTimeAi) ?? AppConstants.defaultAiTime;
    });
  }

  // Xử lý khi bật/tắt hoặc đổi giờ nhắc nhở
  Future<void> _updateReminderSettings(String type, bool isOn, String timeStr) async {
    final prefs = await SharedPreferences.getInstance();
    final timeParts = timeStr.split(':');
    final time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    int id;
    String title, body;
    String keyNotify, keyTime;

    switch (type) {
      case 'water':
        id = ReminderHelper.waterId;
        title = '💧 Tới giờ uống nước';
        body = 'Uống một ly nước để cơ thể luôn sảng khoái nhé!';
        keyNotify = AppConstants.keyNotifyWater;
        keyTime = AppConstants.keyTimeWater;
        setState(() { _waterReminder = isOn; _waterTime = timeStr; });
        break;
      case 'meal':
        id = ReminderHelper.mealId;
        title = '🍲 Tới giờ dùng bữa';
        body = 'Đừng bỏ bữa nhé, hãy nạp năng lượng cho cơ thể!';
        keyNotify = AppConstants.keyNotifyMeal;
        keyTime = AppConstants.keyTimeMeal;
        setState(() { _mealReminder = isOn; _mealTime = timeStr; });
        break;
      case 'sleep':
        id = ReminderHelper.sleepId;
        title = '😴 Chuẩn bị đi ngủ';
        body = 'Đã đến giờ nghỉ ngơi, hãy buông điện thoại xuống nào.';
        keyNotify = AppConstants.keyNotifySleep;
        keyTime = AppConstants.keyTimeSleep;
        setState(() { _sleepReminder = isOn; _sleepTime = timeStr; });
        break;
      case 'ai':
      default:
        id = ReminderHelper.aiId;
        title = '🤖 Tổng kết sức khỏe hôm nay';
        body = 'Trợ lý AI đã tổng hợp báo cáo dinh dưỡng cho bạn. Bấm để xem chi tiết!';
        keyNotify = AppConstants.keyNotifyAi;
        keyTime = AppConstants.keyTimeAi;
        setState(() { _aiReminder = isOn; _aiTime = timeStr; });
        break;
    }

    // Lưu SharedPrefs
    await prefs.setBool(keyNotify, isOn);
    await prefs.setString(keyTime, timeStr);

    // Cập nhật Notification System
    if (isOn) {
      await ReminderHelper.scheduleDailyReminder(id, title, body, time);
    } else {
      await ReminderHelper.cancelReminder(id);
    }
  }

  // Hiển thị TimePicker để chọn giờ
  Future<void> _selectTime(String type, String currentTimeStr) async {
    final parts = currentTimeStr.split(':');
    final currentTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: 'Chọn giờ nhắc nhở',
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      // Tự động bật nhắc nhở sau khi đổi giờ thành công
      _updateReminderSettings(type, true, formattedTime);
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red),
        );
      }
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên hiển thị')),
              const SizedBox(height: 12),
              TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Chiều cao (cm)')),
              const SizedBox(height: 12),
              TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cân nặng (kg)')),
            ],
          ),
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

    String? activityFromProfile = _profile!.activityLevel?.toLowerCase();
    String selectedActivity = 'light';
    if (['light', 'moderate', 'active'].contains(activityFromProfile)) {
      selectedActivity = activityFromProfile!;
    } else if (activityFromProfile == 'lightly_active') {
      selectedActivity = 'light';
    } else if (activityFromProfile == 'moderately_active') {
      selectedActivity = 'moderate';
    } else if (activityFromProfile == 'very_active') {
      selectedActivity = 'active';
    }

    String? goalFromProfile = _profile!.goal?.toLowerCase();
    String selectedGoal = 'maintain_weight';
    if (['maintain_weight', 'lose_weight', 'gain_weight'].contains(goalFromProfile)) {
      selectedGoal = goalFromProfile!;
    } else if (goalFromProfile == 'build_muscle') {
      selectedGoal = 'gain_weight';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cập nhật mục tiêu', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedActivity,
                    decoration: const InputDecoration(labelText: 'Mức độ vận động'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('Nhẹ (Ít vận động)')),
                      DropdownMenuItem(value: 'moderate', child: Text('Vừa (Vận động 3-5 ngày/tuần)')),
                      DropdownMenuItem(value: 'active', child: Text('Nhiều (Vận động 6-7 ngày/tuần)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedActivity = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGoal,
                    decoration: const InputDecoration(labelText: 'Mục tiêu'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'maintain_weight', child: Text('Giữ cân')),
                      DropdownMenuItem(value: 'lose_weight', child: Text('Giảm cân')),
                      DropdownMenuItem(value: 'gain_weight', child: Text('Tăng cân')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedGoal = val);
                      }
                    },
                  ),
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
                      activityLevel: selectedActivity,
                      goal: selectedGoal,
                    ));
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          }
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.red),
            SizedBox(width: 8),
            Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.gray500, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Đóng hộp thoại
              _handleLogout();    // Tiến hành đăng xuất
            },
            child: const Text('Đăng xuất', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  String _getBmiString() {
    if (_profile?.heightCm == null || _profile?.weightKg == null || _profile!.heightCm! == 0) return 'N/A';
    double heightM = _profile!.heightCm! / 100;
    double bmi = _profile!.weightKg! / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // Thêm 2 biến này để quản lý màu sáng/tối đồng bộ
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.workspace_premium, color: AppColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Cá nhân',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingEnabled = !_isEditingEnabled;
                            });
                          },
                          icon: Icon(
                            _isEditingEnabled ? Icons.edit_off : Icons.edit,
                            color: AppColors.white,
                          ),
                          tooltip: _isEditingEnabled ? 'Tắt chế độ sửa' : 'Bật chế độ sửa',
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
                      color: Theme.of(context).cardColor,
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
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                              _profile?.email ?? 'user@nutrisense.vn',
                                              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isEditingEnabled)
                                  IconButton(
                                    onPressed: _showEditProfileDialog,
                                    icon: const Icon(Icons.edit, color: AppColors.blue600),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildMetricBox('Chiều cao', '${_profile?.heightCm?.toInt() ?? 0} cm', Icons.straighten, AppColors.blue600, isDark ? scaffoldBg : AppColors.blue100),
                                const SizedBox(width: 8),
                                _buildMetricBox('Cân nặng', '${_profile?.weightKg?.toInt() ?? 0} kg', Icons.monitor_weight, AppColors.cyan600, isDark ? scaffoldBg : AppColors.cyan100),
                                const SizedBox(width: 8),
                                _buildMetricBox('BMI', _getBmiString(), Icons.track_changes, AppColors.sky500, isDark ? scaffoldBg : AppColors.sky100),
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
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: AppColors.indigo600, borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.flag, color: AppColors.white, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Mục tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  ],
                                ),
                                if (_isEditingEnabled)
                                  IconButton(
                                    onPressed: _showEditGoalDialog,
                                    icon: const Icon(Icons.edit, color: AppColors.blue600),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildGoalRow('Calo mỗi ngày', 'Dựa trên mục tiêu của bạn', '${_profile?.dailyCalorieGoal ?? 2000} kcal', Icons.local_fire_department, isDark ? scaffoldBg : AppColors.orange100),
                            const SizedBox(height: 12),
                            _buildGoalRow('Nước mỗi ngày', 'Khuyến nghị cho bạn', '${_profile?.waterGoalMl ?? 2000} ml', Icons.water_drop, isDark ? scaffoldBg : AppColors.blue100),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reminders Card
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Theme.of(context).cardColor,
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
                                Text('Nhắc nhở', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInteractiveSwitchRow('Uống nước', 'Nhắc nhở uống nước', _waterTime, _waterReminder, 'water', isDark ? scaffoldBg : AppColors.blue100),
                            const SizedBox(height: 12),
                            _buildInteractiveSwitchRow('Bữa ăn', 'Nhắc giờ ăn chính', _mealTime, _mealReminder, 'meal', isDark ? scaffoldBg : AppColors.orange100),
                            const SizedBox(height: 12),
                            _buildInteractiveSwitchRow('Giấc ngủ', 'Nhắc giờ đi ngủ', _sleepTime, _sleepReminder, 'sleep', isDark ? scaffoldBg : AppColors.indigo100),
                            const SizedBox(height: 12),
                            _buildInteractiveSwitchRow('Trợ lý AI', 'Tổng kết dinh dưỡng', _aiTime, _aiReminder, 'ai', isDark ? scaffoldBg : AppColors.cyan100),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Utilities Card
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Theme.of(context).cardColor,
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
                                Text('Tiện ích', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),                              ],
                            ),
                            const SizedBox(height: 16),

                            // TEST THỂ LỰC ROW
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FitnessTestScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: isDark ? scaffoldBg : AppColors.gray50, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: AppColors.blue600, borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.fitness_center, color: AppColors.white, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Bài test thể lực', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                          Text('Đánh giá sức khỏe', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.gray500),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // THƯ GIÃN GIẤC NGỦ ROW
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SleepScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: isDark ? scaffoldBg : AppColors.gray50, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: AppColors.indigo600, borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.dark_mode, color: AppColors.white, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Thư giãn và giấc ngủ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                          Text('Cải thiện tinh thần', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.gray500),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Settings Card
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Theme.of(context).cardColor,
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
                                Text('Cài đặt hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSwitchRowSimple('Giao diện hệ thống', 'Chuyển chế độ sáng/tối', _darkMode, (v) {
                              setState(() {
                                _darkMode = v;
                                appThemeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                              });
                            }, isDark ? scaffoldBg : AppColors.gray100),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Đổi nhạc chuông'),
                                      content: const Text('Ứng dụng sẽ mở cài đặt Kênh Thông Báo của điện thoại. Vui lòng bấm vào "Nhắc nhở hằng ngày" (Daily Reminders) -> Chọn mục "Âm thanh" (Sound) để đổi nhạc.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng', style: TextStyle(color: Colors.grey))),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ReminderHelper.openSystemSoundSettings();
                                            },
                                            child: const Text('Mở Cài đặt')
                                        ),
                                      ],
                                    )
                                );
                              },
                              child: _buildValueRowSimple('Âm thanh nhắc nhở', 'Tùy chỉnh trong Cài đặt máy', 'Chọn nhạc', isDark ? scaffoldBg : AppColors.gray100),                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _showLogoutConfirmDialog,
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

  Widget _buildInteractiveSwitchRow(String title, String subtitle, String timeStr, bool value, String type, Color bgColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _selectTime(type, timeStr),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : AppColors.gray200.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.blue600)),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
              value: value,
              onChanged: (v) => _updateReminderSettings(type, v, timeStr),
              activeColor: AppColors.blue600
          ),
        ],
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
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String title, String subtitle, String value, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),              ],
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(width: 8),
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
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
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
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.blue600)),
        ],
      ),
    );
  }
}