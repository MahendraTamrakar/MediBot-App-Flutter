import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medibot/chatmessage.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:medibot/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final List<Chatmessage> _messages = [];
  bool _isTyping = false;
  bool _hasChatStarted = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  final List<String> _greetings = [
    "Hello! I'm MediBot, your personal health assistant. How can I help you today?",
    "Hi there! I'm here to assist with your health-related questions. What's on your mind?",
    "Welcome! I'm MediBot, ready to help you with medical advice and information. Ask me anything!",
    "Hey! I'm MediBot, your virtual health companion. How can I assist you today?",
    "Hi! I'm MediBot, here to make health advice simple and accessible. What do you need help with?",
    "Hello! I'm MediBot, your friendly health assistant. Let’s talk about your health concerns!",
    "Welcome to MediBot! I’m here to provide quick and reliable health information. How can I help?",
  ];

  String _currentGreeting = "";
  final FocusNode _focusNode = FocusNode();

  List<Chatmessage> get userMessages =>
      _messages.where((msg) => msg.sender == "User").toList();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _refreshChat();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _hasChatStarted = true;
        });
      }
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('Speech status: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false); // 🔴 Turn off glow
          }
        },
        onError: (val) {
          debugPrint('Speech error: $val');
          setState(() => _isListening = false); // 🔴 Turn off glow on error
        },
      );

      if (available) {
        setState(() => _isListening = true); // 🔴 Turn on glow
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });

            // Optional: Auto-stop after result
            if (val.finalResult) {
              _speech.stop();
              setState(() => _isListening = false); // 🔴 Turn off glow
            }
          },
          listenFor: const Duration(seconds: 10), // Optional timeout
          pauseFor: const Duration(seconds: 3), // Silence timeout
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false); // 🔴 Turn off glow
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _refreshChat() {
    setState(() {
      _messages.clear();
      _isTyping = false;
      _hasChatStarted = false;
      _currentGreeting = _greetings[Random().nextInt(_greetings.length)];
    });
  }

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _hasChatStarted = true;
    });

    Chatmessage userChat = Chatmessage(text: userMessage, sender: "User");

    setState(() {
      _messages.insert(0, userChat);
      _isTyping = true;
    });

    FocusScope.of(context).unfocus();
    _controller.clear();

    Future.microtask(() async {
      String botResponse = await ChatService().getBotResponse(userMessage);
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
              focusNode: _focusNode,
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
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow:
                            _isListening
                                ? [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.7),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                                : [],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: _listen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Color.fromARGB(255, 14, 14, 14),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Chat History",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      userMessages.isEmpty
                          ? Center(
                            child: Text(
                              "No chat history yet.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            itemCount: userMessages.length,
                            itemBuilder: (context, index) {
                              final msg = userMessages[index];
                              return ListTile(
                                title: Text(
                                  msg.text,
                                  style: TextStyle(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _controller.text = msg.text;
                                  });
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("MediBot"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 46, 46, 45),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _refreshChat();
            },
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 14, 14, 14),
        child: SafeArea(
          child: Column(
            children: [
              if (!_hasChatStarted)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/home_screen/medical-team.png',
                          width: 120,
                          height: 110,
                          fit: BoxFit.fitHeight,
                        ),
                        SizedBox(height: 10),
                        Text(
                          _currentGreeting,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 224, 223, 223),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _messages[index],
                    );
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        radius: 16,
                        child: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const SpinKitThreeBounce(color: Colors.grey, size: 20.0),
                    ],
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
