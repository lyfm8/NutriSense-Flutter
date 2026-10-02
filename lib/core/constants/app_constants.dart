/// Các hằng số toàn cục của ứng dụng NutriSense
class AppConstants {
  AppConstants._();

  // ==================== API CONFIG ====================
  // Dùng cho Android Emulator (maps đến localhost của máy host)
  static const String baseUrlEmulator = 'http://10.0.2.2:8081/';

  // Dùng cho thiết bị thật (đổi thành IP máy chủ của bạn)
  static const String baseUrlDevice = 'http://192.168.1.55:8081/';

  // Đặt thành true khi chạy trên emulator, false khi chạy thiết bị thật
  static const bool useEmulator = true;

  static String get baseUrl => useEmulator ? baseUrlEmulator : baseUrlDevice;

  // Timeout cho HTTP requests (giống Android cũ: 60 giây)
  static const int connectTimeoutSeconds = 60;
  static const int receiveTimeoutSeconds = 60;

  // ==================== SHARED PREFERENCES KEYS ====================
  static const String prefName = 'NutriSensePrefs';
  static const String keyUserId = 'USER_ID';
  static const String keyDarkMode = 'DARK_MODE';

  // Notification preferences
  static const String keyNotifyWater = 'NOTIFY_WATER';
  static const String keyNotifyMeal = 'NOTIFY_MEAL';
  static const String keyNotifySleep = 'NOTIFY_SLEEP';
  static const String keyNotifyAi = 'NOTIFY_AI';
  static const String keyTimeWater = 'TIME_WATER';
  static const String keyTimeMeal = 'TIME_MEAL';
  static const String keyTimeSleep = 'TIME_SLEEP';
  static const String keyTimeAi = 'TIME_AI';

  // Sleep timer preference
  static const String keyTimerDuration = 'TIMER_DURATION';

  // Robot/FAB position
  static const String keyRobotX = 'robot_x';
  static const String keyRobotY = 'robot_y';

  // Tutorial
  static const String keyIsFirstTime = 'isFirstTime_';

  // ==================== DEFAULT VALUES ====================
  static const String defaultWaterTime = '08:00';
  static const String defaultMealTime = '11:30';
  static const String defaultSleepTime = '22:00';
  static const String defaultAiTime = '21:00';
  static const String defaultTimerDuration = '00:30:00';
}
