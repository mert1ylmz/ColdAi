import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide Language;

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';

/// Standalone StatefulWidget for the assistant chat area.
/// This prevents full-page rebuilds when chat state changes.
class AssistantChatWidget extends StatefulWidget {
  final Language lang;

  const AssistantChatWidget({super.key, required this.lang});

  @override
  State<AssistantChatWidget> createState() => _AssistantChatWidgetState();
}

class _AssistantChatWidgetState extends State<AssistantChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  static const String _geminiApiKey = 'AIzaSyAmGL3ZUWydAzxgNEPcmF-1OHktBMMh3i0';
  late final GenerativeModel? _model;
  late final ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: AppTexts.of("assistant_first_message", widget.lang),
        isUser: false,
      ),
    );

    if (_geminiApiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
      );
      _chatSession = _model!.startChat();
    } else {
      _model = null;
      _chatSession = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final lang = widget.lang;
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    if (_chatSession == null) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            _ChatMessage(
              text: AppTexts.of("assistant_api_missing", lang),
              isUser: false,
            ),
          );
        });
        _scrollToBottom();
      }
      return;
    }

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final replyText = response.text ?? "Yanıt alınamadı.";

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(text: replyText, isUser: false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            _ChatMessage(
              text: "${AppTexts.of("error_prefix", lang)}: $e",
              isUser: false,
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppTexts.of("assistant_chat_title", lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppTexts.of("assistant_chat_subtitle", lang),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(minHeight: 160, maxHeight: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fieldFill.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildChatInput(lang),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final lang = widget.lang;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppTexts.of("assistant_typing", lang),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser
                ? const Radius.circular(4)
                : const Radius.circular(20),
            bottomLeft: message.isUser
                ? const Radius.circular(20)
                : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: message.isUser
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: message.isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : AppColors.text,
            fontSize: 14,
            height: 1.45,
            fontWeight: message.isUser ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput(Language lang) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
            decoration: InputDecoration(
              hintText: AppTexts.of("assistant_chat_hint", lang),
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: AppColors.fieldFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton.filled(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}
