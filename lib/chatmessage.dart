import 'package:flutter/material.dart';

class Chatmessage extends StatelessWidget {
  const Chatmessage({super.key, required this.text, required this.sender});

  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          sender == "User" ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sender != "User")
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/icons/app.png'),
              radius: 20,
            ),
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
                margin: const EdgeInsets.only(top: 6),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (sender == "User")
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: CircleAvatar(child: Text(sender[0])),
          ),
      ],
    );
  }
}
