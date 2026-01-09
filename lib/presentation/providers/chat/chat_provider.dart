import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/chat/chat_message.dart';
import '../../../data/models/chat/chat_session.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatProvider(this._chatRepository);

  // ══════════════════════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════════════════════

  List<ChatMessage> _messages = [];
  List<ChatSession> _chatSessions = [];
  bool _isTyping = false;
  bool _isCancelled = false;
  String? _errorMessage;
  String? _currentSessionId;
  bool _sessionsLoading = false;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  List<ChatMessage> get messages => _messages;
  List<ChatSession> get chatSessions => _chatSessions;
  bool get isTyping => _isTyping;
  bool get isStreaming => false; // Always false now (no streaming)
  bool get sessionsLoading => _sessionsLoading;
  String? get errorMessage => _errorMessage;
  String? get currentSessionId => _currentSessionId;
  bool get hasMessages => _messages.isNotEmpty;

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE (NON-STREAMING)
  // ══════════════════════════════════════════════════════════════════════════

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
      _errorMessage = e.toString();
      _isTyping = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE WITH FILE ATTACHMENT
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // STOP/CANCEL REQUEST
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> stopStreaming() async {
    log('🛑 Cancelling request');
    _isCancelled = true;
    _isTyping = false;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD CHAT SESSION
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // NEW CONVERSATION
  // ══════════════════════════════════════════════════════════════════════════

  void newConversation() {
    _messages.clear();
    _errorMessage = null;
    _currentSessionId = null;
    _isTyping = false;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET CHAT SESSIONS LIST
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<ChatSession>> getChatSessions() async {
    try {
      return await _chatRepository.getChatSessions();
    } catch (e) {
      print('❌ Failed to get chat sessions: $e');
      throw Exception('Failed to load chat history');
    }
  }

  /// Fetch and update chat sessions list
  Future<void> fetchChatSessions() async {
    _sessionsLoading = true;
    notifyListeners();
    
    try {
      _chatSessions = await _chatRepository.getChatSessions();
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

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE CHAT SESSION
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // END CHAT (call when leaving chat screen)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> endChat() async {
    try {
      await _chatRepository.endChat();
      print('✅ Chat ended and profile updated');
    } catch (e) {
      print('⚠️ Failed to end chat: $e');
      // Don't throw - this is a background operation
    }
  }
}