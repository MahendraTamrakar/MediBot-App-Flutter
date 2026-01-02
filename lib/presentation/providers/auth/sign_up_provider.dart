import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/auth/user_model.dart';

/// Sign up provider - Manages sign up form state
class SignUpProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignUpProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ══════════════════════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════════════════════

  bool _isLoading = false;
  String? _error;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  bool get hasError => _error != null;

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Clear previous errors
    _clearErrors();

    // Validate
    if (!_validateEmail(email)) return null;
    if (!_validatePassword(password)) return null;
    if (!_validateConfirmPassword(password, confirmPassword)) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.signUp(email, password);
      return user;
    } catch (e) {
      _error = _parseError(e.toString());
      return null;
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

    // Additional email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email format';
      notifyListeners();
      return false;
    }

    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _passwordError = 'Password must contain at least one uppercase letter';
      notifyListeners();
      return false;
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      _passwordError = 'Password must contain at least one number';
      notifyListeners();
      return false;
    }

    return true;
  }

  bool _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REAL-TIME VALIDATION (for live feedback)
  // ══════════════════════════════════════════════════════════════════════════

  /// Validate email in real-time (call on text change)
  void validateEmailRealTime(String email) {
    if (email.isEmpty) {
      _emailError = null; // Don't show error if empty
    } else if (!email.contains('@')) {
      _emailError = 'Invalid email format';
    } else {
      _emailError = null;
    }
    notifyListeners();
  }

  /// Validate password in real-time
  void validatePasswordRealTime(String password) {
    if (password.isEmpty) {
      _passwordError = null;
    } else if (password.length < 6) {
      _passwordError = 'Too short (min 6 characters)';
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      _passwordError = 'Need uppercase letter';
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      _passwordError = 'Need number';
    } else {
      _passwordError = null;
    }
    notifyListeners();
  }

  /// Validate confirm password in real-time
  void validateConfirmPasswordRealTime(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = null;
    } else if (password != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _confirmPasswordError = null;
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PASSWORD STRENGTH
  // ══════════════════════════════════════════════════════════════════════════

  /// Get password strength (0-4)
  int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;

    // Uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // Number
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // Special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  /// Get password strength text
  String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  String _parseError(String error) {
    // Parse common error messages from backend
    if (error.contains('EMAIL_EXISTS') || 
        error.contains('already exists')) {
      return 'An account with this email already exists';
    }
    
    if (error.contains('WEAK_PASSWORD')) {
      return 'Password is too weak. Please use a stronger password';
    }
    
    if (error.contains('INVALID_EMAIL')) {
      return 'Invalid email format';
    }
    
    if (error.contains('No internet connection')) {
      return 'No internet connection. Please check your network';
    }

    // Return generic error
    return 'Sign up failed. Please try again';
  }

  void _clearErrors() {
    _error = null;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
  }

  /// Clear all errors
  void clearError() {
    _clearErrors();
    notifyListeners();
  }

  /// Clear specific field errors
  void clearEmailError() {
    _emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    _passwordError = null;
    notifyListeners();
  }

  void clearConfirmPasswordError() {
    _confirmPasswordError = null;
    notifyListeners();
  }
}