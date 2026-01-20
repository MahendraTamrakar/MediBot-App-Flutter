import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/data_sources/local/database_service.dart';
import '../../../services/connectivity_service.dart';
import 'package:flutter/material.dart';
import '../../../data/models/chat/chat_message.dart';
import '../../../data/models/chat/chat_session.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatProvider(this._chatRepository);

  List<ChatMessage> _messages = [];
  List<ChatSession> _chatSessions = [];
  bool _isTyping = false;
  bool _isCancelled = false;
  String? _errorMessage;
  String? _currentSessionId;
  bool _sessionsLoading = false;


  List<ChatMessage> get messages => _messages;
  List<ChatSession> get chatSessions => _chatSessions;
  bool get isTyping => _isTyping;
  bool get isStreaming => false; // Always false now (no streaming)
  bool get sessionsLoading => _sessionsLoading;
  String? get errorMessage => _errorMessage;
  String? get currentSessionId => _currentSessionId;
  bool get hasMessages => _messages.isNotEmpty;

  /// Get current session title from chatSessions list
  String? get currentSessionTitle {
    if (_currentSessionId == null) return null;
    try {
      final session = _chatSessions.firstWhere(
        (s) => s.sessionId == _currentSessionId,
      );
      return session.title;
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    log('📤 sendMessage called with: $content');

    // Reset cancellation flag
    _isCancelled = false;

    // Add user message
    final userMessage = ChatMessage(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    log('✅ User message added, total messages: ${_messages.length}');
    _errorMessage = null;
    _isTyping = true;
    notifyListeners();

    try {
      // Get response from repository (non-streaming)
      // firebase_uid is sent via JWT token in Authorization header
      final response = await _chatRepository.sendMessage(
        message: content,
        sessionId: _currentSessionId,
      );

      // Check if request was cancelled
      if (_isCancelled) {
        log('🛑 Request was cancelled');
        return;
      }

        // Log all fields of ChatResponse for debugging
        log('🟢 Backend response:'
          '\n  sessionId: [32m${response.sessionId}[0m'
          '\n  title: [32m${response.title}[0m'
          '\n  response: [32m${response.response}[0m'
          '\n  emergencyLevel: [32m${response.emergencyLevel}[0m'
          '\n  followUpQuestions: [32m${response.followUpQuestions}[0m');

      // Update session ID if new session was created
      if (response.sessionId != null && _currentSessionId != response.sessionId) {
        _currentSessionId = response.sessionId;
        // Refresh chat sessions list since a new session was created
        _refreshChatSessions();
      }

      // Add assistant message
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response.response,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      
      _isTyping = false;
      notifyListeners();
    } catch (e) {
      if (_isCancelled) {
        log('🛑 Request was cancelled');
        return;
      }
      log('❌ Error sending message: $e');
      if (e is Exception && e.toString().contains('DioException')) {
        log('❌ DioException details: $e');
      }
      _errorMessage = e.toString();
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> sendMessageWithFile(String content, File file) async {
    // Add user message with file indicator
    final userMessage = ChatMessage(
      role: 'user',
      content: content.isNotEmpty 
          ? '$content\n\n📎 Attached: ${file.path.split('/').last}'
          : '📎 Attached: ${file.path.split('/').last}',
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _errorMessage = null;
    _isTyping = true;
    notifyListeners();

    try {
      // First upload the document if we have a session
      if (_currentSessionId != null) {
        await _chatRepository.uploadDocument(
          sessionId: _currentSessionId!,
          filePath: file.path,
        );
      }
      
      // Then get response (non-streaming)
      final messageContent = content.isNotEmpty 
          ? content 
          : 'Please analyze the attached document.';
      
      final response = await _chatRepository.sendMessage(
        message: messageContent,
        sessionId: _currentSessionId,
      );

      // Update session ID
      if (response.sessionId != null) {
        _currentSessionId = response.sessionId;
      }

      // Add assistant message
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response.response,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      
      _isTyping = false;
      notifyListeners();
    } catch (e) {
      log('❌ Error sending message with file: $e');
      _errorMessage = e.toString();
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> stopStreaming() async {
    log('🛑 Cancelling request');
    _isCancelled = true;
    _isTyping = false;
    notifyListeners();
  }

  Future<void> loadChatSession(String sessionId) async {
    try {
      print('📥 Loading chat session: $sessionId');
      
      final messages = await _chatRepository.getChatMessages(sessionId);
      
      _messages = messages;
      _currentSessionId = sessionId;
      _errorMessage = null;
      
      print('✅ Loaded ${_messages.length} messages');
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load session: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void newConversation() {
    _messages.clear();
    _errorMessage = null;
    _currentSessionId = null;
    _isTyping = false;
    notifyListeners();
  }

  Future<List<ChatSession>> getChatSessions() async {
    try {
      return await _chatRepository.getChatSessions();
    } catch (e) {
      print('❌ Failed to get chat sessions: $e');
      throw Exception('Failed to load chat history');
    }
  }

  /// Fetch and update chat sessions list
  Future<void> fetchChatSessions({BuildContext? context}) async {
    _sessionsLoading = true;
    notifyListeners();

    bool isConnected = true;
    if (context != null) {
      try {
        final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
        isConnected = await connectivityService.hasConnection();
      } catch (_) {
        isConnected = true; // fallback: assume online if service not available
      }
    }

    try {
      if (isConnected) {
        _chatSessions = await _chatRepository.getChatSessions();
      } else {
        // Offline: load only session metadata from Hive
        _chatSessions = await DatabaseService().getChatSessions();
        // Remove messages if present (just in case)
        _chatSessions = _chatSessions.map((s) => ChatSession(
          sessionId: s.sessionId,
          title: s.title,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          messages: null,
        )).toList();
      }
    } catch (e) {
      print('❌ Failed to fetch chat sessions: $e');
    }

    _sessionsLoading = false;
    notifyListeners();
  }

  /// Internal method to refresh sessions in background
  void _refreshChatSessions() {
    // Fetch in background without blocking
    _chatRepository.getChatSessions().then((sessions) {
      _chatSessions = sessions;
      notifyListeners();
    }).catchError((e) {
      print('⚠️ Failed to refresh chat sessions: $e');
    });
  }

  //delete all chats
  Future<int> deleteAllChats() async {
    try {
      log('🗑️ Deleting all chats');
      
      final deletedCount = await _chatRepository.deleteAllChats();
      
      // Clear local messages
      _messages.clear();
      _currentSessionId = null;
      _errorMessage = null;
      
      log('✅ Deleted $deletedCount chat sessions');
      notifyListeners();
      
      return deletedCount;
    } catch (e) {
      log('❌ Failed to delete all chats: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _chatRepository.deleteChatSession(sessionId);
      
      // If we deleted the current session, start new conversation
      if (_currentSessionId == sessionId) {
        newConversation();
      }
    } catch (e) {
      print('❌ Failed to delete session: $e');
      throw Exception('Failed to delete conversation');
    }
  }

  Future<void> endChat() async {
    try {
      await _chatRepository.endChat();
      print('✅ Chat ended and profile updated');
    } catch (e) {
      print('⚠️ Failed to end chat: $e');
    }
  }
}