import 'nutrient_dto.dart';

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
    'userInput': rawInput,
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
///
/// Gửi lên backend theo snake_case để khớp @JsonProperty của NutrientDto.java.
/// (Trước đây gửi camelCase + thiếu vi chất nên backend nhận null -> lưu "Món ăn từ ảnh".)
class NutrientLogItem {
  final String? foodName;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? estimatedWeightG; // khẩu phần tính bằng gram
  final double? fiberG;
  final double? vitaminAMcg;
  final double? vitaminB12Mcg;
  final double? vitaminCMg;
  final double? vitaminDMcg;
  final double? ironMg;
  final double? calciumMg;
  final double? potassiumMg;
  final String? rawInput; // câu người dùng đã nhập (nếu là text)
  final String? source; // 'text' | 'image'

  const NutrientLogItem({
    this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.estimatedWeightG,
    this.fiberG,
    this.vitaminAMcg,
    this.vitaminB12Mcg,
    this.vitaminCMg,
    this.vitaminDMcg,
    this.ironMg,
    this.calciumMg,
    this.potassiumMg,
    this.rawInput,
    this.source,
  });

  /// Tạo từ kết quả phân tích ảnh
  factory NutrientLogItem.fromNutrient(NutrientDto n, {String source = 'image'}) {
    return NutrientLogItem(
      foodName: n.foodName,
      calories: n.calories,
      proteinG: n.proteinG,
      carbsG: n.carbsG,
      fatG: n.fatG,
      estimatedWeightG: n.estimatedWeightG ?? n.servingSize,
      fiberG: n.fiberG,
      vitaminAMcg: n.vitaminAMcg,
      vitaminB12Mcg: n.vitaminB12Mcg,
      vitaminCMg: n.vitaminCMg,
      vitaminDMcg: n.vitaminDMcg,
      ironMg: n.ironMg,
      calciumMg: n.calciumMg,
      potassiumMg: n.potassiumMg,
      source: source,
    );
  }

  Map<String, dynamic> toJson() => {
    if (foodName != null) 'food_name': foodName,
    if (calories != null) 'calories': calories,
    if (proteinG != null) 'protein_g': proteinG,
    if (carbsG != null) 'carbs_g': carbsG,
    if (fatG != null) 'fat_g': fatG,
    if (estimatedWeightG != null) 'estimated_weight_g': estimatedWeightG,
    if (estimatedWeightG != null) 'serving_size': estimatedWeightG,
    if (estimatedWeightG != null) 'serving_unit': 'g',
    if (fiberG != null) 'fiber_g': fiberG,
    if (vitaminAMcg != null) 'vitamin_a_mcg': vitaminAMcg,
    if (vitaminB12Mcg != null) 'vitamin_b12_mcg': vitaminB12Mcg,
    if (vitaminCMg != null) 'vitamin_c_mg': vitaminCMg,
    if (vitaminDMcg != null) 'vitamin_d_mcg': vitaminDMcg,
    if (ironMg != null) 'iron_mg': ironMg,
    if (calciumMg != null) 'calcium_mg': calciumMg,
    if (potassiumMg != null) 'potassium_mg': potassiumMg,
    if (rawInput != null) 'raw_input': rawInput,
    if (source != null) 'source': source,
  };
}