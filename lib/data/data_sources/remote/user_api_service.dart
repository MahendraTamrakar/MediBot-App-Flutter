import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../../core/constants/api_constants.dart';

/// User API service - Handles user account operations
class UserApiService {
  final ApiClient _apiClient;

  UserApiService(this._apiClient);

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE ACCOUNT
  // ══════════════════════════════════════════════════════════════════════════

  /// Delete the current user's account (hard delete)
  /// DELETE /account
  /// 
  /// This will permanently delete:
  /// - User account
  /// - All chat history
  /// - All medical reports
  /// - All profile data
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.deleteAccount,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEALTH CHECK
  // ══════════════════════════════════════════════════════════════════════════

  /// Check API health status
  /// GET /health
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.health,
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
        message = data['detail'] ?? data['message'] ?? message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Invalid request: $message';
        case 401:
          return 'Unauthorized. Please login again.';
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