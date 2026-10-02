/// Thông tin chất dinh dưỡng (từ phân tích ảnh AI)
/// Tương đương: NutrientDto.java
class NutrientDto {
  final String? foodName;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? servingSize;
  final String? servingUnit;
  final String? vitamins;
  final String? minerals;

  const NutrientDto({
    this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.servingSize,
    this.servingUnit,
    this.vitamins,
    this.minerals,
  });

  factory NutrientDto.fromJson(Map<String, dynamic> json) {
    return NutrientDto(
      foodName: json['foodName'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      proteinG: (json['proteinG'] as num?)?.toDouble(),
      carbsG: (json['carbsG'] as num?)?.toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
      servingSize: (json['servingSize'] as num?)?.toDouble(),
      servingUnit: json['servingUnit'] as String?,
      vitamins: json['vitamins'] as String?,
      minerals: json['minerals'] as String?,
    );
  }
}
