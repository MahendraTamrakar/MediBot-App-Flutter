import 'package:medibot/data/models/chat/chat_message.dart';

/// Chat session model
class ChatSession {
  final String sessionId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage>? messages;

  ChatSession({
    required this.sessionId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  /// Create from JSON (from backend)
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (messages != null)
        'messages': messages!.map((m) => m.toJson()).toList(),
    };
  }

  /// Get message count
  int get messageCount => messages?.length ?? 0;

  /// Get last message
  ChatMessage? get lastMessage =>
      messages != null && messages!.isNotEmpty ? messages!.last : null;
}