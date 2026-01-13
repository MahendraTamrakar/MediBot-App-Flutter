import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Constants - All API-related configuration in one place
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  /// Backend API URL from environment variables
  static String get backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';


  // ════════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Sign up with email/password
  static const String signUpEmail = '/auth/signup/email';

  /// Login with email/password
  static const String loginEmail = '/auth/login/email';

  /// Login with Google
  static const String loginGoogle = '/auth/login/google';

  /// Forgot password
  static const String forgotPassword = '/auth/forgot-password';

  /// Refresh token
  static const String refreshToken = '/auth/refresh-token';

  // ════════════════════════════════════════════════════════════════════════════
  // CHAT ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Analyze symptoms (non-streaming)
  static const String analyzeSymptoms = '/analyze-symptoms';

  /// Get all chat sessions
  static const String listChats = '/chats';

  /// Get messages for a specific session
  static String getChatMessages(String sessionId) =>
      '/chats/$sessionId/messages';

  /// Delete a specific chat session
  static String deleteChatSession(String sessionId) => '/chats/$sessionId';

  /// Delete all chat sessions
  static const String deleteAllChats = '/chats';

  /// End chat (trigger profile update)
  static const String endChat = '/end-chat';

  // ════════════════════════════════════════════════════════════════════════════
  // CHAT DOCUMENT ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Upload document to chat
  static const String uploadDocument = '/chat/upload-document';

  // ════════════════════════════════════════════════════════════════════════════
  // REPORT ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Analyze medical report
  static const String analyzeReport = '/analyze-report';

  /// Get report history
  static const String reportHistory = '/reports/history';

  /// Get specific report by ID
  static String getReportById(String reportId) => '/reports/$reportId';

  // ════════════════════════════════════════════════════════════════════════════
  // USER PROFILE ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Save/update user profile
  static const String saveProfile = '/user/profile';

  /// Get user profile
  static const String getProfile = '/user/profile';

  /// Upload profile photo
  static const String uploadProfilePhoto = '/user/profile/photo';

  /// Delete profile photo
  static const String deleteProfilePhoto = '/user/profile/photo';

  /// Get medical profile
  static const String getMedicalProfile = '/user/medical-profile';

  // ════════════════════════════════════════════════════════════════════════════
  // DOCTOR SUMMARY ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Export doctor summary as PDF
  static const String doctorSummaryPdf = '/doctor-summary-pdf';

  // ════════════════════════════════════════════════════════════════════════════
  // ACCOUNT ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Delete user account
  static const String deleteAccount = '/account';

  // ════════════════════════════════════════════════════════════════════════════
  // HEALTH CHECK
  // ════════════════════════════════════════════════════════════════════════════

  /// Health check endpoint
  static const String health = '/health';

  // ════════════════════════════════════════════════════════════════════════════
  // HTTP HEADERS
  // ════════════════════════════════════════════════════════════════════════════

  /// Content-Type: application/json
  static const String contentTypeJson = 'application/json';

  /// Content-Type: multipart/form-data
  static const String contentTypeMultipart = 'multipart/form-data';

  /// Accept: application/json
  static const String acceptJson = 'application/json';

  /// Authorization header key
  static const String authorizationHeader = 'Authorization';

  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer';

  // ════════════════════════════════════════════════════════════════════════════
  // TIMEOUTS (in seconds)
  // ════════════════════════════════════════════════════════════════════════════

  /// Connection timeout
  static const int connectTimeout = 30;

  /// Receive timeout
  static const int receiveTimeout = 60;

  /// Send timeout
  static const int sendTimeout = 30;

  /// Streaming timeout (for SSE)
  static const int streamTimeout = 300; // 5 minutes

  // ════════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Default page size for paginated requests
  static const int defaultPageSize = 20;

  /// Maximum page size
  static const int maxPageSize = 100;

  // ════════════════════════════════════════════════════════════════════════════
  // FILE UPLOAD
  // ════════════════════════════════════════════════════════════════════════════

  /// Maximum file size for uploads (in bytes) - 10MB
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Allowed image formats
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  /// Allowed document formats
  static const List<String> allowedDocumentFormats = ['pdf'];

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$backendUrl$endpoint';
  }

  /// Get authorization header value
  static String getAuthHeader(String token) {
    return '$bearerPrefix $token';
  }
}
