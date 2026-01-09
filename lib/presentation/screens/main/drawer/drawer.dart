import 'package:flutter/material.dart';
import 'package:medibot/presentation/screens/main/drawer/widgets/chat_history_items.dart';
import 'package:medibot/presentation/screens/main/drawer/widgets/chat_option_sheet.dart';
import 'package:provider/provider.dart';
import 'package:medibot/presentation/providers/chat/chat_provider.dart';
import 'package:medibot/data/models/chat/chat_session.dart';

class DrawerMenu extends StatefulWidget {
  final VoidCallback? onChatSelected;
  final VoidCallback? onNewChat;

  const DrawerMenu({super.key, this.onChatSelected, this.onNewChat});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    super.initState();
    // Fetch chat sessions when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchChatSessions();
    });
  }

  void _onNewChat() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.newConversation();
    widget.onNewChat?.call();
  }

  void _onChatTap(ChatSession session) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.loadChatSession(session.sessionId);
    widget.onChatSelected?.call();
  }

  void _showChatOptions(ChatSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => ChatOptionsSheet(
            session: session,
            onRename: () => _showRenameDialog(session),
            onDelete: () => _deleteChat(session),
          ),
    );
  }

  void _showRenameDialog(ChatSession session) {
    Navigator.pop(context); // Close bottom sheet

    final controller = TextEditingController(text: session.title ?? 'Untitled');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Rename Chat',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600

              ),
            ),
            content: TextField(
              controller: controller,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,

              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 96, 96, 96) , width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 96, 96, 96) , width: 1.0),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rename feature coming soon'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Rename'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteChat(ChatSession session) async {
    Navigator.pop(context); // Close bottom sheet

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Delete Chat',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${session.title ?? 'this chat'}"?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final chatProvider = context.read<ChatProvider>();
        await chatProvider.deleteChatSession(session.sessionId);
        chatProvider.fetchChatSessions(); // Refresh list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Theme.of(context).cardColor,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(radius: 22),
              SizedBox(width: 12),
              Text(
                "MediBot",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Menu Items
          _drawerItem(Icons.add_circle_outline_rounded, "New Chat", onTap: _onNewChat),
          _drawerItem(Icons.file_upload_rounded, "Upload Medical Report"),
          _drawerItem(Icons.person_2_rounded, "Medical Profile"),

          const SizedBox(height: 2),
          Divider(color: theme.brightness == Brightness.dark ? Colors.grey.shade800
                  : Colors.grey.shade200, endIndent: 150),
          const SizedBox(height: 8),

          Text(
            "CHAT HISTORY",
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),

          // History List
          Expanded(child: _buildChatHistoryList()),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.sessionsLoading && chatProvider.chatSessions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          );
        }

        if (chatProvider.chatSessions.isEmpty) {
          return const Center(
            child: Text(
              'No chat history yet',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: chatProvider.chatSessions.length,
          itemBuilder: (context, index) {
            final session = chatProvider.chatSessions[index];
            return ChatHistoryItem(
              session: session,
              onTap: () => _onChatTap(session),
              onLongPress: () => _showChatOptions(session),
            );
          },
        );
      },
    );
  }

  Widget _drawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.brightness == Brightness.dark ? Colors.white54 : const Color.fromARGB(154, 81, 103, 227), size: 22),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}