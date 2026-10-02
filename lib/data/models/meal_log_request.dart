/// Request ghi nhật ký một món ăn
/// Tương đương: MealLogRequest.java
class MealLogRequest {
  final int userId;
  final String date;
  final String mealType;
  final String rawInput;

  const MealLogRequest({
    required this.userId,
    required this.date,
    required this.mealType,
    required this.rawInput,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': date,
        'mealType': mealType,
        'rawInput': rawInput,
      };
}

/// Request ghi nhiều món ăn một lúc (từ phân tích ảnh AI)
/// Tương đương: MealBatchLogRequest.java
class MealBatchLogRequest {
  final int userId;
  final String date;
  final String mealType;
  final List<NutrientLogItem> items;

  const MealBatchLogRequest({
    required this.userId,
    required this.date,
    required this.mealType,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': date,
        'mealType': mealType,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

/// Item trong batch log request
class NutrientLogItem {
  final String? foodName;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  const NutrientLogItem({
    this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  Map<String, dynamic> toJson() => {
        if (foodName != null) 'foodName': foodName,
        if (calories != null) 'calories': calories,
        if (proteinG != null) 'proteinG': proteinG,
        if (carbsG != null) 'carbsG': carbsG,
        if (fatG != null) 'fatG': fatG,
      };
}
