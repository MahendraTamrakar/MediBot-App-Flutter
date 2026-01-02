import 'package:dio/dio.dart';
import 'package:medibot/core/errors/app_exceptions.dart';

class ErrorHandler {
  static String handleError(Object error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppException) {
      return error.message;
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet.";
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final serverMessage = error.response?.data['message'] ?? "Unknown Server Error";
        
        switch (statusCode) {
          case 400:
            return "Bad Request: $serverMessage";
          case 401:
            return "Unauthorized: Please login again.";
          case 403:
            return "Access Denied.";
          case 404:
            return "Resource not found.";
          case 500:
            return "Internal Server Error. Try again later.";
          default:
            return "Server Error ($statusCode): $serverMessage";
        }

      case DioExceptionType.cancel:
        return "Request cancelled.";
        
      case DioExceptionType.connectionError:
        return "No Internet Connection.";
        
      default:
        return "Network Error. Please try again.";
    }
  }
}