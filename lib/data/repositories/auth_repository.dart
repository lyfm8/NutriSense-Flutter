import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_service.dart';
import '../models/user_profile.dart';
import '../../core/utils/session_manager.dart';
import '../../firebase_options.dart';

/// Kết quả từ các thao tác Auth
class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserProfile? userProfile;

  const AuthResult._({
    required this.success,
    this.errorMessage,
    this.userProfile,
  });

  factory AuthResult.success(UserProfile profile) =>
      AuthResult._(success: true, userProfile: profile);

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}

/// Xử lý toàn bộ luồng xác thực
/// Tương đương: LoginActivity.java + RegisterActivity.java
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: DefaultFirebaseOptions.webClientId,
  );
  final ApiService _apiService = ApiService();

  /// Kiểm tra người dùng đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return false;
    return SessionManager.isLoggedIn();
  }

  /// Lấy Firebase User hiện tại (nếu có)
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Đăng nhập Email/Password
  /// Tương đương: mAuth.signInWithEmailAndPassword() trong LoginActivity
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return AuthResult.failure('Đăng nhập thất bại.');
      return await _syncWithBackend(user.uid, user.email ?? email);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Lỗi kết nối. Vui lòng thử lại.');
    }
  }

  /// Đăng ký Email/Password
  /// Tương đương: mAuth.createUserWithEmailAndPassword() trong RegisterActivity
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return AuthResult.failure('Đăng ký thất bại.');
      return await _syncWithBackend(user.uid, user.email ?? email);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Lỗi kết nối. Vui lòng thử lại.');
    }
  }

  /// Đăng nhập Google
  /// Tương đương: signInWithGoogle() + firebaseAuthWithGoogle() trong LoginActivity
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Đăng nhập Google bị hủy.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return AuthResult.failure('Xác thực Google thất bại.');
      return await _syncWithBackend(user.uid, user.email ?? '');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Lỗi Google Sign-In: ${e.toString()}');
    }
  }

  /// Gửi email đặt lại mật khẩu
  /// Tương đương: mAuth.sendPasswordResetEmail() trong LoginActivity
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthResult._(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Không thể gửi email. Vui lòng thử lại.');
    }
  }

  /// Đồng bộ với backend sau khi xác thực Firebase thành công
  /// Tương đương: syncWithBackend() trong LoginActivity
  Future<AuthResult> _syncWithBackend(String uid, String email) async {
    try {
      final profile = await _apiService.syncUser(authUid: uid, email: email);
      if (profile.userId != null) {
        await SessionManager.saveUserId(profile.userId!);
      }
      return AuthResult.success(profile);
    } catch (e) {
      // Firebase auth thành công nhưng không kết nối được server
      // Vẫn trả về thành công để không block user
      return AuthResult.failure('Không thể kết nối tới server. Kiểm tra backend.');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    // 1. Ngắt kết nối hoàn toàn khỏi Google để ép hiện lại hộp thoại chọn tài khoản lần sau
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // Bỏ qua lỗi nếu người dùng chưa từng đăng nhập bằng Google trong phiên này
    }

    // 2. Xóa các phiên đăng nhập còn lại
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      SessionManager.clearSession(),
    ]);
  }

  /// Map Firebase error code sang thông báo tiếng Việt
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'invalid-credential':
        return 'Sai tài khoản hoặc mật khẩu!';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng dùng ít nhất 6 ký tự.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Kiểm tra internet của bạn.';
      default:
        return 'Lỗi xác thực: $code';
    }
  }
}
