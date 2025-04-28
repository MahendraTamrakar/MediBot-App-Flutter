import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl =
      'http://192.168.86.231:8000/chat'; // or replace with your IP on real device

  Future<String> getBotResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': message}), // ✅ Correct key here
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']; // ✅ Must match backend response format
      } else {
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Error sending message: $e";
    }
  }
}
