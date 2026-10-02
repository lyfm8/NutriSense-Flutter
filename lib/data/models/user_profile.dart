/// Thông tin hồ sơ người dùng
/// Tương đương: UserProfile.java
class UserProfile {
  final int? userId;
  final String? authUid;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final double? heightCm;
  final double? weightKg;
  final String? gender;
  final String? dateOfBirth;
  final String? activityLevel;
  final String? goal;
  final int? dailyCalorieGoal;
  final int? waterGoalMl;

  const UserProfile({
    this.userId,
    this.authUid,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.heightCm,
    this.weightKg,
    this.gender,
    this.dateOfBirth,
    this.activityLevel,
    this.goal,
    this.dailyCalorieGoal,
    this.waterGoalMl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as int?,
      authUid: json['authUid'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      activityLevel: json['activityLevel'] as String?,
      goal: json['goal'] as String?,
      dailyCalorieGoal: json['dailyCalorieGoal'] as int?,
      waterGoalMl: json['waterGoalMl'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (authUid != null) 'authUid': authUid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (heightCm != null) 'heightCm': heightCm,
      if (weightKg != null) 'weightKg': weightKg,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (activityLevel != null) 'activityLevel': activityLevel,
      if (goal != null) 'goal': goal,
      if (dailyCalorieGoal != null) 'dailyCalorieGoal': dailyCalorieGoal,
      if (waterGoalMl != null) 'waterGoalMl': waterGoalMl,
    };
  }

  /// Tính BMI từ height và weight
  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }

  /// Kiểm tra profile đã đủ thông tin chưa (để redirect sang Survey nếu chưa)
  bool get isProfileComplete => heightCm != null && weightKg != null;
}
