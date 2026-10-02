import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SingleChildScrollView(
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
                                    const Text('Thành viên mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: const [
                                        Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                                        SizedBox(width: 4),
                                        Text('user@nutrisense.vn', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit, color: AppColors.blue600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildMetricBox('Chiều cao', '170 cm', Icons.straighten, AppColors.blue600, AppColors.blue100),
                              const SizedBox(width: 8),
                              _buildMetricBox('Cân nặng', '68 kg', Icons.monitor_weight, AppColors.cyan600, AppColors.cyan100),
                              const SizedBox(width: 8),
                              _buildMetricBox('BMI', '23.5', Icons.track_changes, AppColors.sky500, AppColors.sky100),
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
                          _buildGoalRow('Calo mỗi ngày', 'Dựa trên mức độ hoạt động', '2000 kcal', Icons.local_fire_department, AppColors.orange100),
                          const SizedBox(height: 12),
                          _buildGoalRow('Nước mỗi ngày', 'Khuyến nghị cho bạn', '2000 ml', Icons.water_drop, AppColors.blue100),
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
                          _buildSwitchRow('Uống nước', 'Nhắc nhở uống nước', '08:00', true, AppColors.blue100),
                          const SizedBox(height: 12),
                          _buildSwitchRow('Bữa ăn', 'Nhắc giờ ăn chính', '11:30', true, AppColors.orange100),
                          const SizedBox(height: 12),
                          _buildSwitchRow('Giấc ngủ', 'Nhắc giờ đi ngủ', '22:00', false, AppColors.indigo100),
                          const SizedBox(height: 12),
                          _buildSwitchRow('Trợ lý AI', 'Tổng kết dinh dưỡng', '21:00', true, AppColors.cyan100),
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
                          _buildSwitchRowSimple('Giao diện hệ thống', 'Chuyển chế độ sáng/tối', false, AppColors.gray100),
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
                      onPressed: () {},
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20, color: AppColors.blue600), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, String time, bool value, Color bgColor) {
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
          Switch(value: value, onChanged: (val) {}, activeColor: AppColors.blue600),
        ],
      ),
    );
  }
  
  Widget _buildSwitchRowSimple(String title, String subtitle, bool value, Color bgColor) {
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
          Switch(value: value, onChanged: (val) {}, activeColor: AppColors.blue600),
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
