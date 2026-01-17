import 'dart:developer' show log;

import 'package:dio/dio.dart';
import '../local/secure_storage_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/storage_keys.dart';

/// Dio API client with automatic token attachment and error handling
///
/// This is the core HTTP client used by all API services.
/// Features:
/// - Automatic token attachment to requests
/// - 401 error handling (token expiration)
/// - Request/response logging
/// - Timeout configuration
class ApiClient {
  final Dio _dio;
  final SecureStorageService _storage;

  ApiClient({required String baseUrl, required SecureStorageService storage})
    : _storage = storage,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
          sendTimeout: Duration(seconds: ApiConstants.sendTimeout),
          headers: {
            'Content-Type': ApiConstants.contentTypeJson,
            'Accept': ApiConstants.acceptJson,
          },
        ),
      ) {
    _setupInterceptors();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SETUP INTERCEPTORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Setup request/response/error interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // ════════════════════════════════════════════════════════════════════
        // REQUEST INTERCEPTOR - Runs before each request
        // ════════════════════════════════════════════════════════════════════
        onRequest: (options, handler) async {
          // Get token from secure storage
          final token = await _storage.getIdToken();

          if (token != null && token.isNotEmpty) {
            // Attach token to Authorization header
            options.headers['Authorization'] =
                '${ApiConstants.bearerPrefix} $token';
          }

          // Log request (only in debug mode)
          log('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
          log('   JWT Token: $token');
          if (options.queryParameters.isNotEmpty) {
            log('   Query: ${options.queryParameters}');
          }
          if (options.data != null) {
            log('   Body: ${options.data}');
          }

          return handler.next(options);
        },

        // ════════════════════════════════════════════════════════════════════
        // RESPONSE INTERCEPTOR - Runs after successful response
        // ════════════════════════════════════════════════════════════════════
        onResponse: (response, handler) {
          // Log successful response
          log(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
          );

          return handler.next(response);
        },

        // ════════════════════════════════════════════════════════════════════
        // ERROR INTERCEPTOR - Runs when request fails
        // ════════════════════════════════════════════════════════════════════
        onError: (error, handler) async {
          log(
            '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          log('   Message: ${error.message}');

          // Skip 401 handling for the refresh token endpoint itself
          // to avoid infinite loops
          final isRefreshRequest = error.requestOptions.path == ApiConstants.refreshToken;

          // Handle 401 Unauthorized (token expired or invalid)
          if (error.response?.statusCode == 401 && !isRefreshRequest) {
            log('🔄 Token expired - attempting to refresh');

            // Try to refresh the token
            final refreshed = await tryRefreshToken();
            
            if (refreshed) {
              log('✅ Token refreshed successfully - retrying request');
              
              // Retry the original request with new token
              try {
                final newToken = await _storage.getIdToken();
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': '${ApiConstants.bearerPrefix} $newToken',
                  },
                );
                
                final response = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: opts,
                );
                
                return handler.resolve(response);
              } catch (retryError) {
                log('❌ Retry failed after token refresh');
                return handler.reject(error);
              }
            } else {
              log('❌ Token refresh failed - clearing local data');
              
              // Clear all local authentication data only if refresh fails
              await _storage.clearAll();

              // Return custom error message
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: 'Session expired. Please login again.',
                  type: DioExceptionType.badResponse,
                  response: error.response,
                ),
              );
            }
          }

          // Pass error to next handler
          return handler.next(error);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOKEN REFRESH
  // ══════════════════════════════════════════════════════════════════════════

  /// Try to refresh the access token using the refresh token
  /// 
  /// This method is public so it can be called during app startup
  /// to proactively refresh expired tokens.
  /// 
  /// Returns true if refresh was successful, false otherwise.
  Future<bool> tryRefreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken == null || refreshToken.isEmpty) {
        log('❌ No refresh token available');
        return false;
      }

      // Call the refresh token endpoint
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': ApiConstants.contentTypeJson,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newIdToken = response.data['idToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newIdToken != null) {
          // Update the stored tokens
          await _storage.updateIdToken(newIdToken);
          
          if (newRefreshToken != null) {
            // Some refresh endpoints return a new refresh token too
            await _storage.write(StorageKeys.refreshToken, newRefreshToken);
          }
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      log('❌ Token refresh error: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET request
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.get('/users', queryParameters: {'page': 1});
  /// ```
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.post('/login', data: {'email': 'test@example.com'});
  /// ```
  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.post(
      path,
      data: data,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.put('/users/123', data: {'name': 'John'});
  /// ```
  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return await _dio.put(path, data: data, options: options);
  }

  /// DELETE request
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.delete('/users/123');
  /// ```
  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return await _dio.delete(path, data: data, options: options);
  }

  /// PATCH request
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.patch('/users/123', data: {'age': 30});
  /// ```
  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return await _dio.patch(path, data: data, options: options);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILE UPLOAD
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload file with multipart/form-data
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.uploadFile(
  ///   '/upload',
  ///   filePath: '/path/to/file.pdf',
  ///   fileFieldName: 'file',
  ///   data: {'description': 'My file'},
  /// );
  /// ```
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fileFieldName: await MultipartFile.fromFile(filePath),
      if (data != null) ...data,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(
        headers: {'Content-Type': ApiConstants.contentTypeMultipart},
      ),
    );
  }

  /// Upload multiple files
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.uploadMultipleFiles(
  ///   '/upload-multiple',
  ///   filePaths: ['/path/to/file1.pdf', '/path/to/file2.jpg'],
  ///   fileFieldName: 'files',
  /// );
  /// ```
  Future<Response> uploadMultipleFiles(
    String path, {
    required List<String> filePaths,
    required String fileFieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );

    final formData = FormData.fromMap({
      fileFieldName: files,
      if (data != null) ...data,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(
        headers: {'Content-Type': ApiConstants.contentTypeMultipart},
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD
  // ══════════════════════════════════════════════════════════════════════════

  /// Download file with progress tracking
  ///
  /// Example:
  /// ```dart
  /// await apiClient.downloadFile(
  ///   '/download/file.pdf',
  ///   savePath: '/local/path/file.pdf',
  ///   onReceiveProgress: (received, total) {
  ///     print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  Future<Response> downloadFile(
    String path, {
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CANCEL REQUEST
  // ══════════════════════════════════════════════════════════════════════════

  /// Cancel all pending requests
  void cancelRequests() {
    _dio.close(force: true);
  }
}
