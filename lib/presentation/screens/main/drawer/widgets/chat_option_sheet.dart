import 'package:flutter/material.dart';
import 'package:medibot/data/models/chat/chat_session.dart';

// give delete and rename options for title when long pressed
class ChatOptionsSheet extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ChatOptionsSheet({super.key, 
    required this.session,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 139, 139, 139),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              session.title ?? 'Untitled Chat',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              title: Text(
                'Rename',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500
                ),
              ),
              onTap: onRename,
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep, color: Theme.of(context).primaryColor),
              title: Text(
                'Delete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500
                ),
              ),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
