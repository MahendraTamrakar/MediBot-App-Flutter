/// Login response DTO
/// 
/// Received from backend after successful email/password authentication
/// Contains Firebase tokens and user info
class LoginResponse {
  final String idToken;
  final String refreshToken;
  final int? expiresIn;
  final String uid;
  final bool emailVerified;

  LoginResponse({
    required this.idToken,
    required this.refreshToken,
    this.expiresIn,
    required this.uid,
    required this.emailVerified,
  });

  /// Parse from JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int?,
      uid: json['uid'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'uid': uid,
      'emailVerified': emailVerified,
    };
  }

  @override
  String toString() => 'LoginResponse(uid: $uid, emailVerified: $emailVerified)';
}