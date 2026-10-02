import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisense_flutter/data/models/user_profile.dart';
import 'package:nutrisense_flutter/data/models/daily_summary.dart';
import 'package:nutrisense_flutter/data/models/food_entry_item.dart';
import 'package:nutrisense_flutter/data/models/schedule.dart';
import 'package:nutrisense_flutter/data/models/chat_message_dto.dart';
import 'package:nutrisense_flutter/data/models/nutrient_dto.dart';
import 'package:nutrisense_flutter/data/models/meal_log_request.dart';
import 'package:nutrisense_flutter/data/models/dashboard_dto.dart';
import 'package:nutrisense_flutter/data/models/exercise_test.dart';
import 'package:nutrisense_flutter/data/models/reminder_response.dart';
import 'package:nutrisense_flutter/core/constants/app_constants.dart';

void main() {
  // ============================================================
  // TEST GROUP 1: AppConstants
  // ============================================================
  group('AppConstants', () {
    test('baseUrl should be emulator URL by default', () {
      expect(AppConstants.baseUrl, contains('10.0.2.2'));
    });

    test('timeout should be 60 seconds', () {
      expect(AppConstants.connectTimeoutSeconds, equals(60));
      expect(AppConstants.receiveTimeoutSeconds, equals(60));
    });

    test('preference keys should not be empty', () {
      expect(AppConstants.keyUserId, isNotEmpty);
      expect(AppConstants.keyDarkMode, isNotEmpty);
    });
  });

  // ============================================================
  // TEST GROUP 2: UserProfile Model
  // ============================================================
  group('UserProfile', () {
    final sampleJson = {
      'userId': 1,
      'authUid': 'firebase-uid-123',
      'email': 'test@nutrisense.vn',
      'displayName': 'Nguyễn Văn A',
      'heightCm': 170.0,
      'weightKg': 68.0,
      'gender': 'male',
      'dailyCalorieGoal': 2000,
      'waterGoalMl': 2000,
    };

    test('fromJson should parse correctly', () {
      final profile = UserProfile.fromJson(sampleJson);
      expect(profile.userId, equals(1));
      expect(profile.email, equals('test@nutrisense.vn'));
      expect(profile.heightCm, equals(170.0));
      expect(profile.weightKg, equals(68.0));
    });

    test('bmi should calculate correctly (68 / 1.7^2 ≈ 23.5)', () {
      final profile = UserProfile.fromJson(sampleJson);
      expect(profile.bmi, closeTo(23.5, 0.1));
    });

    test('isProfileComplete should be true when height and weight exist', () {
      final profile = UserProfile.fromJson(sampleJson);
      expect(profile.isProfileComplete, isTrue);
    });

    test('isProfileComplete should be false when missing data', () {
      final profile = UserProfile.fromJson({'userId': 1});
      expect(profile.isProfileComplete, isFalse);
    });

    test('toJson should include non-null fields', () {
      final profile = UserProfile.fromJson(sampleJson);
      final json = profile.toJson();
      expect(json['userId'], equals(1));
      expect(json['email'], equals('test@nutrisense.vn'));
    });
  });

  // ============================================================
  // TEST GROUP 3: DailySummary Model
  // ============================================================
  group('DailySummary', () {
    test('fromJson should parse correctly', () {
      final json = {
        'totalCalories': 1500,
        'totalProteinG': 75.5,
        'totalCarbsG': 200.0,
        'totalFatG': 45.3,
        'totalWaterMl': 1500,
      };
      final summary = DailySummary.fromJson(json);
      expect(summary.totalCalories, equals(1500));
      expect(summary.totalProteinG, equals(75.5));
      expect(summary.totalWaterMl, equals(1500));
    });

    test('empty constant should have all zeros', () {
      expect(DailySummary.empty.totalCalories, equals(0));
      expect(DailySummary.empty.totalWaterMl, equals(0));
    });
  });

  // ============================================================
  // TEST GROUP 4: FoodEntryItem Model
  // ============================================================
  group('FoodEntryItem', () {
    test('displayName should prefer rawInput over customName', () {
      final item = FoodEntryItem.fromJson({
        'rawInput': 'Phở bò',
        'customName': 'Phở',
      });
      expect(item.displayName, equals('Phở bò'));
    });

    test('displayName should fallback to customName when rawInput is empty', () {
      final item = FoodEntryItem.fromJson({
        'rawInput': '',
        'customName': 'Bánh mì',
      });
      expect(item.displayName, equals('Bánh mì'));
    });

    test('displayCalories should prefer calories over caloriesPerServing', () {
      final item = FoodEntryItem.fromJson({
        'calories': 350.0,
        'caloriesPerServing': 200.0,
      });
      expect(item.displayCalories, equals(350.0));
    });
  });

  // ============================================================
  // TEST GROUP 5: Schedule Model
  // ============================================================
  group('Schedule', () {
    test('fromJson should parse correctly', () {
      final json = {
        'scheduleId': 10,
        'userId': 1,
        'eventType': 'meal',
        'title': 'Bữa sáng',
        'startTime': '2024-01-15T08:00:00',
        'completed': false,
      };
      final schedule = Schedule.fromJson(json);
      expect(schedule.scheduleId, equals(10));
      expect(schedule.eventType, equals('meal'));
    });

    test('displayTime should extract HH:mm from ISO string', () {
      final schedule = Schedule.fromJson({
        'startTime': '2024-01-15T08:30:00',
      });
      expect(schedule.displayTime, equals('08:30'));
    });

    test('displayTime should return empty string when startTime is null', () {
      final schedule = Schedule.fromJson({});
      expect(schedule.displayTime, equals(''));
    });

    test('copyWith should update only completed field', () {
      final schedule = Schedule.fromJson({
        'scheduleId': 1,
        'title': 'Uống nước',
        'completed': false,
      });
      final updated = schedule.copyWith(completed: true);
      expect(updated.completed, isTrue);
      expect(updated.title, equals('Uống nước')); // unchanged
    });
  });

  // ============================================================
  // TEST GROUP 6: ChatMessageDto
  // ============================================================
  group('ChatMessageDto', () {
    test('isFromUser should be true for role=user', () {
      final msg = ChatMessageDto.fromJson({'role': 'user', 'content': 'Xin chào'});
      expect(msg.isFromUser, isTrue);
      expect(msg.isFromAssistant, isFalse);
    });

    test('isFromAssistant should be true for role=assistant', () {
      final msg = ChatMessageDto.fromJson({'role': 'assistant', 'content': 'Chào bạn!'});
      expect(msg.isFromAssistant, isTrue);
    });
  });

  // ============================================================
  // TEST GROUP 7: ChatSendRequest
  // ============================================================
  group('ChatSendRequest', () {
    test('toJson should produce correct structure', () {
      final request = ChatSendRequest(userId: 1, message: 'Hôm nay tôi ăn phở');
      final json = request.toJson();
      expect(json['userId'], equals(1));
      expect(json['message'], equals('Hôm nay tôi ăn phở'));
    });
  });

  // ============================================================
  // TEST GROUP 8: MealLogRequest
  // ============================================================
  group('MealLogRequest', () {
    test('toJson should include all required fields', () {
      final request = MealLogRequest(
        userId: 1,
        date: '2024-01-15',
        mealType: 'breakfast',
        rawInput: '1 bát phở bò',
      );
      final json = request.toJson();
      expect(json['userId'], equals(1));
      expect(json['date'], equals('2024-01-15'));
      expect(json['mealType'], equals('breakfast'));
      expect(json['rawInput'], equals('1 bát phở bò'));
    });
  });

  // ============================================================
  // TEST GROUP 9: ExerciseTest
  // ============================================================
  group('ExerciseTest', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'id': 5,
        'userId': 1,
        'testDate': '2024-01-15',
        'pushUps': 30,
        'sitUps': 40,
        'fitnessLevel': 'good',
      };
      final test = ExerciseTest.fromJson(json);
      expect(test.pushUps, equals(30));
      expect(test.fitnessLevel, equals('good'));

      final backToJson = test.toJson();
      expect(backToJson['pushUps'], equals(30));
    });
  });

  // ============================================================
  // TEST GROUP 10: ReminderResponse
  // ============================================================
  group('ReminderResponse', () {
    test('displayText should use message field', () {
      final reminder = ReminderResponse.fromJson({
        'message': 'Hôm nay bạn đã uống đủ nước!',
      });
      expect(reminder.displayText, equals('Hôm nay bạn đã uống đủ nước!'));
    });

    test('displayText should fallback to summary', () {
      final reminder = ReminderResponse.fromJson({
        'summary': 'Calo hôm nay: 1500 kcal',
      });
      expect(reminder.displayText, equals('Calo hôm nay: 1500 kcal'));
    });

    test('displayText should return empty when both null', () {
      final reminder = ReminderResponse.fromJson({});
      expect(reminder.displayText, equals(''));
    });
  });

  // ============================================================
  // TEST GROUP 11: DashboardDto
  // ============================================================
  group('DashboardDto', () {
    test('fromJson should parse nested dailyCalories list', () {
      final json = {
        'avgCalories': 1800.0,
        'totalDays': 7,
        'dailyCalories': [
          {'date': '2024-01-15', 'calories': 1500.0},
          {'date': '2024-01-16', 'calories': 2000.0},
        ],
      };
      final dto = DashboardDto.fromJson(json);
      expect(dto.avgCalories, equals(1800.0));
      expect(dto.dailyCalories?.length, equals(2));
      expect(dto.dailyCalories?[0].calories, equals(1500.0));
    });
  });
}
