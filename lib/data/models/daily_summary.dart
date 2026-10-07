/// Tóm tắt dinh dưỡng hàng ngày
/// Tương đương: DailySummary.java
class DailySummary {
  final int? totalCalories;
  final double? totalProteinG;
  final double? totalCarbsG;
  final double? totalFatG;
  final int? totalWaterMl;
  final String? date;
  final int? numMeals; // <--- THÊM DÒNG NÀY

  const DailySummary({
    this.totalCalories,
    this.totalProteinG,
    this.totalCarbsG,
    this.totalFatG,
    this.totalWaterMl,
    this.date,
    this.numMeals, // <--- THÊM DÒNG NÀY
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      totalCalories: json['totalCalories'] as int?,
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble(),
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble(),
      totalFatG: (json['totalFatG'] as num?)?.toDouble(),
      totalWaterMl: json['totalWaterMl'] as int?,
      date: json['date'] as String?,
      numMeals: json['numMeals'] as int?, // <--- THÊM DÒNG NÀY
    );
  }

  /// Giá trị mặc định khi không có dữ liệu
  static const DailySummary empty = DailySummary(
    totalCalories: 0,
    totalProteinG: 0,
    totalCarbsG: 0,
    totalFatG: 0,
    totalWaterMl: 0,
    numMeals: 0, // <--- THÊM DÒNG NÀY
  );
}
