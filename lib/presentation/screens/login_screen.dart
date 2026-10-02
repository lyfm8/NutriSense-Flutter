import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'survey_screen.dart';

/// Màn hình đăng nhập với logic đầy đủ
/// Tương đương: LoginActivity.java
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers (thay EditText trong Android)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Trạng thái loading
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _authRepo = AuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // Logic: Đăng nhập Email/Password
  // Tương đương: btnLogin.setOnClickListener() trong LoginActivity
  // ============================================================
  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập đủ thông tin');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authRepo.signInWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _navigateAfterLogin(result.userProfile?.isProfileComplete ?? true);
    } else {
      _showError(result.errorMessage ?? 'Đăng nhập thất bại');
    }
  }

  // ============================================================
  // Logic: Đăng nhập Google
  // Tương đương: signInWithGoogle() trong LoginActivity
  // ============================================================
  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);

    final result = await _authRepo.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result.success) {
      _navigateAfterLogin(result.userProfile?.isProfileComplete ?? true);
    } else {
      _showError(result.errorMessage ?? 'Đăng nhập Google thất bại');
    }
  }

  // ============================================================
  // Logic: Quên mật khẩu
  // Tương đương: showForgotPasswordDialog() trong LoginActivity
  // ============================================================
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Quên mật khẩu',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nhập email để nhận link đặt lại mật khẩu',
                style: TextStyle(color: AppColors.gray600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email của bạn',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppColors.gray500)),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        _showError('Vui lòng nhập email!');
                        return;
                      }
                      setDialogState(() => isSending = true);
                      final result =
                          await _authRepo.sendPasswordResetEmail(email);
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (result.success) {
                        _showSuccess(
                            'Đã gửi email khôi phục! Kiểm tra hộp thư của bạn.');
                      } else {
                        _showError(result.errorMessage ?? 'Gửi thất bại');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Gửi Email',
                      style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Navigation sau đăng nhập
  // Tương đương: syncWithBackend() → startActivity() trong LoginActivity
  // ============================================================
  void _navigateAfterLogin(bool isProfileComplete) {
    final target = isProfileComplete
        ? const MainScreen()
        : const SurveyScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.red600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.green600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chào mừng trở lại',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Đăng nhập để tiếp tục theo dõi sức khỏe của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Field (giờ có controller)
                          CustomTextField(
                            hintText: 'Email',
                            startIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            hintText: 'Mật khẩu',
                            startIcon: Icons.lock_outline,
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: AppColors.blue600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button với loading
                          GradientButton(
                            text: 'Đăng nhập',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleEmailLogin,
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1, color: AppColors.gray200)),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12),
                                child: Text('Hoặc',
                                    style: TextStyle(
                                        color: AppColors.gray500,
                                        fontSize: 14)),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1, color: AppColors.gray200)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google Login
                          OutlinedButton.icon(
                            onPressed: (_isLoading || _isGoogleLoading)
                                ? null
                                : _handleGoogleLogin,
                            icon: _isGoogleLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.gray700),
                                  )
                                : const Icon(Icons.g_mobiledata,
                                    size: 24, color: AppColors.gray700),
                            label: Text(
                              _isGoogleLoading
                                  ? 'Đang đăng nhập...'
                                  : 'Đăng nhập bằng Google',
                              style: const TextStyle(
                                color: AppColors.gray700,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(color: AppColors.gray300),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Chưa có tài khoản? ',
                                style: TextStyle(
                                    color: AppColors.gray600, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                ),
                                child: const Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    color: AppColors.blue600,
                                    fontSize: 14,
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
                ),
              ),

              // Bottom App Name
              const Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'NitriSense AI',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
