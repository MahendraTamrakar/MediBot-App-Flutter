/// Chat response DTO (for non-streaming endpoint)
class ChatResponse {
  final String sessionId;
  final String? title;
  final String response;
  final String? emergencyLevel;
  final List<String>? followUpQuestions;

  ChatResponse({
    required this.sessionId,
    this.title,
    required this.response,
    this.emergencyLevel,
    this.followUpQuestions,
  });

  /// Create from JSON (from backend)
  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      sessionId: json['session_id'] as String,
      title: json['title'] as String?,
      response: json['response'] as String,
      emergencyLevel: json['emergency_level'] as String?,
      followUpQuestions: json['followup_questions'] != null
          ? List<String>.from(json['followup_questions'] as List)
          : null,
    );
  }

  /// Check if emergency
  bool get isEmergency =>
      emergencyLevel != null && emergencyLevel!.toLowerCase() == 'high';
}