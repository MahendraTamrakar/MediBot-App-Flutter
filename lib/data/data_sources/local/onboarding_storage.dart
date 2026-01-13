import 'dart:developer' show log;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';

/// Onboarding storage service
/// 
/// Manages the onboarding completion flag to determine
/// if user should see onboarding screens on app launch
class OnboardingStorage {
  final SharedPreferences _prefs;

  OnboardingStorage(this._prefs);

  // ══════════════════════════════════════════════════════════════════════════
  // ONBOARDING STATUS
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if onboarding is complete
  /// 
  /// Returns true if user has completed onboarding
  Future<bool> isOnboardingComplete() async {
    // Reload to get fresh data after hot restart
    await _prefs.reload();
    final isComplete = _prefs.getBool(StorageKeys.onboardingComplete) ?? false;
    log('📋 Onboarding complete check: $isComplete');
    return isComplete;
  }

  /// Mark onboarding as complete
  /// 
  /// Call this after user finishes onboarding screens
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(StorageKeys.onboardingComplete, true);
  }

  /// Reset onboarding status (for testing or re-onboarding)
  /// 
  /// This will show onboarding screens again on next launch
  Future<void> reset() async {
    await _prefs.remove(StorageKeys.onboardingComplete);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ONBOARDING PROGRESS (Optional)
  // ══════════════════════════════════════════════════════════════════════════

  /// Save current onboarding page (if user exits mid-onboarding)
  Future<void> saveCurrentPage(int pageIndex) async {
    await _prefs.setInt('onboarding_current_page', pageIndex);
  }

  /// Get saved onboarding page
  int getCurrentPage() {
    return _prefs.getInt('onboarding_current_page') ?? 0;
  }

  /// Clear onboarding progress
  Future<void> clearProgress() async {
    await _prefs.remove('onboarding_current_page');
  }
}