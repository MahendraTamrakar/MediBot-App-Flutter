class AppException implements Exception {
  final String message;
  final String prefix;

  AppException([this.message = "Something went wrong", this.prefix = "Error: "]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

// 1. Network Issues (No Internet, Timeout)
class NetworkException extends AppException {
  NetworkException([String message = "No Internet Connection"]) 
      : super(message, "Network Error: ");
}

// 2. Server Issues (500 Errors, API down)
class ServerException extends AppException {
  ServerException([String message = "Server is unable to process request"]) 
      : super(message, "Server Error: ");
}

// 3. Auth Issues (Wrong Password, Token Expired)
class AuthException extends AppException {
  AuthException([String message = "Authentication Failed"]) 
      : super(message, "Auth Error: ");
}

// 4. Data Format Issues (Bad JSON)
class DataFormatException extends AppException {
  DataFormatException([String message = "Invalid Data Format"]) 
      : super(message, "Data Error: ");
}