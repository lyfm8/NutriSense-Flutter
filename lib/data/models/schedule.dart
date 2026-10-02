/// Lịch sự kiện/nhắc nhở
/// Tương đương: Schedule.java
class Schedule {
  final int? scheduleId;
  final int? userId;
  final String? date;
  final String? eventType; // meal, water_reminder, exercise, study, sleep, rest
  final String? title;
  final String? startTime; // format: "2024-01-15T08:00:00"
  final String? notes;
  final bool? completed;

  const Schedule({
    this.scheduleId,
    this.userId,
    this.date,
    this.eventType,
    this.title,
    this.startTime,
    this.notes,
    this.completed,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['scheduleId'] as int?,
      userId: json['userId'] as int?,
      date: json['scheduleDate'] as String?,
      eventType: json['eventType'] as String?,
      title: json['title'] as String?,
      startTime: json['startTime'] as String?,
      notes: json['notes'] as String?,
      completed: json['completed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (userId != null) 'userId': userId,
      if (date != null) 'scheduleDate': date,
      if (eventType != null) 'eventType': eventType,
      if (title != null) 'title': title,
      if (startTime != null) 'startTime': startTime,
      if (notes != null) 'notes': notes,
      if (completed != null) 'completed': completed,
    };
  }

  /// Lấy giờ hiển thị (HH:mm) từ startTime ISO string
  String get displayTime {
    if (startTime == null || startTime!.length < 16) return '';
    return startTime!.substring(11, 16);
  }

  /// Copy với thuộc tính mới (immutable update)
  Schedule copyWith({bool? completed}) {
    return Schedule(
      scheduleId: scheduleId,
      userId: userId,
      date: date,
      eventType: eventType,
      title: title,
      startTime: startTime,
      notes: notes,
      completed: completed ?? this.completed,
    );
  }
}
