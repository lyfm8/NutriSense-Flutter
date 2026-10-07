  import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Quản lý session người dùng (thay thế SessionManager.java trên Android)
///
/// Android gốc dùng SharedPreferences với Context.
/// Flutter dùng shared_preferences package (không cần Context).
class SessionManager {
  SessionManager._();

  /// Lưu userId sau khi đăng nhập thành công
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyUserId, userId);
  }

  /// Lấy userId đang đăng nhập. Trả về null nếu chưa đăng nhập.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(AppConstants.keyUserId);
    return (id == null || id == -1) ? null : id;
  }

  /// Xóa toàn bộ session (dùng khi đăng xuất)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
  }

  /// Kiểm tra xem người dùng đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final id = await getUserId();
    return id != null;
  }
}
