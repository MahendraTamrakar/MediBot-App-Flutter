import 'package:flutter/material.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/providers/chat/chat_provider.dart';
import 'package:medibot/presentation/screens/settings/widgets/setting_card.dart';
import 'package:medibot/presentation/screens/settings/widgets/setting_tile.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:provider/provider.dart';

class DataControlScreen extends StatelessWidget {
  const DataControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Data controls',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Center(
            child: Container(
              margin: const EdgeInsets.only(left: 10, top: 10),
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
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          SettingCard(
            children: [
              SettingTile(
                icon: Icons.cleaning_services_rounded,
                title: 'Clear All Chat History',
                label: 'Permanently remove all your conversation history',
                onTap: () async {
                  final confirmed = await _showConfirmDialog(
                    context: context,
                    title: 'Clear All Chat History',
                    message:
                        'Are you sure you want to clear all your chat history? This cannot be undone.',
                    confirmText: 'Clear',
                  );

                  if (confirmed == true && context.mounted) {
                    await _clearAllChats(context);
                  }
                },
              ),
              
              // ════════════════════════════════════════════════════════════════
              // DELETE ACCOUNT
              // ════════════════════════════════════════════════════════════════
              
              SettingTile(
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                label:
                    'Permanently delete your account and all your associated data',
                onTap: () async {
                  final confirmed = await _showConfirmDialog(
                    context: context,
                    title: 'Delete Account',
                    message:
                        'Are you sure you want to delete your account? This cannot be undone.',
                    confirmText: 'Delete',
                    isDangerous: true,
                  );

                  if (confirmed == true && context.mounted) {
                    await _deleteAccount(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEAR ALL CHATS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _clearAllChats(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get ChatProvider
      final chatProvider = context.read<ChatProvider>();

      // Delete all chats (this calls your ChatRepository.deleteAllChats())
      // You need to add this method to ChatProvider
        await chatProvider.deleteAllChats();
        // Refresh chat history after deletion
        await chatProvider.fetchChatSessions();

      // Hide loading
      if (context.mounted) Navigator.pop(context);

      // Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All chat history cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) Navigator.pop(context);

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear chat history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE ACCOUNT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _deleteAccount(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get AuthProvider
      final authProvider = context.read<AuthProvider>();

      // Delete account
      await authProvider.deleteAccount();

      // Hide loading
      if (context.mounted) Navigator.pop(context);

      // Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to sign in and clear stack
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signIn,
          (route) => false,
        );
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) Navigator.pop(context);

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONFIRMATION DIALOG
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}