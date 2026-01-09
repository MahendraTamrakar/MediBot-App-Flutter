import 'package:flutter/material.dart';

/// Navigation service for navigating without BuildContext
/// 
/// Useful for:
/// - Navigating from providers
/// - Navigating from repositories
/// - Navigating from services
/// - Deep linking
/// 
/// Usage:
/// ```dart
/// // 1. Setup in MaterialApp
/// MaterialApp(
///   navigatorKey: NavigationService.navigatorKey,
///   onGenerateRoute: AppRouter.generateRoute,
/// )
/// 
/// // 2. Navigate from anywhere (no context needed)
/// NavigationService.navigateTo('/home');
/// NavigationService.navigateToReplacement('/signin');
/// NavigationService.goBack();
/// ```
class NavigationService {
  // Global navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get current context
  static BuildContext? get context => navigatorKey.currentContext;

  /// Get navigator state
  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to route (push)
  static Future<T?> navigateTo<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  static Future navigateToReplacement<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushReplacementNamed<dynamic, T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateToAndClearStack<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate and remove routes until predicate
  static Future<T?> navigateToAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Go back (pop)
  static void goBack<T>([T? result]) {
    if (canGoBack()) {
      navigator!.pop<T>(result);
    }
  }

  /// Check if can go back
  static bool canGoBack() {
    return navigator!.canPop();
  }

  /// Pop until route
  static void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }

  /// Pop until predicate
  static void popUntilPredicate(bool Function(Route<dynamic>) predicate) {
    navigator!.popUntil(predicate);
  }



  /// Show dialog
  static Future<T?> showDialogBox<T>(Widget dialog) {
    return showDialog<T>(
      context: context!,
      builder: (_) => dialog,
    );
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheetModal<T>(Widget bottomSheet) {
    return showModalBottomSheet<T>(
      context: context!,
      builder: (_) => bottomSheet,
    );
  }

  /// Show snackbar
  static void showSnackbar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(String message) {
    showSnackbar(message, backgroundColor: Colors.green);
  }

  /// Show error snackbar
  static void showErrorSnackbar(String message) {
    showSnackbar(message, backgroundColor: Colors.red);
  }

  /// Show info snackbar
  static void showInfoSnackbar(String message) {
    showSnackbar(message, backgroundColor: Colors.blue);
  }
}