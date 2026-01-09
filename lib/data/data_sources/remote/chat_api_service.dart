import 'dart:convert';
import 'dart:developer' show log;

import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../models/chat/chat_request.dart';
import '../../models/chat/chat_response.dart';
import '../../models/chat/chat_session.dart';
import '../../models/chat/chat_message.dart';
import '../../../core/constants/api_constants.dart';

/// Chat API service - Handles all chat-related endpoints
class ChatApiService {
  final ApiClient _apiClient;

  ChatApiService(this._apiClient);

  // ══════════════════════════════════════════════════════════════════════════
  // ANALYZE SYMPTOMS (NON-STREAMING)
  // ══════════════════════════════════════════════════════════════════════════

  /// Analyze symptoms - non-streaming endpoint
  /// POST /analyze-symptoms
  Future<ChatResponse> analyzeSymptoms(ChatRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.analyzeSymptoms,
        data: request.toJson(),
      );

      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ANALYZE SYMPTOMS (STREAMING WITH SSE)
  // ══════════════════════════════════════════════════════════════════════════

  /// Analyze symptoms - streaming endpoint with Server-Sent Events
  /// POST /analyze-symptoms/stream
  ///
  /// Returns a Stream of tokens that can be listened to for real-time updates
  ///
  /// Example usage:
  /// ```dart
  /// await for (final token in chatService.analyzeSymptomsStream(request)) {
  ///   print(token); // Print each token as it arrives
  /// }
  /// ```
  Stream<String> analyzeSymptomsStream(ChatRequest request) async* {
    try {
      log('🔄 Starting stream request to ${ApiConstants.analyzeSymptoms}');
      log('📤 Request data: ${request.toJson()}');
      
      final response = await _apiClient.post(
        ApiConstants.analyzeSymptoms,
        data: request.toJson(),
        // Configure for SSE streaming
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          },
        ),
      );

      log('✅ Stream response received, status: ${response.statusCode}');
      log('📥 Response headers: ${response.headers}');

      // Parse SSE stream
      final stream = response.data.stream;
      String buffer = '';

      await for (final chunk in stream) {
        final chunkStr = String.fromCharCodes(chunk);
        log('📦 Chunk received: $chunkStr');
        
        buffer += chunkStr;
        final lines = buffer.split('\n');
        
        // Keep the last incomplete line in the buffer
        buffer = lines.removeLast();

        for (final line in lines) {
          log('📝 Processing line: $line');
          
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();

            if (data.isNotEmpty && data != '[DONE]') {
              try {
                final json = jsonDecode(data);
                log('📊 Parsed JSON: $json');

                // Handle different event types
                if (json.containsKey('token')) {
                  yield json['token'] as String;
                } else if (json.containsKey('content')) {
                  // Alternative format: content field
                  yield json['content'] as String;
                } else if (json.containsKey('text')) {
                  // Alternative format: text field
                  yield json['text'] as String;
                } else if (json.containsKey('session')) {
                  // Session info (new chat)
                  log('📋 Session info: ${json['session']}');
                } else if (json.containsKey('done')) {
                  // Stream complete
                  log('✅ Stream complete signal received');
                  return;
                } else if (json.containsKey('error')) {
                  throw Exception(json['error']);
                }
              } catch (e) {
                // If JSON parsing fails, maybe it's plain text
                log('⚠️ JSON parse failed, trying as plain text: $data');
                if (data.isNotEmpty) {
                  yield data;
                }
              }
            }
          } else if (line.isNotEmpty && !line.startsWith(':')) {
            // Non-SSE format - might be plain text streaming
            log('📝 Non-SSE line: $line');
            yield line;
          }
        }
      }
      
      // Process any remaining buffer
      if (buffer.isNotEmpty) {
        log('📦 Processing remaining buffer: $buffer');
        if (buffer.startsWith('data: ')) {
          final data = buffer.substring(6).trim();
          if (data.isNotEmpty && data != '[DONE]') {
            try {
              final json = jsonDecode(data);
              if (json.containsKey('token')) {
                yield json['token'] as String;
              } else if (json.containsKey('content')) {
                yield json['content'] as String;
              }
            } catch (e) {
              yield data;
            }
          }
        }
      }
      
      log('✅ Stream processing complete');
    } on DioException catch (e) {
      log('❌ DioException in stream: ${e.message}');
      log('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      log('❌ Unexpected error in stream: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT SESSIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get all chat sessions
  /// GET /chats
  Future<List<ChatSession>> listChats() async {
    try {
      final response = await _apiClient.get(ApiConstants.listChats);

      final List<dynamic> data = response.data as List;
      return data.map((json) => ChatSession.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get messages for a specific chat session
  /// GET /chats/{session_id}/messages
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getChatMessages(sessionId),
      );

      final List<dynamic> data = response.data as List;
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a specific chat session
  /// DELETE /chats/{session_id}
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _apiClient.delete(ApiConstants.deleteChatSession(sessionId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete all chat sessions
  /// DELETE /chats
  Future<Map<String, dynamic>> deleteAllChats() async {
    try {
      final response = await _apiClient.delete(ApiConstants.deleteAllChats);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // END CHAT
  // ══════════════════════════════════════════════════════════════════════════

  /// End chat and trigger profile update
  /// POST /end-chat
  Future<Map<String, dynamic>> endChat() async {
    try {
      final response = await _apiClient.post(ApiConstants.endChat);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD DOCUMENT TO CHAT
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload document to chat session
  /// POST /chat/upload-document
  Future<Map<String, dynamic>> uploadDocument({
    required String sessionId,
    required String filePath,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'session_id': sessionId,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.post(
        ApiConstants.uploadDocument,
        data: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'An error occurred';

      if (data is Map<String, dynamic>) {
        // Handle FastAPI validation errors (422) which return detail as a list
        final detail = data['detail'];
        if (detail is List) {
          // Extract validation error messages
          message = detail.map((e) {
            if (e is Map<String, dynamic>) {
              return e['msg'] ?? e['message'] ?? e.toString();
            }
            return e.toString();
          }).join(', ');
        } else if (detail is String) {
          message = detail;
        } else if (data['message'] is String) {
          message = data['message'];
        }
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Invalid request: $message';
        case 401:
          return 'Unauthorized. Please login again.';
        case 404:
          return 'Chat session not found';
        case 422:
          return 'Validation error: $message';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.unknown) {
      return 'No internet connection. Please check your network.';
    }

    return 'An unexpected error occurred';
  }
}
