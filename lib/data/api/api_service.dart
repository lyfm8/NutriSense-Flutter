
import 'package:dio/dio.dart';
import '../models/daily_summary.dart';
import '../models/food_entry_item.dart';
import '../models/user_profile.dart';
import '../models/schedule.dart';
import '../models/chat_message_dto.dart';
import '../models/nutrient_dto.dart';
import '../models/meal_log_request.dart';
import '../models/dashboard_dto.dart';
import '../models/exercise_test.dart';
import '../models/reminder_response.dart';
import 'api_client.dart';

/// Tập hợp tất cả API calls của ứng dụng
/// Tương đương: ApiService.java (interface Retrofit)
///
/// Giữ nguyên: endpoints, tham số, response type
/// Thay thế: Retrofit annotations → Dio methods
class ApiService {
  final Dio _dio = ApiClient.instance;

  // ==================== AUTH ====================

  /// Đồng bộ user sau đăng nhập Firebase → lấy userId backend
  /// POST /api/users/sync
  Future<UserProfile> syncUser({
    required String authUid,
    required String email,
  }) async {
    final response = await _dio.post(
      'api/users/sync',
      data: {'authUid': authUid, 'email': email},
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  // ==================== USER ====================

  /// GET /api/users/{userId}
  Future<UserProfile> getUserProfile(int userId) async {
    final response = await _dio.get('api/users/$userId');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/users/{userId}/profile
  Future<UserProfile> updateUserProfile(int userId, UserProfile profile) async {
    final response = await _dio.put(
      'api/users/$userId/profile',
      data: profile.toJson(),
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  // ==================== HOME / DASHBOARD ====================

  /// GET /api/home/summary?userId=&date=
  Future<DailySummary> getDailySummary(int userId, String date) async {
    final response = await _dio.get(
      'api/home/summary',
      queryParameters: {'userId': userId, 'date': date},
    );
    return DailySummary.fromJson(response.data as Map<String, dynamic>);
  }

  // ==================== MEALS ====================

  /// POST /api/meals/log
  Future<FoodEntryItem> logMeal(MealLogRequest request) async {
    final response = await _dio.post('api/meals/log', data: request.toJson());
    return FoodEntryItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/meals/items?userId=&date=&mealType=
  Future<List<FoodEntryItem>> getMealItems({
    required int userId,
    required String date,
    required String mealType,
  }) async {
    final response = await _dio.get(
      'api/meals/items',
      queryParameters: {'userId': userId, 'date': date, 'mealType': mealType},
    );
    return (response.data as List<dynamic>)
        .map((e) => FoodEntryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// DELETE /api/meals/items/{itemId}
  Future<void> deleteMealItem(int itemId) async {
    await _dio.delete('api/meals/items/$itemId');
  }

  /// DELETE /api/meals/entry?userId=&date=&mealType=
  Future<void> deleteMealEntry({
    required int userId,
    required String date,
    required String mealType,
  }) async {
    await _dio.delete(
      'api/meals/entry',
      queryParameters: {'userId': userId, 'date': date, 'mealType': mealType},
    );
  }

  /// POST /api/meals/log/batch
  Future<void> logMealBatch(MealBatchLogRequest request) async {
    await _dio.post('api/meals/log/batch', data: request.toJson());
  }

  // ==================== WATER ====================

  /// POST /api/water/add?userId=&amountMl=
  /// Backend trả về plain String, không phải JSON
  Future<void> addWater(int userId, int amountMl) async {
    await _dio.post(
      'api/water/add',
      queryParameters: {'userId': userId, 'amountMl': amountMl},
      options: Options(responseType: ResponseType.plain),
    );
  }

  // ==================== SCHEDULE ====================

  /// GET /api/schedules?userId=&date=
  Future<List<Schedule>> getSchedulesByDate(int userId, String date) async {
    final response = await _dio.get(
      'api/schedules',
      queryParameters: {'userId': userId, 'date': date},
    );
    return (response.data as List<dynamic>)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/schedules
  Future<Schedule> createSchedule(Schedule schedule) async {
    final response = await _dio.post(
      'api/schedules',
      data: schedule.toJson(),
    );
    return Schedule.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/schedules/{id}/toggle?isCompleted=
  Future<Schedule> toggleScheduleCompletion(int id, bool isCompleted) async {
    final response = await _dio.patch(
      'api/schedules/$id/toggle',
      queryParameters: {'isCompleted': isCompleted},
    );
    return Schedule.fromJson(response.data as Map<String, dynamic>);
  }

  // ==================== CHAT / AI ====================

  /// GET /api/chat/history?userId=
  Future<List<ChatMessageDto>> getChatHistory(int userId) async {
    final response = await _dio.get(
      'api/chat/history',
      queryParameters: {'userId': userId},
    );
    return (response.data as List<dynamic>)
        .map((e) => ChatMessageDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/chat/unread-count?userId=
  Future<int> getUnreadCount(int userId) async {
    final response = await _dio.get(
      'api/chat/unread-count',
      queryParameters: {'userId': userId},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['unread_count'] as int?) ?? 0;
  }

  /// PUT /api/chat/mark-read?userId=
  Future<void> markAsRead(int userId) async {
    await _dio.put(
      'api/chat/mark-read',
      queryParameters: {'userId': userId},
    );
  }

  /// POST /api/chat/send
  Future<ChatMessageDto> sendMessage(ChatSendRequest request) async {
    final response = await _dio.post(
      'api/chat/send',
      data: request.toJson(),
    );
    return ChatMessageDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ==================== AI IMAGE ====================

  /// POST /api/ai/analyze-image (Multipart)
  /// Tương đương: @Multipart @POST trong Retrofit
  Future<List<NutrientDto>> analyzeImage({
    required int userId,
    required List<int> imageBytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
      ),
    });

    final response = await _dio.post(
      'api/ai/analyze-image',
      data: formData,
      queryParameters: {'userId': userId},
    );
    return (response.data as List<dynamic>)
        .map((e) => NutrientDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== REPORTS ====================

  /// GET /api/reports/dashboard?userId=&startDate=&endDate=
  Future<DashboardDto> getDashboardReport({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get(
      'api/reports/dashboard',
      queryParameters: {
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return DashboardDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ==================== FITNESS ====================

  /// POST /api/fitness/log
  Future<ExerciseTest> logFitnessTest(ExerciseTest test) async {
    final response = await _dio.post(
      'api/fitness/log',
      data: test.toJson(),
    );
    return ExerciseTest.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/fitness/recent?userId=
  Future<List<ExerciseTest>> getRecentFitnessTests(int userId) async {
    final response = await _dio.get(
      'api/fitness/recent',
      queryParameters: {'userId': userId},
    );
    return (response.data as List<dynamic>)
        .map((e) => ExerciseTest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== REMINDER ====================

  /// GET /api/ai/daily-reminder?userId=
  Future<ReminderResponse> getDailyAiReminder(int userId) async {
    final response = await _dio.get(
      'api/ai/daily-reminder',
      queryParameters: {'userId': userId},
    );
    return ReminderResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
