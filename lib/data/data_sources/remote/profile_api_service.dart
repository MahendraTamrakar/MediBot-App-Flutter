import 'package:dio/dio.dart';
import 'dart:io';
import 'api_client.dart';
import '../../models/profile/personal_details.dart';

import '../../../core/constants/api_constants.dart';

/// Profile API service - Handles all profile-related endpoints
class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  /// POST /user/profile
  Future<void> saveProfile({
    PersonalDetails? personalDetails,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (personalDetails != null) {
        data['personal_details'] = personalDetails.toJson();
      }


      await _apiClient.post(ApiConstants.saveProfile, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

 
  Future<void> savePersonalDetails(PersonalDetails personalDetails) async {
    try {
      await _apiClient.post(
        ApiConstants.saveProfile,
        data: {'personal_details': personalDetails.toJson()},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  


  /// GET /user/profile
  Future<PersonalDetails> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.getProfile);

      final data = response.data as Map<String, dynamic>;

      // Backend returns personal_details directly
      if (data.isEmpty) {
        // Return empty profile if no data
        return PersonalDetails();
      }

      return PersonalDetails.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

 
  Future<String> uploadProfilePhoto(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.uploadProfilePhoto,
        data: formData,
        onSendProgress:
            onProgress != null
                ? (sent, total) {
                  if (total > 0) {
                    onProgress(sent / total);
                  }
                }
                : null,
      );

      final data = response.data as Map<String, dynamic>;
      return data['profile_photo_url'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete profile photo
  /// DELETE /user/profile/photo
  Future<void> deleteProfilePhoto() async {
    try {
      await _apiClient.delete(ApiConstants.deleteProfilePhoto);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'An error occurred';

      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? data['message'] ?? message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Invalid profile data: $message';
        case 401:
          return 'Unauthorized. Please login again.';
        case 404:
          return 'Profile not found';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.unknown) {
      return 'No internet connection. Please check your network.';
    }

    return 'An unexpected error occurred';
  }
}
