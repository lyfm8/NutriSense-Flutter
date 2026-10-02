import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

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
                  'Sat, Apr 18',
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
                      _buildSoundCard(Icons.water_drop, 'Select Sound'),
                      _buildSoundCard(Icons.flash_on, 'Select Sound'),
                      _buildSoundCard(Icons.energy_savings_leaf, 'Select Sound'),
                      _buildSoundCard(Icons.local_fire_department, 'Select Sound'),
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
                      const Text(
                        '00:30:00',
                        style: TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '00:30:00',
                        style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircleButton(Icons.timer, Colors.white.withOpacity(0.1), 48),
                          const SizedBox(width: 24),
                          _buildCircleButton(Icons.play_arrow, const Color(0xFF6366F1), 64),
                          const SizedBox(width: 24),
                          _buildCircleButton(Icons.refresh, Colors.white.withOpacity(0.1), 48),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Text(
                  'Select sounds to start',
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

  Widget _buildCircleButton(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: size * 0.5),
    );
  }
}
