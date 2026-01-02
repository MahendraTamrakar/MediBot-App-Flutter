import 'dart:async';
import 'dart:developer' show log;

import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity service
///
/// Monitors internet connection status in real-time.
///
/// **Why is this useful?**
///
/// 1. **Show offline UI**: Display "No Internet" banner when disconnected
/// 2. **Prevent API calls**: Don't make requests when offline
/// 3. **Queue operations**: Save requests to retry when back online
/// 4. **Better UX**: Inform user about connection issues
/// 5. **Auto-retry**: Automatically retry failed requests when connected
///
/// Features:
/// - Real-time connection monitoring
/// - Stream of connectivity changes
/// - Check current connection status
/// - Distinguish between WiFi, Mobile, and No Connection
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity changes
  ///
  /// Listen to this stream to get notified when connection changes
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // ══════════════════════════════════════════════════════════════════════════
  // CHECK CONNECTION STATUS
  // ══════════════════════════════════════════════════════════════════════════

  /// Check current connectivity status
  ///
  /// Returns list of active connection types:
  /// - [ConnectivityResult.mobile] - Mobile data
  /// - [ConnectivityResult.wifi] - WiFi
  /// - [ConnectivityResult.ethernet] - Ethernet
  /// - [ConnectivityResult.none] - No connection
  Future<List<ConnectivityResult>> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return [result];
    } catch (e) {
      log('❌ Error checking connectivity: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Check if device has internet connection
  ///
  /// Returns true if connected to any network (WiFi, Mobile, Ethernet)
  Future<bool> hasConnection() async {
    final result = await checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Check if connected via WiFi
  Future<bool> isWifiConnected() async {
    final result = await checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Check if connected via Mobile data
  Future<bool> isMobileConnected() async {
    final result = await checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }

  /// Check if connected via Ethernet
  Future<bool> isEthernetConnected() async {
    final result = await checkConnectivity();
    return result.contains(ConnectivityResult.ethernet);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONNECTION TYPE
  // ══════════════════════════════════════════════════════════════════════════

  /// Get user-friendly connection type string
  ///
  /// Returns:
  /// - "WiFi"
  /// - "Mobile Data"
  /// - "Ethernet"
  /// - "No Connection"
  Future<String> getConnectionType() async {
    final result = await checkConnectivity();

    if (result.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (result.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'No Connection';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STREAM HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Stream that emits true when connected, false when disconnected
  Stream<bool> get connectionStream {
    return onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  /// Stream of connection type strings
  Stream<String> get connectionTypeStream {
    return onConnectivityChanged.map((result) {
      if (result == ConnectivityResult.wifi) {
        return 'WiFi';
      } else if (result == ConnectivityResult.mobile) {
        return 'Mobile Data';
      } else if (result == ConnectivityResult.ethernet) {
        return 'Ethernet';
      } else {
        return 'No Connection';
      }
    });
  }
}
