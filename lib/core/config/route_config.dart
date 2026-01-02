/// Route configuration - All route names in one place
/// 
/// This prevents typos in navigation and makes routes reusable
/// 
/// Usage:
/// ```dart
/// Navigator.pushNamed(context, RouteConfig.signIn);
/// Navigator.pushReplacementNamed(context, RouteConfig.home);
/// ```
class RouteConfig {
  // Prevent instantiation
  RouteConfig._();

  // ══════════════════════════════════════════════════════════════════════════
  // ONBOARDING & AUTH
  // ══════════════════════════════════════════════════════════════════════════

  /// Onboarding screen
  static const String onboarding = '/onboarding';

  /// Sign in screen
  static const String signIn = '/signin';

  /// Sign up screen
  static const String signUp = '/signup';

  /// Forgot password screen
  static const String forgotPassword = '/forgot-password';

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN APP
  // ══════════════════════════════════════════════════════════════════════════

  /// Home screen (chat screen)
  static const String home = '/home';

  /// Chat screen (alias for home)
  static const String chat = '/chat';

  /// Specific chat session
  /// Use: RouteConfig.chatSession('/12345')
  static String chatSession(String sessionId) => '/chat/$sessionId';

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Settings screen
  static const String settings = '/settings';

  /// Edit profile screen
  static const String editProfile = '/edit-profile';

  /// Medical profile screen
  static const String medicalProfile = '/medical-profile';

  // ══════════════════════════════════════════════════════════════════════════
  // REPORTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload report screen
  static const String uploadReport = '/upload-report';

  /// Report analysis screen
  /// Use: RouteConfig.reportAnalysis('report123')
  static String reportAnalysis(String reportId) => '/report-analysis/$reportId';

  /// Report history screen
  static const String reportHistory = '/report-history';

  // ══════════════════════════════════════════════════════════════════════════
  // OTHER
  // ══════════════════════════════════════════════════════════════════════════

  /// About screen
  static const String about = '/about';

  /// Privacy policy screen
  static const String privacyPolicy = '/privacy-policy';

  /// Terms of service screen
  static const String termsOfService = '/terms-of-service';

  /// Help & FAQ screen
  static const String help = '/help';

  // ══════════════════════════════════════════════════════════════════════════
  // INITIAL ROUTE
  // ══════════════════════════════════════════════════════════════════════════

  /// Initial route (determined by onboarding status)
  static String get initialRoute => onboarding;

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get all route names
  static List<String> getAllRoutes() {
    return [
      onboarding,
      signIn,
      signUp,
      forgotPassword,
      home,
      chat,
      settings,
      editProfile,
      medicalProfile,
      uploadReport,
      reportHistory,
      about,
      privacyPolicy,
      termsOfService,
      help,
    ];
  }

  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    final publicRoutes = [
      onboarding,
      signIn,
      signUp,
      forgotPassword,
    ];

    return !publicRoutes.contains(route);
  }

  /// Get route display name
  static String getDisplayName(String route) {
    switch (route) {
      case onboarding:
        return 'Onboarding';
      case signIn:
        return 'Sign In';
      case signUp:
        return 'Sign Up';
      case forgotPassword:
        return 'Forgot Password';
      case home:
      case chat:
        return 'Chat';
      case settings:
        return 'Settings';
      case editProfile:
        return 'Edit Profile';
      case medicalProfile:
        return 'Medical Profile';
      case uploadReport:
        return 'Upload Report';
      case reportHistory:
        return 'Report History';
      case about:
        return 'About';
      case privacyPolicy:
        return 'Privacy Policy';
      case termsOfService:
        return 'Terms of Service';
      case help:
        return 'Help';
      default:
        return 'Unknown';
    }
  }
}