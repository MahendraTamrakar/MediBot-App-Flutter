import 'dart:developer' show log;

import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In service
///
/// Handles Google OAuth authentication using the google_sign_in package.
/// Returns Google ID token which is sent to backend for verification.
///
/// Features:
/// - Sign in with Google account
/// - Sign out from Google
/// - Get current user info
/// - Access user profile data
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign in with Google and return Google ID token
  ///
  /// Flow:
  /// 1. Opens Google Sign-In UI
  /// 2. User selects account and grants permissions
  /// 3. Returns Google ID token (send this to backend)
  ///
  /// Returns:
  /// - Google ID token if successful
  /// - null if user cancelled
  ///
  /// Throws:
  /// - Exception if sign-in fails
  Future<String?> signIn() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User cancelled the sign-in
        log('ℹ️ Google Sign-In cancelled by user');
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;

      // Return Google ID token (send this to backend)
      log('✅ Google Sign-In successful: ${account.email}');
      return auth.idToken;
    } catch (e) {
      log('❌ Google Sign-In error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN IN SILENTLY (Auto Sign-In)
  // ══════════════════════════════════════════════════════════════════════════

  /// Attempt to sign in silently (without UI)
  ///
  /// Useful for:
  /// - Auto-login on app start
  /// - Re-authentication without user interaction
  ///
  /// Returns:
  /// - Google ID token if successful
  /// - null if user not previously signed in
  Future<String?> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account == null) {
        log('ℹ️ No previous Google Sign-In found');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      log('✅ Silent Google Sign-In successful: ${account.email}');
      return auth.idToken;
    } catch (e) {
      log('❌ Silent Google Sign-In error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════════

  /// Sign out from Google
  ///
  /// Clears Google Sign-In session from device
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      log('✅ Google Sign-Out successful');
    } catch (e) {
      log('❌ Google Sign-Out error: $e');
    }
  }

  /// Disconnect Google account
  ///
  /// Revokes access completely (user will need to re-authorize)
  /// More thorough than signOut()
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      log('✅ Google disconnect successful');
    } catch (e) {
      log('❌ Google disconnect error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CURRENT USER
  // ══════════════════════════════════════════════════════════════════════════

  /// Get currently signed in Google account
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Check if user is currently signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Get user email (or null if not signed in)
  String? get userEmail => _googleSignIn.currentUser?.email;

  /// Get user display name (or null if not signed in)
  String? get userName => _googleSignIn.currentUser?.displayName;

  /// Get user photo URL (or null if not signed in)
  String? get userPhotoUrl => _googleSignIn.currentUser?.photoUrl;

  /// Get user ID (or null if not signed in)
  String? get userId => _googleSignIn.currentUser?.id;
}
