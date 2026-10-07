import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/theme/app_colors.dart';

// Class quản lý trạng thái của từng âm thanh
class SoundItem {
  final String title;
  final IconData icon;
  final String assetPath;
  bool isPlaying;
  double volume;
  final AudioPlayer player;

  SoundItem({
    required this.title,
    required this.icon,
    required this.assetPath,
    this.isPlaying = false,
    this.volume = 0.5,
  }) : player = AudioPlayer();
}

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _timeRemaining = 1800; // Mặc định 30 phút
  bool _isTimerRunning = false;
  Timer? _timer;

  // Danh sách các âm thanh
  late List<SoundItem> _sounds;

  // Plugin thông báo
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initSounds();
  }

  // Khởi tạo thông báo
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Yêu cầu quyền thông báo cho Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Khởi tạo cấu hình âm thanh cho phép phát đè lên nhau
  void _initSounds() async {
    // 1. KHỞI TẠO DANH SÁCH TRƯỚC ĐỂ UI KHÔNG BỊ CRASH
    _sounds = [
      SoundItem(title: 'Tiếng mưa', icon: Icons.water_drop, assetPath: 'audio/rain.wav'),
      SoundItem(title: 'Tiếng sấm', icon: Icons.flash_on, assetPath: 'audio/thunder.wav'),
      SoundItem(title: 'Tiếng gió', icon: Icons.energy_savings_leaf, assetPath: 'audio/wind.wav'),
      SoundItem(title: 'Lửa trại', icon: Icons.local_fire_department, assetPath: 'audio/fire.wav'),
    ];

    // Cấu hình lặp lại cho các AudioPlayer
    for (var sound in _sounds) {
      sound.player.setReleaseMode(ReleaseMode.loop);
    }

    // 2. CẤU HÌNH AUDIO CONTEXT SAU CÙNG (tiến trình chạy ngầm)
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        audioMode: AndroidAudioMode.normal,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancelNotification(); // Xóa thông báo khi thoát màn hình
    // Dừng và giải phóng tài nguyên
    for (var sound in _sounds) {
      sound.player.stop();
      sound.player.dispose();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Hiển thị thông báo đếm ngược trên hệ thống
  Future<void> _showNotification(int seconds) async {
    final int targetTime = DateTime.now().millisecondsSinceEpoch + (seconds * 1000);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sleep_timer',
      'Hẹn giờ ngủ',
      channelDescription: 'Thông báo đếm ngược thời gian tắt nhạc',
      importance: Importance.low, // Đặt Low để không kêu "ting ting"
      priority: Priority.low,
      ongoing: true, // Không cho phép người dùng vuốt tắt thông báo
      usesChronometer: true, // Hiển thị đồng hồ
      chronometerCountDown: true, // Đồng hồ đếm ngược
      when: targetTime,
    );

    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Đang phát nhạc thư giãn',
      'Tự động tắt sau...',
      platformDetails,
    );
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      _cancelNotification();
      setState(() => _isTimerRunning = false);
      _pauseAllSounds();
    } else {
      if (_timeRemaining <= 0) return;

      setState(() => _isTimerRunning = true);
      _showNotification(_timeRemaining); // Gọi thông báo
      _resumePlayingSounds();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeRemaining > 0) {
          setState(() => _timeRemaining--);
        } else {
          timer.cancel();
          _cancelNotification();
          setState(() => _isTimerRunning = false);
          _pauseAllSounds();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _cancelNotification();
    setState(() {
      _isTimerRunning = false;
      _timeRemaining = 1800; // Reset về 30 phút
    });
    _pauseAllSounds();
  }

  // Bật/tắt 1 âm thanh cụ thể
  Future<void> _toggleSound(SoundItem sound) async {
    setState(() {
      sound.isPlaying = !sound.isPlaying;
    });

    if (sound.isPlaying) {
      await sound.player.setVolume(sound.volume);
      try {
        await sound.player.play(AssetSource(sound.assetPath));
        if (!_isTimerRunning && _timeRemaining > 0) {
          _toggleTimer();
        }
      } catch (e) {
        debugPrint('Lỗi phát âm thanh: $e');
      }
    } else {
      await sound.player.pause();
    }
  }

  Future<void> _changeVolume(SoundItem sound, double val) async {
    setState(() {
      sound.volume = val;
    });
    if (sound.isPlaying) {
      await sound.player.setVolume(val);
    }
  }

  void _pauseAllSounds() {
    for (var sound in _sounds) {
      if (sound.isPlaying) {
        sound.player.pause();
      }
    }
  }

  void _resumePlayingSounds() {
    for (var sound in _sounds) {
      if (sound.isPlaying) {
        try {
          sound.player.resume();
        } catch (_) {}
      }
    }
  }

  // Khung nhập thời gian
  Future<void> _showCustomTimePicker() async {
    int h = _timeRemaining ~/ 3600;
    int m = (_timeRemaining % 3600) ~/ 60;
    int s = _timeRemaining % 60;

    int selectedH = h;
    int selectedM = m;
    int selectedS = s;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text('Hẹn giờ tắt nhạc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeColumn('Giờ', selectedH, 23, (val) => setDialogState(() => selectedH = val)),
                const Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeColumn('Phút', selectedM, 59, (val) => setDialogState(() => selectedM = val)),
                const Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeColumn('Giây', selectedS, 59, (val) => setDialogState(() => selectedS = val)),
              ],
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              setState(() {
                _timeRemaining = (selectedH * 3600) + (selectedM * 60) + selectedS;
                // Cập nhật lại thông báo nếu timer đang chạy
                if (_isTimerRunning) {
                  _showNotification(_timeRemaining);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, int value, int maxValue, ValueChanged<int> onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          width: 50,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue + 1,
              builder: (context, index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: index == value ? Colors.white : Colors.white38,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
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
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _sounds.length,
                    itemBuilder: (context, index) {
                      return _buildSoundCard(_sounds[index]);
                    },
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
                        'Thời gian hẹn giờ tắt',
                        style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircleButton(Icons.timer, Colors.white.withOpacity(0.1), 48, _showCustomTimePicker),
                          const SizedBox(width: 24),
                          _buildCircleButton(_isTimerRunning ? Icons.pause : Icons.play_arrow, const Color(0xFF6366F1), 64, _toggleTimer),
                          const SizedBox(width: 24),
                          _buildCircleButton(Icons.refresh, Colors.white.withOpacity(0.1), 48, _resetTimer),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundCard(SoundItem sound) {
    return GestureDetector(
      onTap: () => _toggleSound(sound),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sound.isPlaying ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sound.isPlaying ? const Color(0xFF6366F1) : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sound.icon, color: sound.isPlaying ? Colors.white : const Color(0xFF6366F1), size: 32),
            const SizedBox(height: 12),
            Text(
              sound.title,
              style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: sound.volume,
              onChanged: (val) {
                if (sound.isPlaying) _changeVolume(sound, val);
              },
              activeColor: const Color(0xFF6366F1),
              inactiveColor: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
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