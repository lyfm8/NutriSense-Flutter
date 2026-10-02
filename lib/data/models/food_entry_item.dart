/// Một món ăn trong nhật ký bữa ăn
/// Tương đương: FoodEntryItem.java
class FoodEntryItem {
  final int? id;
  final int? userId;
  final String? mealType; // breakfast, lunch, snack, dinner
  final String? date;
  final String? rawInput;
  final String? customName;
  final double? calories;
  final double? caloriesPerServing;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? servingSize;
  final String? servingUnit;
  final String? imageUrl;

  const FoodEntryItem({
    this.id,
    this.userId,
    this.mealType,
    this.date,
    this.rawInput,
    this.customName,
    this.calories,
    this.caloriesPerServing,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.servingSize,
    this.servingUnit,
    this.imageUrl,
  });

  factory FoodEntryItem.fromJson(Map<String, dynamic> json) {
    return FoodEntryItem(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      mealType: json['mealType'] as String?,
      date: json['date'] as String?,
      rawInput: json['rawInput'] as String?,
      customName: json['customName'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      caloriesPerServing: (json['caloriesPerServing'] as num?)?.toDouble(),
      proteinG: (json['proteinG'] as num?)?.toDouble(),
      carbsG: (json['carbsG'] as num?)?.toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
      servingSize: (json['servingSize'] as num?)?.toDouble(),
      servingUnit: json['servingUnit'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (mealType != null) 'mealType': mealType,
      if (date != null) 'date': date,
      if (rawInput != null) 'rawInput': rawInput,
      if (customName != null) 'customName': customName,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'proteinG': proteinG,
      if (carbsG != null) 'carbsG': carbsG,
      if (fatG != null) 'fatG': fatG,
    };
  }

  /// Tên hiển thị (ưu tiên rawInput, sau đó customName)
  String get displayName =>
      rawInput?.isNotEmpty == true ? rawInput! : (customName ?? 'Món ăn');

  /// Calo hiển thị
  double get displayCalories => calories ?? caloriesPerServing ?? 0;
}
