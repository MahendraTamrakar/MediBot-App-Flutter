import 'package:medibot/data/models/auth/signup_resquest.dart';
import '../data_sources/remote/auth_api_service.dart';
import '../data_sources/local/secure_storage_service.dart';
import '../models/auth/login_request.dart';
import '../models/auth/user_model.dart';
import '../../services/google_sign_in_service.dart';

/// Authentication repository - Business logic layer
/// 
/// Handles all authentication operations including:
/// - Email/password sign up and sign in
/// - Google Sign-In
/// - Password reset
/// - Token management
/// - Session persistence
class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _storage;
  final GoogleSignInService _googleSignIn;

  AuthRepository({
    required AuthApiService apiService,
    required SecureStorageService storage,
    required GoogleSignInService googleSignIn,
  })  : _apiService = apiService,
        _storage = storage,
        _googleSignIn = googleSignIn;

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign up with email and password
  /// 
  /// Steps:
  /// 1. Call backend API to create account
  /// 2. Save tokens to secure storage
  /// 3. Return user model
  Future<UserModel> signUp(String email, String password) async {
    try {
      // 1. Call backend API
      final request = SignupRequest(email: email, password: password);
      final response = await _apiService.signUp(request);

      // 2. Save tokens to secure storage
      await _storage.saveTokens(
        idToken: response.idToken,
        refreshToken: response.refreshToken,
        uid: response.uid,
      );
      await _storage.saveEmail(email);

      // 3. Return user model
      return UserModel(
        uid: response.uid,
        email: email,
        emailVerified: response.emailVerified,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign in with email and password
  /// 
  /// Steps:
  /// 1. Call backend API to authenticate
  /// 2. Save tokens to secure storage
  /// 3. Return user model
  Future<UserModel> signIn(String email, String password) async {
    try {
      // 1. Call backend API
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.signIn(request);

      // 2. Save tokens to secure storage
      await _storage.saveTokens(
        idToken: response.idToken,
        refreshToken: response.refreshToken,
        uid: response.uid,
      );
      await _storage.saveEmail(email);

      // 3. Return user model
      return UserModel(
        uid: response.uid,
        email: email,
        emailVerified: response.emailVerified,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN IN
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign in with Google
  /// 
  /// Steps:
  /// 1. Get Google ID token from Google Sign-In SDK
  /// 2. Send token to backend for verification
  /// 3. Save Firebase tokens to secure storage
  /// 4. Return user model with Google profile data
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Get Google ID token from Google Sign-In
      final googleIdToken = await _googleSignIn.signIn();

      if (googleIdToken == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // 2. Send Google ID token to backend
      final response = await _apiService.signInWithGoogle(googleIdToken);

      // 3. Save tokens to secure storage
      await _storage.saveTokens(
        idToken: response.idToken,
        refreshToken: response.refreshToken,
        uid: response.uid,
      );

      // Get email from Google user if available
      final googleUser = _googleSignIn.currentUser;
      if (googleUser != null) {
        await _storage.saveEmail(googleUser.email);
      }

      // 4. Return user model
      return UserModel(
        uid: response.uid,
        email: googleUser?.email ?? '',
        emailVerified: response.emailVerified,
        displayName: googleUser?.displayName,
        photoUrl: googleUser?.photoUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════════

  /// Send password reset email
  /// 
  /// Calls backend to send password reset email to the user
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _apiService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign out
  /// 
  /// Steps:
  /// 1. Clear local storage (tokens, email, etc.)
  /// 2. Sign out from Google if user signed in with Google
  Future<void> signOut() async {
    try {
      // 1. Clear local storage
      await _storage.clearAll();

      // 2. Sign out from Google if signed in
      if (_googleSignIn.isSignedIn) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHECK AUTH STATE
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if user is logged in
  /// 
  /// Returns true if valid token exists in secure storage
  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  /// Get current user UID
  /// 
  /// Returns UID from secure storage or null if not logged in
  Future<String?> getCurrentUid() async {
    return await _storage.getUid();
  }

  /// Get current user email
  /// 
  /// Returns email from secure storage or null if not logged in
  Future<String?> getCurrentEmail() async {
    return await _storage.getEmail();
  }

  /// Get current user
  /// 
  /// Reconstructs UserModel from stored data
  Future<UserModel?> getCurrentUser() async {
    final uid = await _storage.getUid();
    final email = await _storage.getEmail();

    if (uid != null && email != null) {
      return UserModel(
        uid: uid,
        email: email,
        emailVerified: true, // Assume verified if logged in
      );
    }

    return null;
  }
}