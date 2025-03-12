import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  Future<String> getGeminiResponse(String prompt) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Extract the response text from the API response
      final responseText = data["candidates"][0]["content"]["parts"][0]["text"];
      return responseText ?? "No response";
    } else {
      final errorData = jsonDecode(response.body);
      return "Error: ${errorData["error"]["message"]}";
    }
  }
}
