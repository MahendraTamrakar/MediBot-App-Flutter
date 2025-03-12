import 'package:flutter/material.dart';
import 'package:medibot/chatmessage.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:medibot/gemini_service.dart';
import 'dart:math'; // For Random()

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Chatmessage> _messages = [];
  bool _isTyping = false; // Indicator for "MediBot is typing..."
  bool _hasChatStarted = false; // Track if the chat has started

  // List of greeting messages
  final List<String> _greetings = [
    "Hello! I'm MediBot, your personal health assistant. How can I help you today?",
    "Hi there! I'm here to assist with your health-related questions. What's on your mind?",
    "Welcome! I'm MediBot, ready to help you with medical advice and information. Ask me anything!",
    "Hey! I'm MediBot, your virtual health companion. How can I assist you today?",
    "Hi! I'm MediBot, here to make health advice simple and accessible. What do you need help with?",
    "Hello! I'm MediBot, your friendly health assistant. Let’s talk about your health concerns!",
    "Welcome to MediBot! I’m here to provide quick and reliable health information. How can I help?",
  ];

  String _currentGreeting = ""; // Current greeting message

  @override
  void initState() {
    super.initState();
    _refreshChat(); // Set initial greeting when the screen loads
  }

  void _refreshChat() {
    setState(() {
      _messages.clear(); // Clear the chat history
      _isTyping = false; // Reset the typing indicator
      _hasChatStarted = false; // Reset the chat started flag
      _currentGreeting =
          _greetings[Random().nextInt(_greetings.length)]; // Random greeting
    });
  }

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _hasChatStarted = true; // Chat has started
    });

    Chatmessage userChat = Chatmessage(text: userMessage, sender: "User");

    setState(() {
      _messages.insert(0, userChat);
      _isTyping = true;
    });

    FocusScope.of(context).unfocus();
    _controller.clear();

    // Run Gemini API call in a background task
    Future.microtask(() async {
      GeminiService geminiService = GeminiService();
      String botResponse = await geminiService.getGeminiResponse(userMessage);
      print("Bot Response: $botResponse"); // Debugging output

      if (!mounted) return;

      Chatmessage botChat = Chatmessage(text: botResponse, sender: "MediBot");

      setState(() {
        _messages.insert(0, botChat);
        _isTyping = false;
      });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 14, 14, 14),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Message MediBot",
                filled: true,
                fillColor: const Color.fromARGB(255, 46, 46, 45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(),
                ),
              ),
              style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MediBot"),
        centerTitle: true,
        forceMaterialTransparency: false,
        backgroundColor: const Color.fromARGB(255, 46, 46, 45),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white), // Refresh icon
            onPressed: () {
              _refreshChat(); // Refresh the chat and change the greeting
            },
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 14, 14, 14),
        child: SafeArea(
          child: Column(
            children: [
              // Show image and greeting only if chat has not started
              if (!_hasChatStarted)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/home_screen/Goku-70-1.png', // Replace with your image path
                          width: 200,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20), // Spacing between image and text
                        Text(
                          _currentGreeting, // Display the random greeting
                          style: TextStyle(
                            color: const Color.fromARGB(255, 221, 220, 220),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              Flexible(
                child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                ),
              ),
              if (_isTyping) // Show typing indicator when AI is processing
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "MediBot is typing...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              Container(
                margin: EdgeInsetsDirectional.only(
                  start: 10,
                  end: 10,
                  bottom: 15,
                  top: 10,
                ),
                decoration: BoxDecoration(color: context.cardColor),
                child: _buildTextComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
