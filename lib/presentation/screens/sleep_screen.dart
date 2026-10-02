import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _timeRemaining = 1800; // 30 minutes in seconds
  bool _isPlaying = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleTimer() {
    if (_isPlaying) {
      _timer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      if (_timeRemaining == 0) _timeRemaining = 1800;
      setState(() => _isPlaying = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeRemaining > 0) {
          setState(() => _timeRemaining--);
        } else {
          timer.cancel();
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _timeRemaining = 1800;
    });
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _timeRemaining ~/ 3600, minute: (_timeRemaining % 3600) ~/ 60),
    );
    if (picked != null) {
      setState(() {
        _timeRemaining = picked.hour * 3600 + picked.minute * 60;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                
                // Header
                const SizedBox(height: 8),
                const Text(
                  'Thư giãn & giấc ngủ',
                  style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hỗ trợ giấc ngủ sâu',
                  style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 13),
                ),
                
                const SizedBox(height: 24),
                
                // Sounds Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildSoundCard(Icons.water_drop, 'Tiếng mưa'),
                      _buildSoundCard(Icons.flash_on, 'Tiếng sấm'),
                      _buildSoundCard(Icons.energy_savings_leaf, 'Tiếng gió'),
                      _buildSoundCard(Icons.local_fire_department, 'Lửa trại'),
                    ],
                  ),
                ),
                
                // Timer Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatTime(_timeRemaining),
                        style: const TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Thời gian hẹn giờ',
                        style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircleButton(Icons.timer, Colors.white.withOpacity(0.1), 48, _showTimePicker),
                          const SizedBox(width: 24),
                          _buildCircleButton(_isPlaying ? Icons.pause : Icons.play_arrow, const Color(0xFF6366F1), 64, _toggleTimer),
                          const SizedBox(width: 24),
                          _buildCircleButton(Icons.refresh, Colors.white.withOpacity(0.1), 48, _resetTimer),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Text(
                  '(Tính năng âm thanh đang phát triển cho phiên bản Web)',
                  style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Slider(
            value: 0.5,
            onChanged: (val) {},
            activeColor: const Color(0xFF6366F1),
            inactiveColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color color, double size, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: size * 0.5),
      ),
    );
  }
}
