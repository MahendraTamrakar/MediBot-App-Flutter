import '../data_sources/remote/profile_api_service.dart';
import '../models/profile/personal_details.dart';
import '../models/profile/medical_profile.dart';
import 'dart:io';

/// Profile repository - Business logic for profile operations
///
/// Coordinates:
/// - Profile API service (remote data)
/// - Local caching for offline access
/// - Validation and data transformation
class ProfileRepository {
  final ProfileApiService _profileApiService;

  ProfileRepository({required ProfileApiService profileApiService})
    : _profileApiService = profileApiService;

  // ══════════════════════════════════════════════════════════════════════════
  // PERSONAL DETAILS
  // ══════════════════════════════════════════════════════════════════════════

  /// Save personal details
  ///
  /// [personalDetails] - Personal information to save
  Future<void> savePersonalDetails(PersonalDetails personalDetails) async {
    try {
      // Validate before saving
      _validatePersonalDetails(personalDetails);

      await _profileApiService.savePersonalDetails(personalDetails);

      // Optional: Cache locally
      // await _cachePersonalDetails(personalDetails);
    } catch (e) {
      throw Exception('Failed to save personal details: $e');
    }
  }

  /// Get personal details
  ///
  /// Returns user's personal information
  Future<PersonalDetails> getPersonalDetails() async {
    try {
      final details = await _profileApiService.getProfile();

      // Optional: Cache for offline access
      // await _cachePersonalDetails(details);

      return details;
    } catch (e) {
      // Try to get from cache if API fails
      // final cached = await _getCachedPersonalDetails();
      // if (cached != null) return cached;

      throw Exception('Failed to get personal details: $e');
    }
  }

  /// Update specific personal detail field
  ///
  /// This is a convenience method to update a single field
  /// without fetching and re-saving the entire profile
  Future<void> updatePersonalDetailField({
    String? fullName,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? bloodType,
    String? phone,
    String? address,
  }) async {
    try {
      // Get current details
      final currentDetails = await getPersonalDetails();

      // Create updated details
      final updatedDetails = currentDetails.copyWith(
        fullName: fullName,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        bloodType: bloodType,
        phone: phone,
        address: address,
      );

      // Save updated details
      await savePersonalDetails(updatedDetails);
    } catch (e) {
      throw Exception('Failed to update personal detail: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MEDICAL PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Get medical profile
  ///
  /// Returns user's medical history
  Future<MedicalProfile> getMedicalProfile() async {
    try {
      final profile = await _profileApiService.getMedicalProfile();
      return profile;
    } catch (e) {
      throw Exception('Failed to get medical profile: $e');
    }
  }

  /// Save medical profile
  ///
  /// [medicalProfile] - Medical history to save
  Future<void> saveMedicalProfile(MedicalProfile medicalProfile) async {
    try {
      // Validate before saving
      _validateMedicalProfile(medicalProfile);

      await _profileApiService.saveMedicalProfile(medicalProfile);

      // Optional: Cache locally
      // await _cacheMedicalProfile(medicalProfile);
    } catch (e) {
      throw Exception('Failed to save medical profile: $e');
    }
  }

  /// Update medical profile field
  ///
  /// Convenience method to update specific medical profile fields
  Future<void> updateMedicalProfileField({
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    List<String>? pastSurgeries,
    String? familyHistory,
    bool? isSmoker,
    bool? drinksAlcohol,
    String? exerciseFrequency,
    String? dietType,
  }) async {
    try {
      // For simplicity, create new profile with provided fields
      // In production, you might want to fetch current profile first
      final updatedProfile = MedicalProfile(
        allergies: allergies,
        chronicConditions: chronicConditions,
        currentMedications: currentMedications,
        pastSurgeries: pastSurgeries,
        familyHistory: familyHistory,
        isSmoker: isSmoker,
        drinksAlcohol: drinksAlcohol,
        exerciseFrequency: exerciseFrequency,
        dietType: dietType,
      );

      await saveMedicalProfile(updatedProfile);
    } catch (e) {
      throw Exception('Failed to update medical profile: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE PHOTO OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload profile photo
  ///
  /// [imageFile] - Image file to upload
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns the URL of the uploaded photo
  Future<String> uploadProfilePhoto(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Upload the photo
      final photoUrl = await _profileApiService.uploadProfilePhoto(
        imageFile,
        onProgress: onProgress,
      );

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Delete profile photo
  ///
  /// Removes the user's profile photo
  Future<void> deleteProfilePhoto() async {
    try {
      await _profileApiService.deleteProfilePhoto();
    } catch (e) {
      throw Exception('Failed to delete profile photo: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMBINED OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Save complete profile (personal + medical)
  ///
  /// [personalDetails] - Personal information
  /// [medicalProfile] - Medical history
  Future<void> saveCompleteProfile({
    PersonalDetails? personalDetails,
    MedicalProfile? medicalProfile,
  }) async {
    try {
      if (personalDetails != null) {
        _validatePersonalDetails(personalDetails);
      }

      if (medicalProfile != null) {
        _validateMedicalProfile(medicalProfile);
      }

      await _profileApiService.saveProfile(
        personalDetails: personalDetails,
        medicalProfile: medicalProfile,
      );
    } catch (e) {
      throw Exception('Failed to save complete profile: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════

  void _validatePersonalDetails(PersonalDetails details) {
    if (details.age != null && (details.age! < 0 || details.age! > 150)) {
      throw Exception('Invalid age: must be between 0 and 150');
    }

    if (details.height != null &&
        (details.height! < 0 || details.height! > 300)) {
      throw Exception('Invalid height: must be between 0 and 300 cm');
    }

    if (details.weight != null &&
        (details.weight! < 0 || details.weight! > 500)) {
      throw Exception('Invalid weight: must be between 0 and 500 kg');
    }

    if (details.phone != null && details.phone!.length < 10) {
      throw Exception('Invalid phone number');
    }
  }

  void _validateMedicalProfile(MedicalProfile profile) {
    // Add any medical profile validation here
    // For now, no specific validation needed
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if profile is complete
  ///
  /// Returns true if both personal and medical profiles have essential data
  Future<bool> isProfileComplete() async {
    try {
      final personalDetails = await getPersonalDetails();

      // Check if essential fields are filled
      final hasEssentialPersonalInfo =
          personalDetails.fullName != null &&
          personalDetails.age != null &&
          personalDetails.gender != null;

      return hasEssentialPersonalInfo;
    } catch (e) {
      return false;
    }
  }

  /// Get profile completion percentage
  ///
  /// Returns a percentage (0-100) of how complete the profile is
  Future<int> getProfileCompletionPercentage() async {
    try {
      final personalDetails = await getPersonalDetails();

      int totalFields = 8; // Total number of personal detail fields
      int filledFields = 0;

      if (personalDetails.fullName != null) filledFields++;
      if (personalDetails.age != null) filledFields++;
      if (personalDetails.gender != null) filledFields++;
      if (personalDetails.height != null) filledFields++;
      if (personalDetails.weight != null) filledFields++;
      if (personalDetails.bloodType != null) filledFields++;
      if (personalDetails.phone != null) filledFields++;
      if (personalDetails.address != null) filledFields++;

      return ((filledFields / totalFields) * 100).round();
    } catch (e) {
      return 0;
    }
  }
}
