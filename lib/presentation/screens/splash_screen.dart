import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'survey_screen.dart';

/// Màn hình splash - kiểm tra trạng thái đăng nhập
/// Tương đương: SplashActivity.java
///
/// Logic flow (giống Android cũ):
/// 1. Hiển thị logo 2 giây
/// 2. Kiểm tra Firebase currentUser
/// 3. Nếu đã đăng nhập → sync backend → check profile complete
///    - Profile đầy đủ → MainScreen
///    - Profile chưa đủ → SurveyScreen
/// 4. Nếu chưa đăng nhập → LoginScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _authRepo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Chờ tối thiểu 2 giây để hiển thị splash
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final firebaseUser = _authRepo.currentFirebaseUser;

    if (firebaseUser == null) {
      // Chưa đăng nhập → LoginScreen
      _navigateTo(const LoginScreen());
      return;
    }

    // Đã đăng nhập Firebase → sync với backend
    final result = await _authRepo.signInWithEmail(
      email: firebaseUser.email ?? '',
      password: '', // Firebase đã giữ session, gọi syncUser trực tiếp
    );

    // Nếu sync thất bại, vẫn có thể dùng SessionManager để lấy cached userId
    final isLoggedIn = await _authRepo.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Kiểm tra profile đầy đủ chưa
      final profile = result.userProfile;
      if (profile != null && !profile.isProfileComplete) {
        _navigateTo(const SurveyScreen());
      } else {
        _navigateTo(const MainScreen());
      }
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // App name
                const Text(
                  'NutriSense',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI Nutrition Tracker',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Loading indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
