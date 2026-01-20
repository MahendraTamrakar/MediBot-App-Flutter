import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/storage_keys.dart';
import '../../models/chat/chat_message.dart';
import '../../models/chat/chat_session.dart';

class DatabaseService {

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(StorageKeys.chatMessagesBox);
    await Hive.openBox(StorageKeys.chatSessionsBox);
    await Hive.openBox(StorageKeys.settingsBox);
  }


  /// Save chat message to local database
  Future<void> saveChatMessage(String sessionId, ChatMessage message) async {
    final box = Hive.box(StorageKeys.chatMessagesBox);
    
    // Use sessionId as key prefix
    final key = '${sessionId}_${message.timestamp.millisecondsSinceEpoch}';
    
    await box.put(key, message.toJson());
  }

  /// Get all messages for a session
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    final box = Hive.box(StorageKeys.chatMessagesBox);
    
    final messages = <ChatMessage>[];
    
    for (final key in box.keys) {
      if (key.toString().startsWith(sessionId)) {
        final data = box.get(key) as Map<dynamic, dynamic>;
        final message = ChatMessage.fromJson(Map<String, dynamic>.from(data));
        messages.add(message);
      }
    }
    
    // Sort by timestamp
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return messages;
  }

  /// Delete all messages for a session
  Future<void> deleteChatMessages(String sessionId) async {
    final box = Hive.box(StorageKeys.chatMessagesBox);
    
    final keysToDelete = <dynamic>[];
    
    for (final key in box.keys) {
      if (key.toString().startsWith(sessionId)) {
        keysToDelete.add(key);
      }
    }
    
    await box.deleteAll(keysToDelete);
  }

  /// Delete all chat messages
  Future<void> deleteAllChatMessages() async {
    final box = Hive.box(StorageKeys.chatMessagesBox);
    await box.clear();
  }


  /// Save chat session to local database
  Future<void> saveChatSession(ChatSession session) async {
    final box = Hive.box(StorageKeys.chatSessionsBox);
    await box.put(session.sessionId, session.toJson());
  }

  /// Get all chat sessions
  Future<List<ChatSession>> getChatSessions() async {
    final box = Hive.box(StorageKeys.chatSessionsBox);
    
    final sessions = <ChatSession>[];
    
    for (final value in box.values) {
      final data = value as Map<dynamic, dynamic>;
      final session = ChatSession.fromJson(Map<String, dynamic>.from(data));
      sessions.add(session);
    }
    
    // Sort by most recent
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return sessions;
  }

  /// Get specific chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    final box = Hive.box(StorageKeys.chatSessionsBox);
    final data = box.get(sessionId);
    
    if (data == null) return null;
    
    return ChatSession.fromJson(Map<String, dynamic>.from(data));
  }

  /// Delete chat session
  Future<void> deleteChatSession(String sessionId) async {
    final box = Hive.box(StorageKeys.chatSessionsBox);
    await box.delete(sessionId);
    
    // Also delete messages for this session
    await deleteChatMessages(sessionId);
  }

  /// Delete all chat sessions
  Future<void> deleteAllChatSessions() async {
    final box = Hive.box(StorageKeys.chatSessionsBox);
    await box.clear();
    
    // Also delete all messages
    await deleteAllChatMessages();
  }



  /// Save any data to settings box
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(StorageKeys.settingsBox);
    await box.put(key, value);
  }

  /// Get data from settings box
  dynamic getSetting(String key) {
    final box = Hive.box(StorageKeys.settingsBox);
    return box.get(key);
  }

  /// Delete setting
  Future<void> deleteSetting(String key) async {
    final box = Hive.box(StorageKeys.settingsBox);
    await box.delete(key);
  }



  /// Get database size (number of items)
  Future<Map<String, int>> getDatabaseSize() async {
    return {
      'messages': Hive.box(StorageKeys.chatMessagesBox).length,
      'sessions': Hive.box(StorageKeys.chatSessionsBox).length,
      'settings': Hive.box(StorageKeys.settingsBox).length,
    };
  }

  /// Clear entire database
  Future<void> clearAll() async {
    await Future.wait([
      Hive.box(StorageKeys.chatMessagesBox).clear(),
      Hive.box(StorageKeys.chatSessionsBox).clear(),
      Hive.box(StorageKeys.settingsBox).clear(),
    ]);
  }

  /// Compact database (optimize storage)
  Future<void> compact() async {
    await Future.wait([
      Hive.box(StorageKeys.chatMessagesBox).compact(),
      Hive.box(StorageKeys.chatSessionsBox).compact(),
      Hive.box(StorageKeys.settingsBox).compact(),
    ]);
  }

  /// Close all boxes (call on app exit)
  Future<void> close() async {
    await Hive.close();
  }
}