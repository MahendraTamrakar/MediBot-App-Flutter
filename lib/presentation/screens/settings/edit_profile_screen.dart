import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/providers/profile/profile_provider.dart';
import 'package:medibot/presentation/screens/settings/widgets/profile_image_popUp_menu.dart';
import 'package:medibot/presentation/screens/settings/widgets/profile_text_field.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  bool _isSaving = false;
  File? _selectedImageFile;
  String? _initialPhotoUrl; // Store initial photo URL as fallback

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _selectedGender;
  String? _selectedBloodType;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodTypeOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    final profileProvider = context.read<ProfileProvider>();
    final personalDetails = profileProvider.personalDetails;

    // Store initial photo URL as fallback - this won't change
    _initialPhotoUrl = personalDetails?.profilePhotoUrl ?? user?.photoUrl;

    _nameController = TextEditingController(
      text: personalDetails?.fullName ?? user?.firstName ?? '',
    );
    _ageController = TextEditingController(
      text: personalDetails?.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: personalDetails?.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: personalDetails?.weight?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: personalDetails?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: personalDetails?.address ?? '',
    );
    _selectedGender = personalDetails?.gender;
    _selectedBloodType = personalDetails?.bloodType;
    
    // Don't call loadPersonalDetails() here as it overwrites the photo URL
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _buildDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF9E9E9E),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFBDBDBD),
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        
        // Show selected image immediately
        setState(() {
          _selectedImageFile = imageFile;
          _isUploading = true;
        });

        final profileProvider = context.read<ProfileProvider>();

        await profileProvider.uploadProfilePhoto(imageFile);

        // Keep showing the local file - don't clear it
        // The local file will be shown until user leaves the screen
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Profile photo updated successfully',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedImageFile = null;
        });
        Fluttertoast.showToast(
          msg: 'Failed to upload photo: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Remove Photo',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'Are you sure you want to remove your profile photo?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove'),
                ),
              ],
            ),
      );

      if (confirmed == true && mounted) {
        setState(() => _isUploading = true);

        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.deleteProfilePhoto();

        // Clear the photo URL and selected file
        if (mounted) {
          setState(() {
            _initialPhotoUrl = null;
            _selectedImageFile = null;
          });

          Fluttertoast.showToast(
            msg: 'Profile photo removed',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to remove photo: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final profileProvider = context.read<ProfileProvider>();

      await profileProvider.updatePersonalDetails(
        fullName: _nameController.text.isNotEmpty ? _nameController.text : null,
        age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
        gender: _selectedGender,
        height: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
        weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        bloodType: _selectedBloodType,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Profile saved successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to save profile: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Edit Profile',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Center(
            child: Container(
              margin: const EdgeInsets.only(left: 10, top: 10),
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 193, 193, 193),
                  width: 0.15,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Profile Image
            Builder(
              builder: (context) {
                // Use the initial photo URL captured at init - this won't change
                final photoUrl = _initialPhotoUrl;
                
                // Determine what to show
                Widget imageWidget;
                if (_selectedImageFile != null) {
                  // Show locally selected image while uploading
                  imageWidget = Image.file(
                    _selectedImageFile!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  );
                } else if (photoUrl != null && photoUrl.isNotEmpty) {
                  // Show network image
                  imageWidget = CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 38,
                      color: Colors.white,
                    ),
                  );
                } else {
                  // Show default icon
                  imageWidget = const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  );
                }
                
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 163, 163, 163),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _isUploading && _selectedImageFile == null
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : imageWidget,
                      ),
                    ),
                    // Show loading overlay when uploading with selected image
                    if (_isUploading && _selectedImageFile != null)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (!_isUploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ProfileImagePopupMenu(
                          onGallery: _pickImageFromGallery,
                          onRemove: _removeProfilePhoto,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            ProfileTextField(
              label: 'Full Name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Age',
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _buildDropdownDecoration('Gender'),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Height (cm)',
              controller: _heightController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Weight (kg)',
              controller: _weightController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              decoration: _buildDropdownDecoration('Blood Type'),
              items: _bloodTypeOptions.map((bloodType) {
                return DropdownMenuItem(
                  value: bloodType,
                  child: Text(bloodType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Phone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Address',
              controller: _addressController,
              maxLines: 2,
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}