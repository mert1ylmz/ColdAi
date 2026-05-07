import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide Language;

import 'package:cold_assistant_ai/core/localization/app_texts.dart';
import 'package:cold_assistant_ai/core/localization/language.dart';
import 'package:cold_assistant_ai/core/theme/app_colors.dart';
import '../../my_fridge/pages/my_fridge_page.dart';

class HomePage extends StatefulWidget {
  final Language lang;

  const HomePage({super.key, required this.lang});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // TODO: Paste your API key here or provide it in the chat
  static const String _geminiApiKey = '[YOUR API KEY]';
  late final GenerativeModel? _model;
  late final ChatSession? _chatSession;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  final ScrollController _chatScrollController = ScrollController();

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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _onMenuSelected(String value) {
    final lang = widget.lang;

    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.of("profile_coming_soon", lang)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.of("settings_coming_soon", lang)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'notifications':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.of("notifications_coming_soon", lang)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'logout':
        _signOut();
        break;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final lang = widget.lang;
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    if (_chatSession == null) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            const _ChatMessage(
              text: "API anahtarı eksik. Lütfen koda ekleyin.",
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

  Widget _buildBody(
    Language lang, {
    required String displayName,
    required String brand,
  }) {
    switch (selectedIndex) {
      case 0:
        return _buildHomeContent(lang, displayName: displayName, brand: brand);
      case 1:
        return Center(
          child: Text(
            AppTexts.of("nav_search", lang),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        );
      case 2:
        return Center(
          child: Text(
            AppTexts.of("nav_recipes", lang),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        );
      case 3:
        return MyFridgePage(lang: lang);
      default:
        return _buildHomeContent(lang, displayName: displayName, brand: brand);
    }
  }

  Widget _buildHomeContent(
    Language lang, {
    required String displayName,
    required String brand,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F5F9), // Slate 100
            Color(0xFFF8FAFC), // Slate 50
            Color(0xFFF0F9FF), // Sky 50
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          physics: const BouncingScrollPhysics(),
          children: [
            _AnimatedHeroCard(lang: lang),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${AppTexts.of("welcome", lang)} $displayName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${AppTexts.of("brand_name", lang)}: $brand',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _AssistantChatCard(
              lang: lang,
              controller: _messageController,
              messages: _messages,
              onSend: _sendMessage,
              isTyping: _isTyping,
              scrollController: _chatScrollController,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.auto_awesome_rounded,
                    title: AppTexts.of("smart_suggestion", lang),
                    subtitle: AppTexts.of("smart_suggestion_subtitle", lang),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.notifications_active_rounded,
                    title: AppTexts.of("reminders", lang),
                    subtitle: AppTexts.of("reminders_subtitle", lang),
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(AppTexts.of("user_not_found", lang))),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                '${AppTexts.of("error_prefix", lang)}: ${snapshot.error}',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() ?? {};
        final name = (data['name'] as String?)?.trim();
        final brand =
            (data['brand'] as String?)?.trim() ??
            (data['fridgeType'] as String?)?.trim() ??
            AppTexts.of("select_option", lang);

        final displayName = (name != null && name.isNotEmpty)
            ? name
            : (user.email ?? 'Kullanıcı');

        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,
          appBar: selectedIndex == 0
              ? AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: false,
                  title: Text(
                    AppTexts.of("app_name", lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      fontSize: 22,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: PopupMenuButton<String>(
                        onSelected: _onMenuSelected,
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        itemBuilder: (context) => [
                          _buildPopupItem(
                            'profile',
                            Icons.person_rounded,
                            AppTexts.of("profile", lang),
                          ),
                          _buildPopupItem(
                            'notifications',
                            Icons.notifications_rounded,
                            AppTexts.of("notifications", lang),
                          ),
                          _buildPopupItem(
                            'settings',
                            Icons.settings_outlined,
                            AppTexts.of("settings", lang),
                          ),
                          const PopupMenuDivider(),
                          _buildPopupItem(
                            'logout',
                            Icons.logout_rounded,
                            AppTexts.of("logout", lang),
                            isDestructive: true,
                          ),
                        ],
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: _buildBody(lang, displayName: displayName, brand: brand),
          bottomNavigationBar: _buildBottomNav(lang),
        );
      },
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? AppColors.error : AppColors.text,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDestructive ? AppColors.error : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Language lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: AppTexts.of("nav_home", lang),
              isSelected: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),
            _NavItem(
              icon: Icons.search_rounded,
              label: AppTexts.of("nav_search", lang),
              isSelected: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),
            _NavItem(
              icon: Icons.receipt_long_rounded,
              label: AppTexts.of("nav_recipes", lang),
              isSelected: selectedIndex == 2,
              onTap: () => setState(() => selectedIndex = 2),
            ),
            _NavItem(
              icon: Icons.kitchen_rounded,
              label: AppTexts.of("nav_my_fridge", lang),
              isSelected: selectedIndex == 3,
              onTap: () => setState(() => selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantChatCard extends StatelessWidget {
  final Language lang;
  final TextEditingController controller;
  final List<_ChatMessage> messages;
  final VoidCallback onSend;
  final bool isTyping;
  final ScrollController scrollController;

  const _AssistantChatCard({
    required this.lang,
    required this.controller,
    required this.messages,
    required this.onSend,
    required this.isTyping,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
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
              controller: scrollController,
              shrinkWrap: true,
              itemCount: messages.length + (isTyping ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return _buildTypingIndicator();
                }

                final message = messages[index];
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
              "Yazıyor...",
              style: TextStyle(
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
            controller: controller,
            minLines: 1,
            maxLines: 4,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
            onPressed: onSend,
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

class _AnimatedHeroCard extends StatefulWidget {
  final Language lang;

  const _AnimatedHeroCard({required this.lang});

  @override
  State<_AnimatedHeroCard> createState() => _AnimatedHeroCardState();
}

class _AnimatedHeroCardState extends State<_AnimatedHeroCard> {
  int sloganIndex = 0;
  Timer? _timer;
  final _random = Random();
  late final List<String> slogans;

  @override
  void initState() {
    super.initState();

    slogans = [
      AppTexts.of("slogan_1", widget.lang),
      AppTexts.of("slogan_2", widget.lang),
      AppTexts.of("slogan_3", widget.lang),
      AppTexts.of("slogan_4", widget.lang),
      AppTexts.of("slogan_5", widget.lang),
      AppTexts.of("slogan_6", widget.lang),
      AppTexts.of("slogan_7", widget.lang),
      AppTexts.of("slogan_8", widget.lang),
      AppTexts.of("slogan_9", widget.lang),
      AppTexts.of("slogan_10", widget.lang),
      AppTexts.of("slogan_11", widget.lang),
    ];

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || slogans.length < 2) return;

      setState(() {
        int newIndex = sloganIndex;
        while (newIndex == sloganIndex) {
          newIndex = _random.nextInt(slogans.length);
        }
        sloganIndex = newIndex;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF4F46E5)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  AppTexts.of("app_name", widget.lang).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 84,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Align(
                  key: ValueKey('$sloganIndex-${slogans[sloganIndex]}'),
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    slogans[sloganIndex],
                    maxLines: 2,
                    minFontSize: 18,
                    maxFontSize: 24,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
