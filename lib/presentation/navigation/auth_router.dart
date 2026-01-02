import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:medibot/presentation/navigation/route_guard.dart';
import 'package:medibot/presentation/screens/auth/forgot_password/forgot_screen.dart';
import 'package:medibot/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:medibot/presentation/screens/auth/sign_up/sign_up_screen.dart';
import 'package:medibot/presentation/screens/onboarding/onboarding_screen.dart';

/// App Router - Centralized route management
///
/// Defines all app routes with proper navigation guards.
///
/// Usage:
/// ```dart
/// // In MaterialApp
/// onGenerateRoute: AppRouter.generateRoute,
///
/// // Navigate to route
/// Navigator.pushNamed(context, AppRoutes.home);
///
/// // Navigate with arguments
/// Navigator.pushNamed(
///   context,
///   AppRoutes.chatDetail,
///   arguments: sessionId,
/// );
/// ```
class AppRouter {
  // ══════════════════════════════════════════════════════════════════════════
  // ROUTE GENERATION
  // ══════════════════════════════════════════════════════════════════════════

  static Route<dynamic> generateRoute(RouteSettings settings) {
    log('🧭 Navigating to: ${settings.name}');

    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      // ══════════════════════════════════════════════════════════════════════
      // AUTHENTICATION (Public Routes)
      // ══════════════════════════════════════════════════════════════════════

      case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: settings,
        );

      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotScreen(),
          settings: settings,
        );

      /* //main app routes
      
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: HomeScreen()),
          settings: settings,
        );

      case AppRoutes.chat:
        // Get session ID from arguments (optional)
        final sessionId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: ChatScreen(sessionId: sessionId),
          ),
          settings: settings,
        );

      case AppRoutes.chatHistory:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: ChatHistoryScreen()),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: ProfileScreen()),
          settings: settings,
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: EditProfileScreen()),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: SettingsScreen()),
          settings: settings,
        );

      case AppRoutes.reports:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: ReportsScreen()),
          settings: settings,
        );

      case AppRoutes.reportDetail:
        // Get report ID from arguments
        final reportId = settings.arguments as String?;
        if (reportId == null) {
          return _errorRoute(settings, 'Report ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: ReportDetailScreen(reportId: reportId),
          ),
          settings: settings,
        ); */

      // ══════════════════════════════════════════════════════════════════════
      // ERROR - ROUTE NOT FOUND
      // ══════════════════════════════════════════════════════════════════════

      default:
        return _errorRoute(settings, 'Route not found: ${settings.name}');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR ROUTE
  // ══════════════════════════════════════════════════════════════════════════

  static Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        ),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
      settings: settings,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP ROUTES - String Constants
// ═══════════════════════════════════════════════════════════════════════════════

/// Route names as string constants
///
/// Benefits:
/// - Type safety (no typos)
/// - Easy refactoring
/// - Auto-complete support
/// - Single source of truth
class AppRoutes {
  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main App
  static const String home = '/home';
  static const String chat = '/chat';
  static const String chatHistory = '/chat-history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String reportDetail = '/report-detail';

  /// Check if route requires authentication
  static bool isProtectedRoute(String route) {
    return ![
      splash,
      onboarding,
      signIn,
      signUp,
      forgotPassword,
    ].contains(route);
  }

  /// Check if route is authentication route
  static bool isAuthRoute(String route) {
    return [signIn, signUp, forgotPassword].contains(route);
  }
}
