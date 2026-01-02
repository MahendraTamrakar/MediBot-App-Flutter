import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/auth/user_model.dart';

/// Sign in provider - Manages sign in form state
class SignInProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignInProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  String? _emailError;
  String? _passwordError;


  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get error => _error;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get hasError => _error != null;


  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    // Clear previous errors
    _clearErrors();

    // Validate
    if (!_validateEmail(email)) return null;
    if (!_validatePassword(password)) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.signIn(email, password);
      return user;
    } catch (e) {
      _error = _parseError(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    _clearErrors();
    _isGoogleLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      return user;
    } catch (e) {
      _error = _parseError(e.toString());
      return null;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }


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

    return true;
  }

  String _parseError(String error) {
    // Parse common error messages from backend
    if (error.contains('Invalid credentials') || 
        error.contains('INVALID_PASSWORD') ||
        error.contains('EMAIL_NOT_FOUND')) {
      return 'Invalid email or password';
    }
    
    if (error.contains('USER_DISABLED')) {
      return 'This account has been disabled';
    }
    
    if (error.contains('TOO_MANY_ATTEMPTS')) {
      return 'Too many failed attempts. Please try again later';
    }
    
    if (error.contains('No internet connection')) {
      return 'No internet connection. Please check your network';
    }

    // Return generic error
    return 'Sign in failed. Please try again';
  }

  void _clearErrors() {
    _error = null;
    _emailError = null;
    _passwordError = null;
  }

  /// Clear all errors
  void clearError() {
    _clearErrors();
    notifyListeners();
  }

  /// Clear specific field error
  void clearEmailError() {
    _emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    _passwordError = null;
    notifyListeners();
  }
}