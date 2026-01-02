import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';

/// Forgot password provider - Manages password reset
class ForgotPasswordProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ══════════════════════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════════════════════

  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;
  String? _emailError;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  bool get isLoading => _isLoading;
  bool get emailSent => _emailSent;
  String? get error => _error;
  String? get emailError => _emailError;
  bool get hasError => _error != null;

  // ══════════════════════════════════════════════════════════════════════════
  // SEND RESET EMAIL
  // ══════════════════════════════════════════════════════════════════════════

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    // Clear previous errors
    _clearErrors();
    _emailSent = false;

    // Validate
    if (!_validateEmail(email)) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _emailSent = true;
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _emailError = 'Email is required';
      notifyListeners();
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _emailError = 'Please enter a valid email';
      notifyListeners();
      return false;
    }

    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  String _parseError(String error) {
    if (error.contains('EMAIL_NOT_FOUND') || 
        error.contains('not found')) {
      return 'No account found with this email';
    }
    
    if (error.contains('INVALID_EMAIL')) {
      return 'Invalid email format';
    }
    
    if (error.contains('No internet connection')) {
      return 'No internet connection. Please check your network';
    }

    return 'Failed to send reset email. Please try again';
  }

  void _clearErrors() {
    _error = null;
    _emailError = null;
  }

  /// Clear all errors
  void clearError() {
    _clearErrors();
    notifyListeners();
  }

  /// Reset state (for navigating back)
  void reset() {
    _emailSent = false;
    _clearErrors();
    notifyListeners();
  }
}