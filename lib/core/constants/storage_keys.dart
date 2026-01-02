/// Storage Keys - All storage key constants in one place
/// 
/// This prevents typos and makes keys reusable across the app.
/// 
/// Usage:
/// ```dart
/// await storage.write(key: StorageKeys.idToken, value: token);
/// final token = await storage.read(key: StorageKeys.idToken);
/// ```
class StorageKeys {
  // Prevent instantiation
  StorageKeys._();

  // ══════════════════════════════════════════════════════════════════════════
  // SECURE STORAGE KEYS (flutter_secure_storage)
  // ══════════════════════════════════════════════════════════════════════════
  // Used for sensitive data like tokens and passwords

  /// Firebase ID token (JWT)
  static const String idToken = 'firebase_id_token';

  /// Firebase refresh token
  static const String refreshToken = 'firebase_refresh_token';

  /// User UID from Firebase
  static const String uid = 'firebase_uid';

  /// User email address
  static const String userEmail = 'user_email';

  /// User display name
  static const String displayName = 'user_display_name';

  /// User photo URL
  static const String photoUrl = 'user_photo_url';

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED PREFERENCES KEYS (shared_preferences)
  // ══════════════════════════════════════════════════════════════════════════
  // Used for non-sensitive settings and preferences

  // ──────────────────────────────────────────────────────────────────────────
  // ONBOARDING
  // ──────────────────────────────────────────────────────────────────────────

  /// Onboarding completion flag
  /// Type: bool
  /// Default: false
  static const String onboardingComplete = 'onboarding_complete';

  // ──────────────────────────────────────────────────────────────────────────
  // THEME & APPEARANCE
  // ──────────────────────────────────────────────────────────────────────────

  /// Theme mode: 'light', 'dark', or 'system'
  /// Type: String
  /// Default: 'system'
  static const String themeMode = 'theme_mode';

  /// Language code (e.g., 'en', 'es', 'hi')
  /// Type: String
  /// Default: null (system language)
  static const String languageCode = 'language_code';

  // ──────────────────────────────────────────────────────────────────────────
  // APP LIFECYCLE
  // ──────────────────────────────────────────────────────────────────────────

  /// First launch date (ISO 8601 string)
  /// Type: String (DateTime)
  /// Default: null (set on first launch)
  static const String firstLaunchDate = 'first_launch_date';

  /// Last app version (e.g., '1.0.0')
  /// Type: String
  /// Default: null
  static const String lastAppVersion = 'last_app_version';

  // ──────────────────────────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ──────────────────────────────────────────────────────────────────────────

  /// Notifications enabled flag
  /// Type: bool
  /// Default: true
  static const String notificationsEnabled = 'notifications_enabled';

  /// Sound enabled flag
  /// Type: bool
  /// Default: true
  static const String soundEnabled = 'sound_enabled';

  /// Vibration enabled flag
  /// Type: bool
  /// Default: true
  static const String vibrationEnabled = 'vibration_enabled';

  // ──────────────────────────────────────────────────────────────────────────
  // ANALYTICS & PRIVACY
  // ──────────────────────────────────────────────────────────────────────────

  /// Analytics enabled flag
  /// Type: bool
  /// Default: true
  static const String analyticsEnabled = 'analytics_enabled';

  /// Crashlytics enabled flag
  /// Type: bool
  /// Default: true
  static const String crashlyticsEnabled = 'crashlytics_enabled';

  /// Data collection consent flag
  /// Type: bool
  /// Default: false
  static const String dataCollectionConsent = 'data_collection_consent';

  // ──────────────────────────────────────────────────────────────────────────
  // CACHE MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────

  /// Last sync timestamp (ISO 8601 string)
  /// Type: String (DateTime)
  /// Default: null
  static const String lastSyncTime = 'last_sync_time';

  /// Cached user profile (JSON string)
  /// Type: String (JSON)
  /// Default: null
  static const String cachedUserProfile = 'cached_user_profile';

  /// Cached chat history (JSON string)
  /// Type: String (JSON)
  /// Default: null
  static const String cachedChatHistory = 'cached_chat_history';

  // ──────────────────────────────────────────────────────────────────────────
  // USER PREFERENCES
  // ──────────────────────────────────────────────────────────────────────────

  /// Auto-send messages enabled
  /// Type: bool
  /// Default: false
  static const String autoSendEnabled = 'auto_send_enabled';

  /// Show typing indicator
  /// Type: bool
  /// Default: true
  static const String showTypingIndicator = 'show_typing_indicator';

  /// Chat bubble style: 'rounded' or 'square'
  /// Type: String
  /// Default: 'rounded'
  static const String chatBubbleStyle = 'chat_bubble_style';

  /// Font size scale: 0.8 to 1.5
  /// Type: double
  /// Default: 1.0
  static const String fontSizeScale = 'font_size_scale';

  // ──────────────────────────────────────────────────────────────────────────
  // TUTORIAL & HINTS
  // ──────────────────────────────────────────────────────────────────────────

  /// Chat tutorial shown flag
  /// Type: bool
  /// Default: false
  static const String chatTutorialShown = 'chat_tutorial_shown';

  /// Report upload tutorial shown flag
  /// Type: bool
  /// Default: false
  static const String reportTutorialShown = 'report_tutorial_shown';

