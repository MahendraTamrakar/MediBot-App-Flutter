import 'package:flutter/material.dart';

class Chatmessage extends StatelessWidget {
  const Chatmessage({super.key, required this.text, required this.sender});

  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Row(
      // Align the user's message to the right
      mainAxisAlignment:
          sender == "User" ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align avatar and text at the top
      children: [
        if (sender != "User") // Show avatar only for MediBot (left side)
          Container(
            margin: const EdgeInsets.only(
              right: 8,
            ), // Space between avatar and text
            child: CircleAvatar(child: Text(sender[0])),
          ),
        Flexible(
          child: Column(
            crossAxisAlignment:
                sender == "User"
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              // Sender's name
              Text(
                sender,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              // Message text
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (sender == "User") // Show avatar only for the user (right side)
          Container(
            margin: const EdgeInsets.only(
              left: 8,
            ), // Space between text and avatar
            child: CircleAvatar(child: Text(sender[0])),
          ),
      ],
    );
  }
}
