import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide Language;

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/ai_constants.dart';

class SmartSuggestionPage extends StatefulWidget {
  final Language lang;

  const SmartSuggestionPage({super.key, required this.lang});

  @override
  State<SmartSuggestionPage> createState() => _SmartSuggestionPageState();
}

class _SmartSuggestionPageState extends State<SmartSuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMsg> _messages = [];
  bool _isTyping = false;

  late final GenerativeModel? _model;
  late final ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMsg(
      text: widget.lang == Language.tr
          ? "Merhaba! Dolabındaki ürünlere göre sana önerilerde bulunabilirim. Soruyu sor!"
          : "Hello! I can give you suggestions based on your fridge items. Ask away!",
      isUser: false,
    ));

    if (AIConstants.geminiApiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: AIConstants.geminiModel,
        apiKey: AIConstants.geminiApiKey,
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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatMsg(text: text, isUser: true));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    if (_chatSession == null) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMsg(
            text: AppTexts.of("assistant_api_missing", widget.lang),
            isUser: false,
          ));
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
          _messages.add(_ChatMsg(text: replyText, isUser: false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMsg(
            text: "${AppTexts.of("error_prefix", widget.lang)}: $e",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          AppTexts.of("smart_suggestion_page_title", lang),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1F5F9),
              Color(0xFFF8FAFC),
              Color(0xFFF0F9FF),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          physics: const BouncingScrollPhysics(),
          children: [
            // Subtitle
            Text(
              AppTexts.of("smart_suggestion_page_subtitle", lang),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Smart assistant chat
            _buildAssistantSection(lang),
            const SizedBox(height: 24),

            // Recipes section card
            _buildRecipesSection(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantSection(Language lang) {
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
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.of("smart_suggestion_assistant_title", lang),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      AppTexts.of("smart_suggestion_assistant_subtitle", lang),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chat area
          Container(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 350),
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
                  return _buildTypingIndicator(lang);
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

  Widget _buildRecipesSection(Language lang) {
    return GestureDetector(
      onTap: () {
        // Navigate to recipes tab – we'll pop back and user can navigate
        Navigator.pop(context, 'go_recipes');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, Color(0xFF059669)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.of("smart_suggestion_recipes_title", lang),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTexts.of("smart_suggestion_recipes_subtitle", lang),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(Language lang) {
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

  Widget _buildMessageBubble(_ChatMsg message) {
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
              hintText: AppTexts.of("smart_suggestion_assistant_hint", lang),
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

class _ChatMsg {
  final String text;
  final bool isUser;
  const _ChatMsg({required this.text, required this.isUser});
}
