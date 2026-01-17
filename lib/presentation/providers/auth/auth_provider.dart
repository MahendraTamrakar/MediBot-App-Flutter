import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:medibot/data/models/auth/user_model.dart';
import 'package:medibot/data/repositories/auth_repository.dart';

/// Authentication provider
///
/// Manages global authentication state for the entire app.
///
/// Features:
/// - Current user state
/// - Authentication status
/// - Sign in/out methods
/// - Loading states
/// - Error handling
/// - Persistent login check
///
/// Usage:
/// ```dart
/// // Get current user
/// final user = context.watch<AuthProvider>().currentUser;
///
/// // Check if logged in
/// final isLoggedIn = context.watch<AuthProvider>().isAuthenticated;
///
/// // Sign in
/// await context.read<AuthProvider>().signIn(email, password);
///
/// // Sign out
/// await context.read<AuthProvider>().signOut();
/// ```
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository;

  // ══════════════════════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════════════════════

  /// Current authenticated user (null if not logged in)
  UserModel? _currentUser;

  /// Loading state for auth operations
  bool _isLoading = false;

  /// Error message from last operation
  String? _errorMessage;

  /// Whether app is checking initial auth state
  bool _isInitializing = true;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Check if user is NOT authenticated
  bool get isUnauthenticated => _currentUser == null;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Check if still checking initial auth state
  bool get isInitializing => _isInitializing;

  /// Get user email (or empty string if not logged in)
  String get userEmail => _currentUser?.email ?? '';

  /// Get user display name (or empty string if not logged in)
  String get userName => _currentUser?.displayName ?? '';

  /// Get user UID (or empty string if not logged in)
  String get userUid => _currentUser?.uid ?? '';

  // ══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if user is already logged in (call on app start)
  ///
  /// Call this in main.dart or splash screen to check if user has
  /// a valid token from previous session.
  ///
  /// Returns true if user is logged in, false otherwise.
  Future<bool> checkAuthStatus() async {
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if user has valid token
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        // Get user data from storage
        final user = await _authRepository.getCurrentUser();
        _currentUser = user;
        log('✅ User already logged in: ${user?.email}');
      } else {
        _currentUser = null;
        log('ℹ️ No active session found');
      }

      return isLoggedIn;
    } catch (e) {
      log('❌ Error checking auth status: $e');
      _currentUser = null;
      return false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }


  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('🗑️ Deleting account...');

      // Call repository to delete account
      final success = await _authRepository.deleteAccount();

      if (success) {
        // Clear local user data
        _currentUser = null;
        
        log('✅ Account deleted successfully');
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      log('❌ Failed to delete account: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign in with email and password
  ///
  /// Returns UserModel on success, throws exception on error
  Future<UserModel> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signIn(email, password);
      _currentUser = user;
      _isInitializing = false; // Ensure initialization is complete
      log('✅ Sign in successful: ${user.email}');

      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      log('❌ Sign in error: $e');
      _errorMessage = e.toString();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign up with email and password
  ///
  /// Returns UserModel on success, throws exception on error
  Future<UserModel> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signUp(email, password);
      _currentUser = user;
      _isInitializing = false; // Ensure initialization is complete
      log('✅ Sign up successful: ${user.email}');

      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      log('❌ Sign up error: $e');
      _errorMessage = e.toString();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  //forgot password
  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      log('✅ Password reset email sent to: $email');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Password reset error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }


  /// Sign in with Google
  /// Returns UserModel on success, null if cancelled, throws on error
  Future<UserModel?> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _isInitializing = false; // Ensure initialization is complete
      log('✅ Google sign in successful: ${user.email}');

      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      log('❌ Google sign in error: $e');

      // Check if user cancelled
      if (e.toString().contains('cancelled')) {
        _errorMessage = null; // Don't show error for cancellation
        _isLoading = false;
        notifyListeners();
        return null;
      }

      _errorMessage = e.toString();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _errorMessage = null;
      log('✅ Sign out successful');
    } catch (e) {
      log('❌ Sign out error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE USER
  // ══════════════════════════════════════════════════════════════════════════

  /// Set user manually (useful after successful auth from other providers)
  void setUser(UserModel user) {
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user data (e.g., after profile update)
  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Clear user manually (use signOut instead in most cases)
  void clearUser() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set error message manually
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REFRESH
  // ══════════════════════════════════════════════════════════════════════════

  /// Refresh user data from storage
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      log('❌ Error refreshing user: $e');
    }
  }
}
