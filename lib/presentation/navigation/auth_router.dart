import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:medibot/presentation/navigation/route_guard.dart';
import 'package:medibot/presentation/screens/auth/forgot_password/forgot_screen.dart';
import 'package:medibot/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:medibot/presentation/screens/auth/sign_up/sign_up_screen.dart';
import 'package:medibot/presentation/screens/main/chat/chat_screen.dart';
import 'package:medibot/presentation/screens/main/drawer/widgets/drawer_animation.dart';
import 'package:medibot/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:medibot/presentation/screens/settings/data_control_screen.dart';
import 'package:medibot/presentation/screens/settings/edit_profile_screen.dart';
import 'package:medibot/presentation/screens/settings/setting_screen.dart';

class AppRouter {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    log('🧭 Navigating to: ${settings.name}');

    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      
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

      //main app routes

      case AppRoutes.chat:
        return MaterialPageRoute(
          builder:
              (_) => AuthGuard(
                child: AnimatedDrawerScaffold(
                  builder:
                      (context, toggle) => ChatScreen(onMenuPressed: toggle),
                ),
              ),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: SettingsScreen()),
          settings: settings,
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: EditProfileScreen()),
          settings: settings,
        );

      
      case AppRoutes.dataControl:
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: DataControlScreen(),
          ),
          settings: settings,
        );

      default:
        return _errorRoute(settings, 'Route not found: ${settings.name}');
    }
  }


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
                          AppRoutes.chat,
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


class AppRoutes {
  static const String onboarding = '/onboarding';

  // Authentication
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main App
  static const String chat = '/chat';
  static const String chatHistory = '/chat-history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String dataControl = '/data-control';


  /// Check if route requires authentication
  static bool isProtectedRoute(String route) {
    return ![onboarding, signIn, signUp, forgotPassword].contains(route);
  }

  /// Check if route is authentication route
  static bool isAuthRoute(String route) {
    return [signIn, signUp, forgotPassword].contains(route);
  }
}
