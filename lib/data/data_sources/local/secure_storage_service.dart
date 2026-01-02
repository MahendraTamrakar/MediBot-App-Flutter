import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/storage_keys.dart';

/// Secure storage service for sensitive data (tokens, passwords, etc.)
/// 
/// Uses flutter_secure_storage which provides encrypted storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// 
/// Use this for:
/// - Authentication tokens
/// - User credentials
/// - Any sensitive user data
class SecureStorageService {
  // Create secure storage instance with options
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
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
  Future<String?> getIdToken() async {
    return await _storage.read(key: StorageKeys.idToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
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
  Future<bool> hasToken() async {
    final token = await getIdToken();
    return token != null && token.isNotEmpty;
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