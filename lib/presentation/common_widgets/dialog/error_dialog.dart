import 'package:flutter/material.dart';

/// Error dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title ?? 'Error',
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}