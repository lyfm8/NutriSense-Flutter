/// Tin nhắn trong chat với AI
/// Tương đương: ChatMessageDTO.java
class ChatMessageDto {
  final int? id;
  final int? userId;
  final String? role; // "user" hoặc "assistant"
  final String? content;
  final String? createdAt;
  final bool? isRead;

  const ChatMessageDto({
    this.id,
    this.userId,
    this.role,
    this.content,
    this.createdAt,
    this.isRead,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      role: json['role'] as String?,
      content: json['content'] as String?,
      createdAt: json['createdAt'] as String?,
      isRead: json['isRead'] as bool?,
    );
  }

  bool get isFromUser => role == 'user';
  bool get isFromAssistant => role == 'assistant';
}

/// Request gửi tin nhắn đến AI
/// Tương đương: ChatSendRequest.java
class ChatSendRequest {
  final int userId;
  final String message;

  const ChatSendRequest({required this.userId, required this.message});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'message': message,
      };
}
