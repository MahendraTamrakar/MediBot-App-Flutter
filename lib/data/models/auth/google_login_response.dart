/// Google login response DTO
/// 
/// Received from backend after successful Google Sign-In
/// Contains Firebase tokens and user info from Google
class GoogleLoginResponse {
  final String idToken;
  final String refreshToken;
  final int? expiresIn;
  final String uid;
  final String? email;
  final String provider;

  GoogleLoginResponse({
    required this.idToken,
    required this.refreshToken,
    this.expiresIn,
    required this.uid,
    this.email,
    this.provider = 'google',
  });

  /// Parse from JSON response
  factory GoogleLoginResponse.fromJson(Map<String, dynamic> json) {
    return GoogleLoginResponse(
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int?,
      uid: json['uid'] as String,
      email: json['email'] as String?,
      provider: json['provider'] as String? ?? 'google',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'uid': uid,
      'email': email,
      'provider': provider,
    };
  }

  @override
  String toString() => 'GoogleLoginResponse(uid: $uid, email: $email, provider: $provider)';
}