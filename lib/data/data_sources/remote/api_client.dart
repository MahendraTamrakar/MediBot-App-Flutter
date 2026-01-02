import 'dart:developer' show log;

import 'package:dio/dio.dart';
import '../local/secure_storage_service.dart';
import '../../../core/constants/api_constants.dart';

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
          log('📤 REQUEST: ${options.method} ${options.path}');
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

          // Handle 401 Unauthorized (token expired or invalid)
          if (error.response?.statusCode == 401) {
            log('🔄 Token expired or invalid - clearing local data');

            // Clear all local authentication data
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

          // Pass error to next handler
          return handler.next(error);
        },
      ),
    );
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
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
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
