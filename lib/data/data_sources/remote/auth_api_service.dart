import 'dart:developer' show log;

import 'package:dio/dio.dart';
import 'package:medibot/core/constants/api_constants.dart';
import 'package:medibot/data/models/auth/signup_resquest.dart';
import 'api_client.dart';
import '../../models/auth/login_request.dart';
import '../../models/auth/login_response.dart';
import '../../models/auth/signup_response.dart';

/// Authentication API service
/// 
/// Handles all authentication-related API calls:
/// - Email/password sign up
/// - Email/password sign in
/// - Google Sign-In
/// - Password reset
/// - Token refresh (optional)
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign up with email and password
  /// 
  /// Endpoint: POST /auth/signup/email
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "email": "user@example.com",
  ///   "password": "password123"
  /// }
  /// ```
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "idToken": "...",
  ///   "refreshToken": "...",
  ///   "expiresIn": 3600,
  ///   "uid": "user123",
  ///   "emailVerified": false
  /// }
  /// ```
  Future<SignupResponse> signUp(SignupRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup/email',
        data: request.toJson(),
      );

      return SignupResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign in with email and password
  /// 
  /// Endpoint: POST /auth/login/email
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "email": "user@example.com",
  ///   "password": "password123"
  /// }
  /// ```
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "idToken": "...",
  ///   "refreshToken": "...",
  ///   "expiresIn": 3600,
  ///   "uid": "user123",
  ///   "emailVerified": true
  /// }
  /// ```
  Future<LoginResponse> signIn(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/login/email',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN IN
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign in with Google ID token
  /// 
  /// Endpoint: POST /auth/login/google
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "id_token": "google_id_token_here"
  /// }
  /// ```
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "idToken": "...",
  ///   "refreshToken": "...",
  ///   "expiresIn": 3600,
  ///   "uid": "user123",
  ///   "emailVerified": true
  /// }
  /// ```
  Future<LoginResponse> signInWithGoogle(String googleIdToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/login/google',
        data: {'id_token': googleIdToken},
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════════

  /// Send password reset email
  /// 
  /// Endpoint: POST /auth/forgot-password
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "email": "user@example.com"
  /// }
  /// ```
  /// 
  /// Response: 200 OK (no body)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await _apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('✅ Password reset email sent successfully');
        return;
      }

      // Handle errors
      final data = response.data;
      final message = data is Map ? data['message'] ?? data['error'] : null;

      if (response.statusCode == 400) {
        throw Exception(message ?? 'Invalid email address');
      } else if (response.statusCode == 404) {
        throw Exception(message ?? 'Email not found');
      } else if (response.statusCode == 429) {
        throw Exception(message ?? 'Too many requests. Please try again later');
      } else {
        throw Exception(message ?? 'Failed to send reset email');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      log('❌ Password reset error: $e');
      rethrow;
    }
  }


  // ══════════════════════════════════════════════════════════════════════════
  // TOKEN REFRESH (Optional - if your backend supports it)
  // ══════════════════════════════════════════════════════════════════════════

  /// Refresh ID token using refresh token
  /// 
  /// Endpoint: POST /auth/token/refresh
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "refresh_token": "..."
  /// }
  /// ```
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "idToken": "new_id_token",
  ///   "refreshToken": "new_refresh_token",
  ///   "expiresIn": 3600
  /// }
  /// ```
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/token/refresh',
        data: {'refresh_token': refreshToken},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  // Add this method to your existing AuthApiService class:

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE ACCOUNT
  // ══════════════════════════════════════════════════════════════════════════

  /// Delete user account
  /// DELETE /auth/delete-account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.deleteAccount, // Add this constant: '/auth/delete-account'
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VERIFY EMAIL (Optional)
  // ══════════════════════════════════════════════════════════════════════════

  /// Send email verification link
  /// 
  /// Endpoint: POST /auth/email/verify/send
  /// 
  /// Response: 200 OK
  Future<void> sendEmailVerification() async {
    try {
      await _apiClient.post('/auth/email/verify/send');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if email is verified
  /// 
  /// Endpoint: GET /auth/email/verify/check
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "emailVerified": true
  /// }
  /// ```
  Future<bool> checkEmailVerification() async {
    try {
      final response = await _apiClient.get('/auth/email/verify/check');
      return response.data['emailVerified'] as bool;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  /// Handle API errors and convert to user-friendly messages
  String _handleError(DioException error) {
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Extract error message from response
      String message = 'An error occurred';

      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? data['message'] ?? message;
      } else if (data is String) {
        message = data;
      }

      // Handle specific status codes
      switch (statusCode) {
        case 400:
          return _parseBadRequestError(message, data);
        case 401:
          return 'Invalid credentials';
        case 403:
          return 'Access denied';
        case 404:
          return 'Account not found';
        case 409:
          return _parseConflictError(message, data);
        case 422:
          return _parseValidationError(data);
        case 429:
          return 'Too many requests. Please try again later';
        case 500:
          return 'Server error. Please try again later';
        case 503:
          return 'Service temporarily unavailable';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection';
    } else if (error.type == DioExceptionType.sendTimeout) {
      return 'Request timeout. Please try again';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network';
    } else if (error.type == DioExceptionType.badResponse) {
      return 'Invalid server response';
    }

    return 'An unexpected error occurred';
  }

  /// Parse 400 Bad Request errors
  String _parseBadRequestError(String message, dynamic data) {
    if (message.toLowerCase().contains('email')) {
      return 'Invalid email format';
    }
    if (message.toLowerCase().contains('password')) {
      return 'Password does not meet requirements';
    }
    return 'Invalid request: $message';
  }

  /// Parse 409 Conflict errors
  String _parseConflictError(String message, dynamic data) {
    if (message.toLowerCase().contains('email')) {
      return 'An account with this email already exists';
    }
    if (message.toLowerCase().contains('exists')) {
      return 'Account already exists';
    }
    return message;
  }

  /// Parse 422 Validation errors
  String _parseValidationError(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'] as List<dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is Map<String, dynamic>) {
          return firstError['message'] ?? 'Validation error';
        }
      }
    }
    return 'Validation error';
  }
}