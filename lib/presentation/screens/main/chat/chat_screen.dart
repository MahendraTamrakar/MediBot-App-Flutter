import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medibot/presentation/screens/main/chat/widgets/chat_pop_menu.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medibot/presentation/screens/main/chat/widgets/animated_gradient.dart';
import 'package:medibot/presentation/screens/main/chat/widgets/chat_app_bar.dart';
import 'package:medibot/data/models/chat/chat_message.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/providers/chat/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback onMenuPressed;

  const ChatScreen({super.key, required this.onMenuPressed});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _drawerOpening = false;
  int _prevMessageCount = 0;
  final ScrollController _scrollController = ScrollController();
  File? _attachedFile;

  @override
  void initState() {
    super.initState();
    // Always start with a new chat on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().newConversation();
      }
    });
  }

  void onDrawerOpen() {
    setState(() {
      _drawerOpening = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _drawerOpening = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty && _attachedFile == null) return;

    final chatProvider = context.read<ChatProvider>();

    // If there's a file attached, handle it
    if (_attachedFile != null) {
      chatProvider.sendMessageWithFile(text, _attachedFile!);
      setState(() => _attachedFile = null);
    } else {
      chatProvider.sendMessage(text);
    }

    _scrollToBottom();
  }

  void _handleFileAttached(File file) {
    setState(() {
      _attachedFile = file;
    });
  }

  void _stopStreaming() {
    context.read<ChatProvider>().stopStreaming();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showRenameDialog(BuildContext context, ChatProvider chatProvider) {
    final controller = TextEditingController(text: 'Current Chat');

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

  void _showDeleteDialog(
    BuildContext context,
    ChatProvider chatProvider,
  ) async {
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
      final sessionId = chatProvider.currentSessionId;
      if (sessionId != null) {
        try {
          await chatProvider.deleteChatSession(sessionId);
          chatProvider.fetchChatSessions(); // Refresh list
          chatProvider.newConversation();
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
      } else {
        chatProvider.newConversation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final hasMessages = chatProvider.hasMessages;
        final currentMessageCount = chatProvider.messages.length;

        // Only auto-scroll when a new message arrives
        if (hasMessages && !_drawerOpening && currentMessageCount > _prevMessageCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
        _prevMessageCount = currentMessageCount;

        return Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: AppBar(
              backgroundColor: const Color.fromARGB(
                0,
                0,
                0,
                0,
              ).withValues(alpha: 0),
              elevation: 0,
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
                    icon: const Icon(Icons.menu_rounded, size: 24),
                    onPressed: () {
                      onDrawerOpen();
                      widget.onMenuPressed();
                    },
                  ),
                ),
              ),
              title: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: const Color.fromARGB(255, 185, 185, 185),
                    width: 0.15,
                  ),
                ),
                child: Text(
                  "MediBot",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              actions:
                  hasMessages
                      ? [
                        // New Chat button
                        Container(
                          margin: const EdgeInsets.only(top: 10),
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
                            icon: const Icon(Icons.add_rounded, size: 24),
                            onPressed: () {
                              chatProvider.newConversation();
                            },
                            tooltip: 'New Chat',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // More options button
                        ChatPopupMenu(
                          chatProvider: chatProvider,
                          onRename: () => _showRenameDialog(context, chatProvider),
                          onDelete: () => _showDeleteDialog(context, chatProvider),
                        ),
                      ]
                      : null,
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;

              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 14),
                child: Column(
                  children: [
                    Expanded(
                      child:
                          hasMessages
                              ? _buildMessageList(theme, chatProvider)
                              : _buildWelcomeScreen(theme),
                    ),

                    if (chatProvider.isTyping)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildShimmerLoader(theme),
                      ),

                    if (chatProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildErrorMessage(chatProvider.errorMessage!),
                      ),

                    Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: ChatInputBar(
                        onSendMessage: _sendMessage,
                        onFileAttached: _handleFileAttached,
                        isStreaming: chatProvider.isTyping,
                        onStopStreaming: _stopStreaming,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LiquidCircularGradient(size: 180),
          const SizedBox(height: 16),
          Text(
            "Hello! I'm MediBot.\n",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontFamily: 'cursive',
            ),
          ),
          Text(
            textAlign: TextAlign.center,
            "I'm here to answer all your\nhealth-related questions.",
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme, ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 80, bottom: 10),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];

        return _buildMessageBubble(message, theme);
      },
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: message.isUser ? 18 : 6,
        bottom: message.isAssistant ? 18 : 6,
        left: 4,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* if (message.isAssistant) ...[
            _buildBotAvatar(theme),
            const SizedBox(width: 8),
          ], */
          Flexible(
            child:
                message.isUser
                    ? _buildUserMessage(message, theme)
                    : _buildBotMessage(message, theme),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage message, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
      ),
    );
  }

  Widget _buildBotMessage(
    ChatMessage message,
    ThemeData theme,
    //bool isStreaming,
  ) {
    // Clean up the message content by removing escape sequences and quotes
    String cleanedContent =
        message.content
            .replaceAll(r'\n', '\n') // Convert literal \n to actual newlines
            .replaceAll(r'\t', '  ') // Convert literal \t to spaces
            .replaceAll('""', '') // Remove empty quotes
            .replaceAll(r'\"', '"') // Convert literal \" to actual quotes
            .trim();

    // Remove quotes at the start and end of the response
    if (cleanedContent.startsWith('"') && cleanedContent.endsWith('"')) {
      cleanedContent = cleanedContent.substring(1, cleanedContent.length - 1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: cleanedContent,
          styleSheet: MarkdownStyleSheet(
            p: theme.textTheme.bodySmall?.copyWith(fontSize: 15, height: 1.5),
            strong: theme.textTheme.bodySmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            h1: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            h2: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            h3: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            listBullet: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
            blockquote: theme.textTheme.bodySmall?.copyWith(
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            code: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontFamily: 'monospace',
              backgroundColor: theme.cardColor,
            ),
          ),
        ),
      ],
    );
  }

  

  /* Widget _buildBotAvatar(ThemeData theme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.medical_services_rounded,
        size: 18,
        color: theme.primaryColor,
      ),
    );
  } */

  Widget _buildUserAvatar(ThemeData theme) {
    final authProvider = context.watch<AuthProvider>();
    final photoUrl = authProvider.currentUser?.photoUrl;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child:
            photoUrl != null && photoUrl.isNotEmpty
                ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.white,
                      ),
                )
                : const Icon(Icons.person, size: 18, color: Colors.white),
      ),
    );
  }

  /* Widget _buildTypingIndicator(ThemeData theme) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              const SizedBox(width: 4),
              _buildDot(1),
              const SizedBox(width: 4),
              _buildDot(2),
            ],
          ),
        ),
      ],
    );
  } */

  Widget _buildShimmerLoader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: theme.cardColor,
            highlightColor: theme.cardColor.withOpacity(0.5),
            child: Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: theme.cardColor,
            highlightColor: theme.cardColor.withOpacity(0.5),
            child: Container(
              height: 16,
              width: double.infinity * 0.85,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: theme.cardColor,
            highlightColor: theme.cardColor.withOpacity(0.5),
            child: Container(
              height: 16,
              width: double.infinity * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* Widget _buildDot(int index) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        final offset = (index * 0.2);
        final animValue = ((value + offset) % 1.0);
        final opacity =
            (animValue < 0.5) ? animValue * 2 : (1.0 - animValue) * 2;

        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  } */

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}