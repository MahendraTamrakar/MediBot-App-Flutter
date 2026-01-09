import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final ScrollController _scrollController = ScrollController();
  File? _attachedFile;

  @override
  void initState() {
    super.initState();
    // Always start with a new chat on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().newConversation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Call endChat when leaving screen
    context.read<ChatProvider>().endChat();
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
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final hasMessages = chatProvider.hasMessages;

        // Auto-scroll when new message arrives
        if (hasMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0),
              elevation: 0,
              leading: Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  height: 42,
                  width: 42,
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
                    onPressed: widget.onMenuPressed,
                  ),
                ),
              ),
              title: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
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
                      child: hasMessages
                          ? _buildMessageList(theme, chatProvider)
                          : _buildWelcomeScreen(theme),
                    ),
                    
                    if (chatProvider.isTyping)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildTypingIndicator(theme),
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
        final isStreaming = index == chatProvider.messages.length - 1 && 
                           message.isAssistant && 
                           chatProvider.isStreaming;
        
        return _buildMessageBubble(message, theme, isStreaming);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme, bool isStreaming) {
    return Padding(
      padding: EdgeInsets.only(
        top: message.isUser ? 18 : 6,
        bottom: message.isAssistant ? 18 : 6,
        left: 4,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* if (message.isAssistant) ...[
            _buildBotAvatar(theme),
            const SizedBox(width: 8),
          ], */
          
          Flexible(
            child: message.isUser 
                ? _buildUserMessage(message, theme) 
                : _buildBotMessage(message, theme, isStreaming),
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
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBotMessage(ChatMessage message, ThemeData theme, bool isStreaming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.content,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 15,
            height: 1.5,
          ),
        ),
        
        if (isStreaming)
          Container(
            width: 2,
            height: 16,
            margin: const EdgeInsets.only(top: 4),
            child: _buildBlinkingCursor(theme),
          ),
      ],
    );
  }

  Widget _buildBlinkingCursor(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 530),
      builder: (context, value, child) {
        return Opacity(
          opacity: value < 0.5 ? 1.0 : 0.0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
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
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.person, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
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
  }

  Widget _buildDot(int index) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        final offset = (index * 0.2);
        final animValue = ((value + offset) % 1.0);
        final opacity = (animValue < 0.5) ? animValue * 2 : (1.0 - animValue) * 2;
        
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
  }

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