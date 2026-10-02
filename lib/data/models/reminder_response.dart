/// Response nhắc nhở hàng ngày từ AI
/// Tương đương: ReminderResponse.java
class ReminderResponse {
  final String? message;
  final String? summary;

  const ReminderResponse({this.message, this.summary});

  factory ReminderResponse.fromJson(Map<String, dynamic> json) {
    return ReminderResponse(
      message: json['message'] as String?,
      summary: json['summary'] as String?,
    );
  }

  String get displayText => message ?? summary ?? '';
}
