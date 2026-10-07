import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'dashboard_screen.dart';
import 'schedule_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'ai_analysis_screen.dart';
import 'ai_chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Tọa độ cho nút AI Chatbot
  double _fabX = 0;
  double _fabY = 0;
  bool _isFabInitialized = false;

  // Biến cho khung thoại Mascot bình thường
  Timer? _cycleTimer;
  Timer? _hideTimer;
  bool _showMessage = true;
  int _currentMessageIndex = 0;
  final List<String> _mascotMessages = [
    'Xin chào! Tôi là NutriSense 🤖',
    'Bạn có câu hỏi gì cứ hỏi tôi nhé!',
    'Hôm nay bạn ăn gì thế? 🍲',
    'Nhớ uống đủ nước bạn nha 💧',
    'Cần tính Calo? Nhấn vào tôi!'
  ];

  // --- CÁC BIẾN CHO HƯỚNG DẪN (ONBOARDING) ---
  bool _showTutorial = false;
  int _tutorialStep = 0;
  final List<String> _tutorialTexts = [
    'Chào mừng bạn!\nTôi là Trợ lý AI.\nNhấn vào tôi bất cứ lúc nào để được tư vấn dinh dưỡng nhé!',
    'Trang chủ:\nNơi tóm tắt Calo, Nước và các chất bạn đã nạp trong ngày.',
    'Lịch trình:\nLên lịch nhắc nhở ăn uống, tập luyện, uống nước.',
    'Phân tích AI:\nChụp ảnh món ăn, tôi sẽ đoán ngay lượng Calo!',
    'Lịch sử:\nTheo dõi biểu đồ sức khỏe của bạn theo thời gian.',
    'Hồ sơ:\nQuản lý mục tiêu và cài đặt hệ thống của bạn.',
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _startNormalMascotTimers();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Đọc trạng thái, nếu null thì gán = true (Lần đầu mở app)
    bool isFirst = prefs.getBool(AppConstants.keyIsFirstTime) ?? true;
    if (isFirst) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsFirstTime, false);
    setState(() {
      _showTutorial = false;
    });
  }

  void _startNormalMascotTimers() {
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showMessage = false);
    });

    _cycleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && !_showTutorial) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _mascotMessages.length;
          _showMessage = true;
        });

        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showMessage = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Lấy chiều cao của thanh điều hướng (nếu có SafeArea dưới cùng)
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 60.0 + bottomPadding; // 60 là chiều cao ước tính của BottomNavigationBar

    if (!_isFabInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _fabX = screenWidth - 100;
          _fabY = screenHeight - bottomNavHeight - 160;
          _isFabInitialized = true;
        });
      });
    }

    return Scaffold(
      // BỎ THUỘC TÍNH bottomNavigationBar CỦA SCAFFOLD.
      // ĐƯA TẤT CẢ VÀO TRONG MỘT STACK.
      body: Stack(
        children: [
          // 1. GIAO DIỆN CHÍNH NẰM DƯỚI CÙNG
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    DashboardScreen(isActive: _currentIndex == 0),
                    const ScheduleScreen(),
                    const AiAnalysisScreen(),
                    const HistoryScreen(),
                    const ProfileScreen(),
                  ],
                ),
              ),
              // VẼ BOTTOM NAVIGATION BAR THỦ CÔNG
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (!_showTutorial) setState(() => _currentIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.white,
                selectedItemColor: AppColors.blue600,
                unselectedItemColor: AppColors.gray400,
                elevation: 16,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Lịch'),
                  BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'Trợ lý AI'),
                  BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Lịch sử'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Hồ sơ'),
                ],
              ),
            ],
          ),

          // 2. MASCOT BÌNH THƯỜNG (Ẩn đi khi đang chạy Hướng dẫn)
          if (_isFabInitialized && !_showTutorial)
            Positioned(
              left: _fabX,
              top: _fabY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _fabX += details.delta.dx;
                    _fabY += details.delta.dy;
                    _fabX = _fabX.clamp(0.0, screenWidth - 160.0);
                    _fabY = _fabY.clamp(0.0, screenHeight - bottomNavHeight - 140.0);
                  });
                },
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatScreen()));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: _showMessage ? 1.0 : 0.0,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4, left: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: const BoxConstraints(maxWidth: 160),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(4),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: AppColors.blue100, width: 1),
                        ),
                        child: Text(
                          _mascotMessages[_currentMessageIndex],
                          style: const TextStyle(fontSize: 12, color: AppColors.blue600, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      width: 80, height: 80,
                      color: Colors.transparent,
                      child: Lottie.asset('assets/animations/chatbot.json', fit: BoxFit.contain, repeat: true),
                    ),
                  ],
                ),
              ),
            ),

          // 3. LỚP PHỦ HƯỚNG DẪN NẰM TRÊN CÙNG (Đè lên cả Bottom Nav)
          if (_showTutorial && _isFabInitialized)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_tutorialStep < 5) {
                      _tutorialStep++; // Sang bước tiếp theo
                    } else {
                      _finishTutorial(); // Kết thúc
                    }
                  });
                },
                child: Stack(
                  children: [
                    // Màn hình tối với vòng tròn cắt xuyên thấu (Spotlight)
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: SpotlightPainter(
                        _getSpotlightCenter(screenWidth, screenHeight, bottomPadding),
                        _getSpotlightRadius(),
                      ),
                    ),

                    // Nút Bỏ qua
                    Positioned(
                      top: 50,
                      right: 20,
                      child: TextButton(
                        onPressed: _finishTutorial,
                        child: const Text('Bỏ qua', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    // Mascot và Khung thoại di chuyển theo các bước
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      left: _getTutorialMascotX(screenWidth),
                      top: _getTutorialMascotY(screenHeight, bottomPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            constraints: const BoxConstraints(maxWidth: 240),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                            ),
                            child: Text(
                              _tutorialTexts[_tutorialStep],
                              style: const TextStyle(color: AppColors.blue600, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 80, height: 80,
                            child: Lottie.asset('assets/animations/chatbot.json', fit: BoxFit.contain, repeat: true),
                          ),
                        ],
                      ),
                    ),

                    // Dòng chữ hướng dẫn
                    const Positioned(
                      bottom: 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Chạm vào màn hình để tiếp tục',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- HÀM TÍNH TỌA ĐỘ VÀ KÍCH THƯỚC CHO HƯỚNG DẪN ---

  Offset _getSpotlightCenter(double screenWidth, double screenHeight, double bottomPadding) {
    if (_tutorialStep == 0) {
      // Tính toán tọa độ trung tâm của khối Mascot + Khung thoại ở bước 1
      double mascotX = _getTutorialMascotX(screenWidth);
      double mascotY = _getTutorialMascotY(screenHeight, bottomPadding);

      // Khối [Khung thoại + Mascot] có chiều rộng ước tính khoảng 240px và cao khoảng 180px
      return Offset(mascotX + 120, mascotY + 90);
    }
    // Vị trí của các Tab ở dưới cùng
    final tabWidth = screenWidth / 5;
    final targetTabIndex = _tutorialStep - 1;
    final x = tabWidth * targetTabIndex + (tabWidth / 2);
    // Tính toán tọa độ Y chính xác giữa lòng BottomNavigationBar
    final y = screenHeight - bottomPadding - 30.0; // 30 là một nửa chiều cao thanh Nav (60)
    return Offset(x, y);
  }

  double _getSpotlightRadius() {
    // Bước đầu tiên khoanh vòng lớn hơn (140) để chứa đủ cả Khung thoại và Mascot Lottie
    return _tutorialStep == 0 ? 140.0 : 40.0;
  }

  double _getTutorialMascotX(double screenWidth) {
    if (_tutorialStep == 0) {
      return (_fabX - 160).clamp(16.0, screenWidth - 100.0);
    }
    final tabWidth = screenWidth / 5;
    final x = tabWidth * (_tutorialStep - 1) + (tabWidth / 2) - 40;
    return x.clamp(16.0, screenWidth - 256.0);
  }

  double _getTutorialMascotY(double screenHeight, double bottomPadding) {
    if (_tutorialStep == 0) {
      return _fabY - 60;
    }
    // Đứng lơ lửng ngay trên Bottom Nav
    final bottomNavY = screenHeight - 60 - bottomPadding;
    return bottomNavY - 180;
  }
}

// --- CLASS VẼ MÀN HÌNH TỐI CÓ KHOÉT LỖ (SPOTLIGHT) ---
class SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;

  SpotlightPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.85); // Tăng độ tối lên 0.85 cho rõ phần khoanh vùng

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }

}