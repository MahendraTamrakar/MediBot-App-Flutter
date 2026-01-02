/// Signup response DTO
/// 
/// Received from backend after successful account creation
/// Contains Firebase tokens and user info
class SignupResponse {
  final String idToken;
  final String refreshToken;
  final int? expiresIn;
  final String uid;
  final bool emailVerified;

  SignupResponse({
    required this.idToken,
    required this.refreshToken,
    this.expiresIn,
    required this.uid,
    required this.emailVerified,
  });

  /// Parse from JSON response
  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
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
  String toString() => 'SignupResponse(uid: $uid, emailVerified: $emailVerified)';
}