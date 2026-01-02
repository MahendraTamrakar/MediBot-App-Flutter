/// Signup request DTO
/// 
/// Used to send email and password to the backend for account creation
class SignupRequest {
  final String email;
  final String password;

  SignupRequest({
    required this.email,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() => 'SignupRequest(email: $email)';
}