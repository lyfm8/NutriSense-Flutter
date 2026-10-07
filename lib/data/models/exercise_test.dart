class ExerciseTest {
  final int? testId;
  final int? userId;
  final String? testDate;
  final String? testType; // VD: 'pushups', 'situps', 'running_1km', 'plank_seconds'
  final double? value;
  final String? unit;
  final String? notes;
  final String? createdAt;

  const ExerciseTest({
    this.testId,
    this.userId,
    this.testDate,
    this.testType,
    this.value,
    this.unit,
    this.notes,
    this.createdAt,
  });

  factory ExerciseTest.fromJson(Map<String, dynamic> json) {
    return ExerciseTest(
      testId: json['testId'] as int?,
      userId: json['userId'] as int?,
      testDate: json['testDate'] as String?,
      testType: json['testType'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (testId != null) 'testId': testId,
      if (userId != null) 'userId': userId,
      if (testDate != null) 'testDate': testDate,
      if (testType != null) 'testType': testType,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
    };
  }
}