  /// Profile tutorial shown flag
  /// Type: bool
  /// Default: false
  static const String profileTutorialShown = 'profile_tutorial_shown';

  // ══════════════════════════════════════════════════════════════════════════
  // HIVE BOX NAMES (if using Hive for local database)
  // ══════════════════════════════════════════════════════════════════════════

  /// Chat messages box
  static const String chatMessagesBox = 'chat_messages';

  /// Chat sessions box
  static const String chatSessionsBox = 'chat_sessions';

  /// User profile box
  static const String userProfileBox = 'user_profile';

  /// Medical reports box
  static const String medicalReportsBox = 'medical_reports';

  /// Settings box
  static const String settingsBox = 'settings';

  /// Drafts box (for unsent messages)
  static const String draftsBox = 'drafts';

  // ══════════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS
  // ══════════════════════════════════════════════════════════════════════════

  /// Streaming chat enabled
  /// Type: bool
  /// Default: true
  static const String streamingChatEnabled = 'streaming_chat_enabled';

  /// Voice input enabled
  /// Type: bool
  /// Default: true
  static const String voiceInputEnabled = 'voice_input_enabled';

  /// Image upload enabled
  /// Type: bool
  /// Default: true
  static const String imageUploadEnabled = 'image_upload_enabled';

  /// PDF upload enabled
  /// Type: bool
  /// Default: true
  static const String pdfUploadEnabled = 'pdf_upload_enabled';

  // ══════════════════════════════════════════════════════════════════════════
  // TEMPORARY DATA (cleared on logout)
  // ══════════════════════════════════════════════════════════════════════════

  /// Current chat session ID
  /// Type: String
  /// Default: null
  static const String currentSessionId = 'current_session_id';

  /// Draft message text
  /// Type: String
  /// Default: null
  static const String draftMessage = 'draft_message';

  /// Last selected report file path
  /// Type: String
  /// Default: null
  static const String lastSelectedFilePath = 'last_selected_file_path';

  // ══════════════════════════════════════════════════════════════════════════
  // RATE LIMITING
  // ══════════════════════════════════════════════════════════════════════════

  /// Last message sent timestamp (ISO 8601)
  /// Type: String (DateTime)
  /// Default: null
  static const String lastMessageSentTime = 'last_message_sent_time';

  /// Message count in current hour
  /// Type: int
  /// Default: 0
  static const String messageCountThisHour = 'message_count_this_hour';

  /// Last report upload timestamp (ISO 8601)
  /// Type: String (DateTime)
  /// Default: null
  static const String lastReportUploadTime = 'last_report_upload_time';

  // ══════════════════════════════════════════════════════════════════════════
  // BIOMETRIC AUTHENTICATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Biometric authentication enabled
  /// Type: bool
  /// Default: false
  static const String biometricEnabled = 'biometric_enabled';

  /// Biometric type: 'fingerprint', 'face', or 'iris'
  /// Type: String
  /// Default: null
  static const String biometricType = 'biometric_type';

  // ══════════════════════════════════════════════════════════════════════════
  // DEBUG & TESTING
  // ══════════════════════════════════════════════════════════════════════════

  /// Debug mode enabled
  /// Type: bool
  /// Default: false
  static const String debugModeEnabled = 'debug_mode_enabled';

  /// Mock API enabled (for testing)
  /// Type: bool
  /// Default: false
  static const String mockApiEnabled = 'mock_api_enabled';

  /// Last error log (JSON string)
  /// Type: String (JSON)
  /// Default: null
  static const String lastErrorLog = 'last_error_log';

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get all secure storage keys
  static List<String> getSecureStorageKeys() {
    return [
      idToken,
      refreshToken,
      uid,
      userEmail,
      displayName,
      photoUrl,
    ];
  }

  /// Get all shared preferences keys
  static List<String> getSharedPreferencesKeys() {
    return [
      onboardingComplete,
      themeMode,
      languageCode,
      firstLaunchDate,
      lastAppVersion,
      notificationsEnabled,
      soundEnabled,
      vibrationEnabled,
      analyticsEnabled,
      crashlyticsEnabled,
      dataCollectionConsent,
      lastSyncTime,
      cachedUserProfile,
      cachedChatHistory,
      autoSendEnabled,
      showTypingIndicator,
      chatBubbleStyle,
      fontSizeScale,
      chatTutorialShown,
      reportTutorialShown,
      profileTutorialShown,
      streamingChatEnabled,
      voiceInputEnabled,
      imageUploadEnabled,
      pdfUploadEnabled,
      currentSessionId,
      draftMessage,
      lastSelectedFilePath,
      lastMessageSentTime,
      messageCountThisHour,
      lastReportUploadTime,
      biometricEnabled,
      biometricType,
      debugModeEnabled,
      mockApiEnabled,
      lastErrorLog,
    ];
  }

  /// Get all Hive box names
  static List<String> getHiveBoxNames() {
    return [
      chatMessagesBox,
      chatSessionsBox,
      userProfileBox,
      medicalReportsBox,
      settingsBox,
      draftsBox,
    ];
  }

  /// Get all keys that should be cleared on logout
  static List<String> getLogoutClearKeys() {
    return [
      currentSessionId,
      draftMessage,
      lastSelectedFilePath,
      cachedUserProfile,
      cachedChatHistory,
    ];
  }
}