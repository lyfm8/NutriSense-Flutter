/// Response nhắc nhở hàng ngày từ AI
/// Tương đương: ReminderResponseDto.java
class ReminderResponse {
  final String? notificationText;
  final String? detailText;

  const ReminderResponse({this.notificationText, this.detailText});

  factory ReminderResponse.fromJson(Map<String, dynamic> json) {
    return ReminderResponse(
      notificationText: json['notificationText'] as String?,
      detailText: json['detailText'] as String?,
    );
  }

  String get displayText => detailText ?? notificationText ?? '';
}