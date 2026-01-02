import '../data_sources/remote/user_api_service.dart';
import '../data_sources/local/secure_storage_service.dart';

/// User repository - Business logic for user account operations
/// 
/// Coordinates:
/// - User API service (remote data)
/// - Secure storage (local data)
/// - Account management operations
class UserRepository {
  final UserApiService _userApiService;
  final SecureStorageService _secureStorage;

  UserRepository({
    required UserApiService userApiService,
    required SecureStorageService secureStorage,
  })  : _userApiService = userApiService,
        _secureStorage = secureStorage;

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE ACCOUNT
  // ══════════════════════════════════════════════════════════════════════════

  /// Delete the current user's account (hard delete)
  /// 
  /// This will permanently delete:
  /// - User account
  /// - All chat history
  /// - All medical reports
  /// - All profile data
  /// 
  /// Returns true if successful
  Future<bool> deleteAccount() async {
    try {
      // Call API to delete account on backend
      final result = await _userApiService.deleteAccount();

      // Clear all local data
      await _secureStorage.clearAll();

      return result['message'] != null;
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEALTH CHECK
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if API is healthy and responsive
  /// 
  /// Returns true if API is healthy
  Future<bool> checkApiHealth() async {
    try {
      final health = await _userApiService.healthCheck();

      return health['status'] == 'healthy';
    } catch (e) {
      return false;
    }
  }

  /// Get API version
  /// 
  /// Returns the API version string
  Future<String?> getApiVersion() async {
    try {
      final health = await _userApiService.healthCheck();

      return health['version'] as String?;
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER INFO
  // ══════════════════════════════════════════════════════════════════════════

  /// Get current user UID
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.getUid();
  }

  /// Get current user email
  Future<String?> getCurrentUserEmail() async {
    return await _secureStorage.getEmail();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasToken();
  }
}