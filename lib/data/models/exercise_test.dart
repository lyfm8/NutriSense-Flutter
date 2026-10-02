/// Kết quả bài test thể lực
/// Tương đương: ExerciseTest.java
class ExerciseTest {
  final int? id;
  final int? userId;
  final String? testDate;
  final int? pushUps;
  final int? sitUps;
  final double? runDistanceKm;
  final int? runTimeSeconds;
  final String? fitnessLevel; // poor, fair, good, excellent
  final String? notes;

  const ExerciseTest({
    this.id,
    this.userId,
    this.testDate,
    this.pushUps,
    this.sitUps,
    this.runDistanceKm,
    this.runTimeSeconds,
    this.fitnessLevel,
    this.notes,
  });

  factory ExerciseTest.fromJson(Map<String, dynamic> json) {
    return ExerciseTest(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      testDate: json['testDate'] as String?,
      pushUps: json['pushUps'] as int?,
      sitUps: json['sitUps'] as int?,
      runDistanceKm: (json['runDistanceKm'] as num?)?.toDouble(),
      runTimeSeconds: json['runTimeSeconds'] as int?,
      fitnessLevel: json['fitnessLevel'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (testDate != null) 'testDate': testDate,
      if (pushUps != null) 'pushUps': pushUps,
      if (sitUps != null) 'sitUps': sitUps,
      if (runDistanceKm != null) 'runDistanceKm': runDistanceKm,
      if (runTimeSeconds != null) 'runTimeSeconds': runTimeSeconds,
      if (fitnessLevel != null) 'fitnessLevel': fitnessLevel,
      if (notes != null) 'notes': notes,
    };
  }
}
