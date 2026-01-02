/// User model
/// 
/// Represents the currently authenticated user
/// Used throughout the app for user information
class UserModel {
  final String uid;
  final String email;
  final bool emailVerified;
  final String? displayName;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
    this.photoUrl,
  });

  /// Parse from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    bool? emailVerified,
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Get display name or email as fallback
  String get displayNameOrEmail => displayName ?? email;

  /// Get first name from display name
  String? get firstName {
    if (displayName == null) return null;
    final parts = displayName!.split(' ');
    return parts.isNotEmpty ? parts.first : null;
  }

  /// Get initials for avatar (e.g., "John Doe" -> "JD")
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        return displayName![0].toUpperCase();
      }
    }
    return email[0].toUpperCase();
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, displayName: $displayName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}