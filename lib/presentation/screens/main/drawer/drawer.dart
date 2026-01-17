import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medibot/core/constants/api_constants.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/providers/profile/profile_provider.dart';
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
                fontWeight: FontWeight.w600,
              ),
            ),
            content: TextField(
              controller: controller,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade100,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 96, 96, 96),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 96, 96, 96),
                    width: 1.0,
                  ),
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
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this chat? This action cannot be undone.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 13),
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

              _buildUserAvatar(theme),
              SizedBox(width: 12),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  String displayText = 'Guest';
                  if (user != null) {
                    if (user.displayName != null && user.displayName!.isNotEmpty) {
                      displayText = user.displayName!.split(' ').first;
                    } else if (user.email.isNotEmpty) {
                      displayText = user.email.split('@').first;
                    }
                  }
                  return Text(
                    displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                  );
                },
              ),
              const SizedBox(width: 90),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
                icon: Icon(
                  Icons.settings_rounded,
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.white
                          : theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _drawerItem(
            Icons.add_circle_outline_rounded,
            "New Chat",
            onTap: _onNewChat,
          ),
          _drawerItem(Icons.file_upload_rounded, "Upload Medical Report"),
          _drawerItem(Icons.health_and_safety, "BMI Calculator"),

          const SizedBox(height: 2),
          Divider(
            color:
                theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
            endIndent: 150,
          ),
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

  Widget _buildUserAvatar(ThemeData theme) {
    final profilePhotoUrl = context.watch<ProfileProvider>().profilePhotoUrl;
    final authProvider = context.watch<AuthProvider>();
    final fallbackPhotoUrl = authProvider.currentUser?.photoUrl;


    final displayPhotoUrl = (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
      ? profilePhotoUrl
      : (fallbackPhotoUrl != null && fallbackPhotoUrl.isNotEmpty)
        ? fallbackPhotoUrl
        : null;

    final resolvedPhotoUrl = (displayPhotoUrl != null && displayPhotoUrl.isNotEmpty)
      ? ApiConstants.resolveImageUrl(displayPhotoUrl)
      : null;
    // ignore: avoid_print
    print('[Drawer] Resolved photoUrl: $resolvedPhotoUrl');

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 163, 163, 163),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: resolvedPhotoUrl != null
            ? CachedNetworkImage(
                imageUrl: resolvedPhotoUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.person, size: 18, color: Colors.white),
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
      leading: Icon(
        icon,
        color:
            theme.brightness == Brightness.dark
                ? Colors.white54
                : const Color.fromARGB(154, 81, 103, 227),
        size: 22,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
