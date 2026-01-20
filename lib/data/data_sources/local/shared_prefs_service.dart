import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';

class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  /// Save theme mode ('light', 'dark', or 'system')
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(StorageKeys.themeMode, themeMode);
  }

  /// Get theme mode
  String getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode) ?? 'system';
  }

  /// Check if dark mode is enabled
  bool isDarkMode() {
    return getThemeMode() == 'dark';
  }

  /// Save first launch date
  Future<void> saveFirstLaunchDate() async {
    final hasDate = _prefs.containsKey(StorageKeys.firstLaunchDate);
    if (!hasDate) {
      await _prefs.setString(
        StorageKeys.firstLaunchDate,
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Get first launch date
  DateTime? getFirstLaunchDate() {
    final dateString = _prefs.getString(StorageKeys.firstLaunchDate);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Save last app version
  Future<void> saveAppVersion(String version) async {
    await _prefs.setString(StorageKeys.lastAppVersion, version);
  }

  /// Get last app version
  String? getLastAppVersion() {
    return _prefs.getString(StorageKeys.lastAppVersion);
  }

  /// Check if app was updated
  bool wasAppUpdated(String currentVersion) {
    final lastVersion = getLastAppVersion();
    return lastVersion != null && lastVersion != currentVersion;
  }


  /// Save analytics enabled state
  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.analyticsEnabled, enabled);
  }

  /// Check if analytics are enabled
  bool areAnalyticsEnabled() {
    return _prefs.getBool(StorageKeys.analyticsEnabled) ?? true;
  }

  /// Save crashlytics enabled state
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.crashlyticsEnabled, enabled);
  }

  /// Check if crashlytics are enabled
  bool areCrashlyticsEnabled() {
    return _prefs.getBool(StorageKeys.crashlyticsEnabled) ?? true;
  }

  /// Save data collection consent
  Future<void> setDataCollectionConsent(bool consent) async {
    await _prefs.setBool(StorageKeys.dataCollectionConsent, consent);
  }

  /// Check if user gave consent for data collection
  bool hasDataCollectionConsent() {
    return _prefs.getBool(StorageKeys.dataCollectionConsent) ?? false;
  }


  /// Save last sync timestamp
  Future<void> saveLastSyncTime() async {
    await _prefs.setString(
      StorageKeys.lastSyncTime,
      DateTime.now().toIso8601String(),
    );
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(StorageKeys.lastSyncTime);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  /// Check if cache is stale (older than specified duration)
  bool isCacheStale(Duration maxAge) {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    return difference > maxAge;
  }


  /// Save string value
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save int value
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save bool value
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save double value
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Save string list
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  /// Get string list
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Remove a key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Clear all except specified keys
  Future<void> clearAllExcept(List<String> keysToKeep) async {
    final allKeys = _prefs.getKeys();
    final keysToRemove = allKeys.where((key) => !keysToKeep.contains(key));

    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }

  /// Get data size (number of stored items)
  int getDataSize() {
    return _prefs.getKeys().length;
  }

  /// Reload data from disk
  Future<void> reload() async {
    await _prefs.reload();
  }
}