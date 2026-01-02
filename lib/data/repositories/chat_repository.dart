import 'dart:developer' show log;

import '../data_sources/remote/chat_api_service.dart';
import '../models/chat/chat_request.dart';
import '../models/chat/chat_response.dart';
import '../models/chat/chat_session.dart';
import '../models/chat/chat_message.dart';

/// Chat repository - Business logic for chat operations
///
/// Coordinates:
/// - Chat API service (remote data)
/// - Local caching (optional - can add later)
/// - Error handling and data transformation
class ChatRepository {
  final ChatApiService _chatApiService;

  ChatRepository({required ChatApiService chatApiService})
    : _chatApiService = chatApiService;

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE (NON-STREAMING)
  // ══════════════════════════════════════════════════════════════════════════

  /// Send a message and get response
  ///
  /// [message] - User's message/symptoms
  /// [sessionId] - Optional session ID (creates new session if null)
  ///
  /// Returns ChatResponse with session info and AI response
  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final request = ChatRequest(sessionId: sessionId, symptoms: message);

      final response = await _chatApiService.analyzeSymptoms(request);

      // Optional: Save to local cache here
      // await _saveToCache(response);

      return response;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE (STREAMING)
  // ══════════════════════════════════════════════════════════════════════════

  /// Send a message and get streaming response
  ///
  /// Returns a Stream of tokens that can be displayed in real-time
  ///
  /// Example usage:
  /// ```dart
  /// await for (final token in chatRepo.sendMessageStream(message)) {
  ///   print(token); // Update UI with each token
  /// }
  /// ```
  Stream<String> sendMessageStream({
    required String message,
    String? sessionId,
  }) async* {
    try {
      final request = ChatRequest(sessionId: sessionId, symptoms: message);

      // Yield tokens from API service
      await for (final token in _chatApiService.analyzeSymptomsStream(
        request,
      )) {
        yield token;
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT SESSIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get all chat sessions
  ///
  /// Returns list of chat sessions sorted by most recent
  Future<List<ChatSession>> getChatSessions() async {
    try {
      final sessions = await _chatApiService.listChats();

      // Sort by most recent first
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return sessions;
    } catch (e) {
      throw Exception('Failed to get chat sessions: $e');
    }
  }

  /// Get messages for a specific chat session
  ///
  /// [sessionId] - The session ID to get messages for
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    try {
      final messages = await _chatApiService.getChatMessages(sessionId);

      return messages;
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  /// Get a specific chat session with messages
  ///
  /// [sessionId] - The session ID to get
  Future<ChatSession> getChatSession(String sessionId) async {
    try {
      // Get all sessions
      final sessions = await _chatApiService.listChats();

      // Find the specific session
      final session = sessions.firstWhere(
        (s) => s.sessionId == sessionId,
        orElse: () => throw Exception('Session not found'),
      );

      // Get messages for this session
      final messages = await _chatApiService.getChatMessages(sessionId);

      // Return session with messages
      return ChatSession(
        sessionId: session.sessionId,
        title: session.title,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
        messages: messages,
      );
    } catch (e) {
      throw Exception('Failed to get chat session: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Delete a specific chat session
  ///
  /// [sessionId] - The session ID to delete
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _chatApiService.deleteChatSession(sessionId);

      // Optional: Clear from local cache
      // await _removeFromCache(sessionId);
    } catch (e) {
      throw Exception('Failed to delete chat session: $e');
    }
  }

  /// Delete all chat sessions
  ///
  /// Returns the number of sessions deleted
  Future<int> deleteAllChats() async {
    try {
      final result = await _chatApiService.deleteAllChats();

      // Optional: Clear local cache
      // await _clearAllCache();

      return result['deleted_sessions'] as int? ?? 0;
    } catch (e) {
      throw Exception('Failed to delete all chats: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // END CHAT
  // ══════════════════════════════════════════════════════════════════════════

  /// End chat and trigger profile update
  ///
  /// This should be called when user leaves the chat screen.
  /// It triggers the backend to update the medical profile based on chat history.
  Future<bool> endChat() async {
    try {
      final result = await _chatApiService.endChat();

      final profileUpdated = result['profile_updated'] as bool? ?? false;

      return profileUpdated;
    } catch (e) {
      // Don't throw error - this is a background operation
      log('Failed to end chat: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD DOCUMENT TO CHAT
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload a document to a chat session
  ///
  /// [sessionId] - The session to upload to
  /// [filePath] - Path to the document file
  ///
  /// Returns document ID and extracted text length
  Future<Map<String, dynamic>> uploadDocument({
    required String sessionId,
    required String filePath,
  }) async {
    try {
      final result = await _chatApiService.uploadDocument(
        sessionId: sessionId,
        filePath: filePath,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get chat statistics
  ///
  /// Returns total number of sessions and messages
  Future<Map<String, int>> getChatStatistics() async {
    try {
      final sessions = await getChatSessions();

      int totalMessages = 0;
      for (final session in sessions) {
        totalMessages += session.messageCount;
      }

      return {
        'total_sessions': sessions.length,
        'total_messages': totalMessages,
      };
    } catch (e) {
      throw Exception('Failed to get chat statistics: $e');
    }
  }

  /// Search chat history
  ///
  /// [query] - Search query
  ///
  /// Returns sessions that match the query
  Future<List<ChatSession>> searchChatHistory(String query) async {
    try {
      final sessions = await getChatSessions();

      // Filter sessions by title or messages
      final filtered =
          sessions.where((session) {
            final titleMatch =
                session.title?.toLowerCase().contains(query.toLowerCase()) ??
                false;
            return titleMatch;
          }).toList();

      return filtered;
    } catch (e) {
      throw Exception('Failed to search chat history: $e');
    }
  }
}
