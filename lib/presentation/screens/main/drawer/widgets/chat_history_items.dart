import 'package:flutter/material.dart';
import 'package:medibot/data/models/chat/chat_session.dart';

class ChatHistoryItem extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatHistoryItem({ super.key,
    required this.session,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = session.title ?? 'Untitled Chat';
    //final date = _formatDate(session.updatedAt);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            //const Icon(Icons.chat_bubble_rounded, color: Colors.white38, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  /* const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ), */
                ],
              ),
            ),
            /* const Icon(Icons.more_vert, color: Color.fromARGB(255, 255, 255, 255), size: 18),
            const SizedBox(width: 16), */
          ],
        ),
      ),
    );
  }

  /* String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  } */
}

