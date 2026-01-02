import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  /// Requests Camera access
  static Future<bool> requestCamera() async {
    return await _requestPermission(Permission.camera);
  }

  /// Requests Storage access (Handles Android 13+ differences automatically)
  static Future<bool> requestStorage() async {
    if (Platform.isAndroid) {
      // On Android 13+ (SDK 33), "Storage" permission is split into Photos/Video/Audio
      // The permission_handler package usually handles this logic, 
      // but sometimes you need to check specific media types.
      
      // Try generic storage first (for older Android)
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      
      // If that fails/is restricted, try the new Photos permission
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      
      return false;
    } else {
      // iOS usually requires specific usage descriptions in Info.plist
      return await _requestPermission(Permission.storage);
    }
  }

  /// Requests Microphone access
  static Future<bool> requestMicrophone() async {
    return await _requestPermission(Permission.microphone);
  }

  // INTERNAL HELPER
  static Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // The user clicked "Don't ask again". We must direct them to Settings.
      await openAppSettings();
      return false;
    } else {
      return false;
    }
  }
}