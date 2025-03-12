import 'package:flutter/material.dart';
import 'package:medibot/chat_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized

  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully!");
  } catch (e) {
    print("❌ Error loading .env file: $e"); // Debugging output
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 31, 29, 34),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
