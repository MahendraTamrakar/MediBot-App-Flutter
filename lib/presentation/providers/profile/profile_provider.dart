import 'package:flutter/foundation.dart';
import 'dart:developer' show log;
import 'dart:io';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/profile/personal_details.dart';
import '../../../data/models/profile/medical_profile.dart';

/// Profile Provider - Manages user profile state
///
/// Handles:
/// - Personal details (name, age, gender, etc.)
/// - Medical profile (allergies, medications, conditions)
/// - Profile photo upload and deletion
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileProvider(this._profileRepository);

  PersonalDetails? _personalDetails;
  MedicalProfile? _medicalProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  PersonalDetails? get personalDetails => _personalDetails;
  MedicalProfile? get medicalProfile => _medicalProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  // Personal details convenience getters
  String? get fullName => _personalDetails?.fullName;
  int? get age => _personalDetails?.age;
  String? get gender => _personalDetails?.gender;
  double? get height => _personalDetails?.height;
  double? get weight => _personalDetails?.weight;
  String? get bloodType => _personalDetails?.bloodType;
  String? get phone => _personalDetails?.phone;
  String? get address => _personalDetails?.address;
  String? get profilePhotoUrl => _personalDetails?.profilePhotoUrl;

  // Medical profile convenience getters
  List<String>? get allergies => _medicalProfile?.allergies;
  List<String>? get medications => _medicalProfile?.currentMedications;
  List<String>? get conditions => _medicalProfile?.chronicConditions;

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Load personal details from backend
  Future<void> loadPersonalDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📥 Loading personal details');

      // Preserve existing photo URL in case backend doesn't return one
      final existingPhotoUrl = _personalDetails?.profilePhotoUrl;
      
      final newDetails = await _profileRepository.getPersonalDetails();
      
      // If new details don't have a photo URL but we had one, preserve it
      if (newDetails != null && newDetails.profilePhotoUrl == null && existingPhotoUrl != null) {
        _personalDetails = newDetails.copyWith(profilePhotoUrl: existingPhotoUrl);
      } else {
        _personalDetails = newDetails;
      }

      log('✅ Personal details loaded: ${_personalDetails?.fullName}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Failed to load personal details: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load medical profile from backend
  Future<void> loadMedicalProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📥 Loading medical profile');

      _medicalProfile = await _profileRepository.getMedicalProfile();

      log('✅ Medical profile loaded');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Failed to load medical profile: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load complete profile (personal + medical)
  Future<void> loadProfile() async {
    await loadPersonalDetails();
    try {
      await loadMedicalProfile();
    } catch (e) {
      // Medical profile is optional, don't fail if it doesn't exist
      log('⚠️ Medical profile not loaded: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Update personal details
  Future<void> updatePersonalDetails({
    String? fullName,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? bloodType,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📝 Updating personal details');

      await _profileRepository.updatePersonalDetailField(
        fullName: fullName,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        bloodType: bloodType,
        phone: phone,
        address: address,
      );

      // Reload personal details to get updated data
      await loadPersonalDetails();

      log('✅ Personal details updated successfully');
    } catch (e) {
      log('❌ Failed to update personal details: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE PHOTO OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload profile photo
  ///
  /// [imageFile] - Image file to upload
  Future<void> uploadProfilePhoto(File imageFile) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📤 Uploading profile photo');

      final photoUrl = await _profileRepository.uploadProfilePhoto(
        imageFile,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // Update personal details with new photo URL
      if (_personalDetails != null) {
        _personalDetails = _personalDetails!.copyWith(
          profilePhotoUrl: photoUrl,
        );
      } else {
        // Create new PersonalDetails with just the photo URL
        _personalDetails = PersonalDetails(
          profilePhotoUrl: photoUrl,
        );
      }

      log('✅ Profile photo uploaded: $photoUrl');
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
    } catch (e) {
      log('❌ Failed to upload photo: $e');
      _errorMessage = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE PROFILE PHOTO
  // ══════════════════════════════════════════════════════════════════════════

  /// Delete profile photo
  Future<void> deleteProfilePhoto() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('🗑️ Deleting profile photo');

      await _profileRepository.deleteProfilePhoto();

      // Update personal details to remove photo URL
      if (_personalDetails != null) {
        _personalDetails = _personalDetails!.copyWith(profilePhotoUrl: null);
      }

      log('✅ Profile photo deleted');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Failed to delete photo: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REFRESH PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Refresh profile (pull-to-refresh)
  Future<void> refreshProfile() async {
    try {
      await Future.wait([
        _profileRepository.getPersonalDetails().then((details) {
          _personalDetails = details;
        }),
        _profileRepository
            .getMedicalProfile()
            .then((profile) {
              _medicalProfile = profile;
            })
            .catchError((e) {
              // Medical profile is optional
              log('⚠️ Medical profile not loaded: $e');
            }),
      ]);
      notifyListeners();
    } catch (e) {
      log('⚠️ Failed to refresh profile: $e');
      // Don't throw - this is a background refresh
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEAR
  // ══════════════════════════════════════════════════════════════════════════

  /// Clear profile data (on logout)
  void clear() {
    _personalDetails = null;
    _medicalProfile = null;
    _isLoading = false;
    _errorMessage = null;
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
