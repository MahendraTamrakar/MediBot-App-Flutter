import '../data_sources/remote/user_api_service.dart';
import '../data_sources/local/secure_storage_service.dart';

class UserRepository {
  final UserApiService _userApiService;
  final SecureStorageService _secureStorage;

  UserRepository({
    required UserApiService userApiService,
    required SecureStorageService secureStorage,
  })  : _userApiService = userApiService,
        _secureStorage = secureStorage;

  //hard delete - deletes all data of current's user
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

  Future<bool> checkApiHealth() async {
    try {
      final health = await _userApiService.healthCheck();

      return health['status'] == 'healthy';
    } catch (e) {
      return false;
    }
  }

/*   Future<String?> getApiVersion() async {
    try {
      final health = await _userApiService.healthCheck();

      return health['version'] as String?;
    } catch (e) {
      return null;
    }
  } */

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