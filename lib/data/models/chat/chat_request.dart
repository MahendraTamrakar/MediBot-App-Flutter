/// Chat request DTO
class ChatRequest {
  final String? sessionId;
  final String symptoms;

  ChatRequest({
    this.sessionId,
    required this.symptoms,
  });

  /// Convert to JSON (send to backend)
  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'session_id': sessionId,
      'symptoms': symptoms,
    };
  }
}