/// Dashboard report theo khoảng ngày (cho màn hình Report)
/// Tương đương: DashboardDTO.java
class DashboardDto {
  final List<DailyCalorieEntry>? dailyCalories;
  final double? avgCalories;
  final double? avgProtein;
  final double? avgCarbs;
  final double? avgFat;
  final double? avgWater;
  final int? totalDays;

  const DashboardDto({
    this.dailyCalories,
    this.avgCalories,
    this.avgProtein,
    this.avgCarbs,
    this.avgFat,
    this.avgWater,
    this.totalDays,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    return DashboardDto(
      dailyCalories: (json['dailyCalories'] as List<dynamic>?)
          ?.map((e) => DailyCalorieEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      avgCalories: (json['avgCalories'] as num?)?.toDouble(),
      avgProtein: (json['avgProtein'] as num?)?.toDouble(),
      avgCarbs: (json['avgCarbs'] as num?)?.toDouble(),
      avgFat: (json['avgFat'] as num?)?.toDouble(),
      avgWater: (json['avgWater'] as num?)?.toDouble(),
      totalDays: json['totalDays'] as int?,
    );
  }
}

/// Dữ liệu calo theo từng ngày (dùng trong biểu đồ)
class DailyCalorieEntry {
  final String? date;
  final double? calories;

  const DailyCalorieEntry({this.date, this.calories});

  factory DailyCalorieEntry.fromJson(Map<String, dynamic> json) {
    return DailyCalorieEntry(
      date: json['date'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
    );
  }
}
