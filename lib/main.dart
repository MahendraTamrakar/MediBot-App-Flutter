import 'package:flutter/material.dart';
import 'package:medibot/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /* try {
    await dotenv.load(fileName: ".env");
    log("✅ .env file loaded successfully!");
  } catch (e) {
    log("❌ Error loading .env file: $e");
  } */

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
