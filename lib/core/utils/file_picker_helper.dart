import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:medibot/core/errors/app_exceptions.dart';

class FilePickerHelper {
  /// Picks a single file (PDF, JPG, PNG)
  /// Returns null if user cancels the picker.
  static Future<File?> pickReportFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      } else {
        // User canceled the picker
        return null; 
      }
    } catch (e) {
      throw AppException("Failed to pick file: $e", "File Error: ");
    }
  }

  /// Picks a profile picture (Image only)
  static Future<File?> pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw AppException("Failed to pick image", "File Error: ");
    }
  }
}