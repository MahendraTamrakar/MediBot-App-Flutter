import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Bottom chat input bar extracted for reuse.
class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File)? onFileAttached;
  final bool isStreaming;  // ← New: Check if bot is streaming
  final VoidCallback onStopStreaming;  // ← New: Stop streaming callback

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.onFileAttached,
    this.isStreaming = false,
    required this.onStopStreaming,
  });

  static const Color pillColor = Color(0xFF2A2B2E);

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _speechAvailable = false;
  File? _attachedFile;
  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _micAnimationController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        final isImage = _isImageFile(fileName);
        
        setState(() {
          _attachedFile = file;
        });
        
        // Notify parent about the attached file
        widget.onFileAttached?.call(file);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isImage ? 'Image' : 'PDF'} attached: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  void _removeAttachment() {
    setState(() {
      _attachedFile = null;
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFile == null) return;

    widget.onSendMessage(text);
    _controller.clear();
    _removeAttachment();
    
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show attached file indicator
        if (_attachedFile != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8, left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 20,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _attachedFile!.path.split('/').last,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _removeAttachment,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        
        // Input row
        Row(
          children: [
            GestureDetector(
              onLongPress: _attachedFile != null ? _removeAttachment : null,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
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
                  onPressed: _pickFile,
                  icon: Icon(
                    _attachedFile != null 
                        ? Icons.picture_as_pdf_rounded 
                        : Icons.attach_file_rounded, 
                    size: 24,
                    color: _attachedFile != null 
                        ? theme.primaryColor 
                        : theme.iconTheme.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
            enabled: !widget.isStreaming,  // ← Disable while streaming
            decoration: InputDecoration(
              hintText: widget.isStreaming 
                  ? 'Generating response...'
                  : (_isListening ? 'Listening...' : 'Ask Medibot'),
              hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
              filled: true,
              fillColor: theme.cardColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 193, 193, 193),
                  width: 0.15,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 193, 193, 193),
                  width: 0.15,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 193, 193, 193),
                  width: 0.15,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 193, 193, 193),
                  width: 0.15,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Microphone button
                  if (!widget.isStreaming)
                    GestureDetector(
                      onTap: _toggleListening,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isListening 
                              ? const Color.fromARGB(255, 137, 129, 219) 
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: _isListening
                            ? _buildListeningAnimation()
                            : Icon(
                                Icons.mic_rounded,
                                size: 24,
                                color: theme.iconTheme.color,
                              ),
                      ),
                    ),
                  const SizedBox(width: 5),
                  // Send or Stop button
                  Container(
                    height: 36,
                    width: 36,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: widget.isStreaming 
                          ? Colors.red 
                          : theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.isStreaming 
                          ? widget.onStopStreaming  // ← Stop streaming
                          : _sendMessage,  // ← Send message
                      icon: Icon(
                        widget.isStreaming 
                            ? Icons.stop_rounded 
                            : Icons.arrow_upward_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),  // Close Row
    ],  // Close Column children
    );  // Close Column
  }

  Widget _buildListeningAnimation() {
    return AnimatedBuilder(
      animation: _micAnimationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36 * (1.0 + _micAnimationController.value * 0.3),
              height: 36 * (1.0 + _micAnimationController.value * 0.3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  0.3 * (1.0 - _micAnimationController.value),
                ),
              ),
            ),
            Container(
              width: 36 * (1.0 + _micAnimationController.value * 0.15),
              height: 36 * (1.0 + _micAnimationController.value * 0.15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  0.5 * (1.0 - _micAnimationController.value),
                ),
              ),
            ),
            const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        );
      },
    );
  }
}