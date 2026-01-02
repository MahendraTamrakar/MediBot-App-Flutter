import 'package:flutter/material.dart';

/// Success dialog
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;

  const SuccessDialog({
    Key? key,
    this.title = 'Success',
    required this.message,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title ?? 'Success',
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
          const Icon(Icons.check_circle_outline, color: Colors.green),
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