import 'dart:developer' show log;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/storage_keys.dart';

/// Secure storage service for sensitive data (tokens, passwords, etc.)
/// 
/// Uses flutter_secure_storage which provides encrypted storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (with resetOnError for resilience)
/// 
/// Use this for:
/// - Authentication tokens
/// - User credentials
/// - Any sensitive user data
class SecureStorageService {
  // Create secure storage instance with options
  // resetOnError: true - If there's a decryption error (e.g., after app reinstall),
  // the storage will be cleared rather than throwing an error
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION TOKENS
  // ══════════════════════════════════════════════════════════════════════════

  /// Save authentication tokens (ID token, refresh token, UID)
  Future<void> saveTokens({
    required String idToken,
    required String refreshToken,
    required String uid,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.idToken, value: idToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
      _storage.write(key: StorageKeys.uid, value: uid),
    ]);
  }

  /// Get ID token (Firebase JWT)
  /// 
  /// Returns null if token doesn't exist or if there's an error reading storage
  Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: StorageKeys.idToken);
    } catch (e) {
      log('❌ Error reading ID token from secure storage: $e');
      // On some Android devices, encrypted storage can become corrupted
      // In that case, we return null and the user will need to re-login
      return null;
    }
  }

  /// Get refresh token
  /// 
  /// Returns null if token doesn't exist or if there's an error reading storage
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: StorageKeys.refreshToken);
    } catch (e) {
      log('❌ Error reading refresh token from secure storage: $e');
      return null;
    }
  }

  /// Get user UID
  Future<String?> getUid() async {
    return await _storage.read(key: StorageKeys.uid);
  }

  /// Update ID token (after refresh)
  Future<void> updateIdToken(String newIdToken) async {
    await _storage.write(key: StorageKeys.idToken, value: newIdToken);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER DATA
  // ══════════════════════════════════════════════════════════════════════════

  /// Save user email
  Future<void> saveEmail(String email) async {
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  /// Get user email
  Future<String?> getEmail() async {
    return await _storage.read(key: StorageKeys.userEmail);
  }

  /// Save user display name
  Future<void> saveDisplayName(String displayName) async {
    await _storage.write(key: StorageKeys.displayName, value: displayName);
  }

  /// Get user display name
  Future<String?> getDisplayName() async {
    return await _storage.read(key: StorageKeys.displayName);
  }

  /// Save user photo URL
  Future<void> savePhotoUrl(String photoUrl) async {
    await _storage.write(key: StorageKeys.photoUrl, value: photoUrl);
  }

  /// Get user photo URL
  Future<String?> getPhotoUrl() async {
    return await _storage.read(key: StorageKeys.photoUrl);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CUSTOM KEY-VALUE OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Write a custom key-value pair
  /// 
  /// Example:
  /// ```dart
  /// await secureStorage.write('api_key', 'abc123');
  /// ```
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a custom key
  /// 
  /// Example:
  /// ```dart
  /// final apiKey = await secureStorage.read('api_key');
  /// ```
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a custom key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEAR DATA
  // ══════════════════════════════════════════════════════════════════════════

  /// Clear all authentication data (logout)
  Future<void> clearAll() async {
    log('🗑️ CLEARING ALL SECURE STORAGE DATA');
    // Print stack trace to help identify what's calling this
    log(StackTrace.current.toString().split('\n').take(10).join('\n'));
    await _storage.deleteAll();
  }

  /// Clear only authentication tokens (keep user data)
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.idToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  /// Clear only user data (keep tokens)
  Future<void> clearUserData() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.userEmail),
      _storage.delete(key: StorageKeys.displayName),
      _storage.delete(key: StorageKeys.photoUrl),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if user has valid token (is logged in)
  /// 
  /// Returns true if a non-empty ID token exists in secure storage
  Future<bool> hasToken() async {
    try {
      final token = await getIdToken();
      final hasValidToken = token != null && token.isNotEmpty;
      log('🔑 Token check: ${hasValidToken ? "Token exists" : "No token found"}');
      return hasValidToken;
    } catch (e) {
      log('❌ Error checking token: $e');
      return false;
    }
  }

  /// Get all stored keys
  Future<Map<String, String>> getAllData() async {
    return await _storage.readAll();
  }

  /// Get data size (number of stored items)
  Future<int> getDataSize() async {
    final data = await _storage.readAll();
    return data.length;
  }
}