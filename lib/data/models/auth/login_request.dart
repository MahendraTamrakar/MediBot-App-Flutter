/// Login request DTO (Data Transfer Object)
/// 
/// Used to send email and password to the backend for authentication
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
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
  String toString() => 'LoginRequest(email: $email)';
}