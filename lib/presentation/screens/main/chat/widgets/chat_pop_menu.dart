import 'package:flutter/material.dart';
import 'package:medibot/presentation/providers/chat/chat_provider.dart';

class ChatPopupMenu extends StatefulWidget {
  final ChatProvider chatProvider;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ChatPopupMenu({super.key, 
    required this.chatProvider,
    required this.onRename,
    required this.onDelete,
  });

  @override
  State<ChatPopupMenu> createState() => _ChatPopupMenuState();
}

class _ChatPopupMenuState extends State<ChatPopupMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 10),
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color.fromARGB(255, 193, 193, 193),
          width: 0.15,
        ),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert_rounded, size: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: theme.cardColor,
        offset: const Offset(0, 50),
        constraints: const BoxConstraints(minWidth: 180),
        itemBuilder: (itemContext) {
          final itemTheme = Theme.of(itemContext);
          return [
            PopupMenuItem<String>(
              height: 36,
              enabled: false,
              child: Text(
                widget.chatProvider.currentSessionTitle ??
                    (widget.chatProvider.currentSessionId != null
                        ? 'Current Chat'
                        : 'New Chat'),
                style: itemTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
                maxLines: 2,
              ),
            ),
            const PopupMenuDivider(height: 1),
            PopupMenuItem<String>(
              value: 'rename',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: itemTheme.iconTheme.color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Rename',
                    style: itemTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_rounded,
                    size: 20,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: itemTheme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 'rename') {
            widget.onRename();
          } else if (value == 'delete') {
            widget.onDelete();
          }
        },
      ),
    );
  }
}