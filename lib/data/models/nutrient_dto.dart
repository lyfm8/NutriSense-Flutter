/// Thông tin chất dinh dưỡng (từ phân tích ảnh AI)
/// Tương đương: NutrientDto.java
///
/// Backend trả JSON snake_case (food_name, protein_g, ...),
/// nên fromJson đọc snake_case trước, camelCase là dự phòng.
class NutrientDto {
  final String? foodName;
  final double? estimatedWeightG;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? vitaminAMcg;
  final double? vitaminB12Mcg;
  final double? vitaminCMg;
  final double? vitaminDMcg;
  final double? ironMg;
  final double? calciumMg;
  final double? potassiumMg;
  final double? servingSize;
  final String? servingUnit;
  final String? vitamins;
  final String? minerals;

  const NutrientDto({
    this.foodName,
    this.estimatedWeightG,
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
    this.servingSize,
    this.servingUnit,
    this.vitamins,
    this.minerals,
  });

  factory NutrientDto.fromJson(Map<String, dynamic> json) {
    double? num_(String snake, String camel) =>
        ((json[snake] ?? json[camel]) as num?)?.toDouble();

    final weight = num_('estimated_weight_g', 'estimatedWeightG');

    return NutrientDto(
      foodName: (json['food_name'] ?? json['foodName']) as String?,
      estimatedWeightG: weight,
      calories: num_('calories', 'calories'),
      proteinG: num_('protein_g', 'proteinG'),
      carbsG: num_('carbs_g', 'carbsG'),
      fatG: num_('fat_g', 'fatG'),
      fiberG: num_('fiber_g', 'fiberG'),
      vitaminAMcg: num_('vitamin_a_mcg', 'vitaminAMcg'),
      vitaminB12Mcg: num_('vitamin_b12_mcg', 'vitaminB12Mcg'),
      vitaminCMg: num_('vitamin_c_mg', 'vitaminCMg'),
      vitaminDMcg: num_('vitamin_d_mcg', 'vitaminDMcg'),
      ironMg: num_('iron_mg', 'ironMg'),
      calciumMg: num_('calcium_mg', 'calciumMg'),
      potassiumMg: num_('potassium_mg', 'potassiumMg'),
      servingSize: num_('serving_size', 'servingSize') ?? weight,
      servingUnit: (json['serving_unit'] ?? json['servingUnit']) as String?,
      vitamins: json['vitamins'] as String?,
      minerals: json['minerals'] as String?,
    );
  }
}