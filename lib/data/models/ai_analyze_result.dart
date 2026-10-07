class AiAnalyzeResult {
  final bool isAskUser;
  final String? question;
  final List<FoodItem>? foodItems;

  AiAnalyzeResult({
    this.isAskUser = false,
    this.question,
    this.foodItems,
  });

  factory AiAnalyzeResult.fromJson(Map<String, dynamic> json) {
    // KHẮC PHỤC 1: Bắt chuẩn mọi biến thể của trạng thái hỏi người dùng từ Backend
    final checkAskUser = (json['isAskUser'] == true) ||
        (json['askUser'] == true) ||
        (json['status'] == 'ask_user');

    return AiAnalyzeResult(
      isAskUser: checkAskUser,
      question: json['question'] as String?,
      foodItems: json['foodItems'] != null
          ? (json['foodItems'] as List)
          .map((i) => FoodItem.fromJson(i))
          .toList()
          : null,
    );
  }
}

class FoodItem {
  String name; // KHÔNG ĐƯỢC ĐỂ NULL
  double? servingSize;
  double? calories;
  double? proteinG;
  double? carbsG;
  double? fatG;
  double? fiberG;
  double? vitaminAMcg;
  double? vitaminB12Mcg;
  double? vitaminCMg;
  double? vitaminDMcg;
  double? ironMg;
  double? calciumMg;
  double? potassiumMg;
  String? source;

  FoodItem({
    required this.name,
    this.servingSize,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
    this.vitaminAMcg,
    this.vitaminB12Mcg,
    this.vitaminCMg,
    this.vitaminDMcg,
    this.ironMg,
    this.calciumMg,
    this.potassiumMg,
    this.source,
  });

  /// Bản sao, dùng làm mốc để scale theo số gram
  FoodItem copy() => FoodItem(
    name: name,
    servingSize: servingSize,
    calories: calories,
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
    fiberG: fiberG,
    vitaminAMcg: vitaminAMcg,
    vitaminB12Mcg: vitaminB12Mcg,
    vitaminCMg: vitaminCMg,
    vitaminDMcg: vitaminDMcg,
    ironMg: ironMg,
    calciumMg: calciumMg,
    potassiumMg: potassiumMg,
    source: source,
  );

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Fallback tên món nếu AI/Backend trả về null
    final parsedName = (json['food_name'] ?? json['name']) as String?;
    final defaultName = parsedName != null && parsedName.isNotEmpty
        ? parsedName
        : 'Món ăn tự nhập';

    // Backend trả entity FoodItem (camelCase); vẫn chấp nhận snake_case
    double n(String camel, String snake) =>
        ((json[camel] ?? json[snake] ?? 0) as num).toDouble();

    return FoodItem(
      name: defaultName,
      servingSize: ((json['estimated_weight_g'] ?? json['servingSize'] ?? 100) as num).toDouble(),
      calories: n('calories', 'calories'),
      proteinG: n('proteinG', 'protein_g'),
      carbsG: n('carbsG', 'carbs_g'),
      fatG: n('fatG', 'fat_g'),
      fiberG: n('fiberG', 'fiber_g'),
      vitaminAMcg: n('vitaminAMcg', 'vitamin_a_mcg'),
      vitaminB12Mcg: n('vitaminB12Mcg', 'vitamin_b12_mcg'),
      vitaminCMg: n('vitaminCMg', 'vitamin_c_mg'),
      vitaminDMcg: n('vitaminDMcg', 'vitamin_d_mcg'),
      ironMg: n('ironMg', 'iron_mg'),
      calciumMg: n('calciumMg', 'calcium_mg'),
      potassiumMg: n('potassiumMg', 'potassium_mg'),
      source: json['source'] as String? ?? 'text',
    );
  }
}