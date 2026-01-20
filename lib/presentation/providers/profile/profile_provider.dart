import 'package:flutter/foundation.dart';
import 'dart:developer' show log;
import 'dart:io';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/profile/personal_details.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileProvider(this._profileRepository);

  PersonalDetails? _personalDetails;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  PersonalDetails? get personalDetails => _personalDetails;

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



  /// Load personal details from backend or cache
  Future<void> loadPersonalDetails({bool preferCache = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📥 Loading personal details');

      // Try cache first if requested
      if (preferCache) {
        final repo = _profileRepository;
        final cached = await repo.getCachedPersonalDetails();
        if (cached != null) {
          _personalDetails = cached;
          _isLoading = false;
          notifyListeners();
          return;
        }
            }

      // Preserve existing photo URL in case backend doesn't return one
      final existingPhotoUrl = _personalDetails?.profilePhotoUrl;
      final newDetails = await _profileRepository.getPersonalDetails();
      // If new details don't have a photo URL but we had one, preserve it
      if (newDetails.profilePhotoUrl == null && existingPhotoUrl != null) {
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


  Future<void> updatePersonalDetails({
    String? email,
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
        email: email ?? _personalDetails?.email,
        fullName: fullName,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        bloodType: bloodType,
        phone: phone,
        address: address,
      );

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

  // Delete profile photo
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




  // Clear profile data (on logout)
  void clear() {
    _personalDetails = null;
    _isLoading = false;
    _errorMessage = null;
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
