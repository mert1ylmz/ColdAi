import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide Language;

import 'package:cold_assistant_ai/core/localization/app_texts.dart';
import 'package:cold_assistant_ai/core/localization/language.dart';
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
      _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);
      _chatSession = _model!.startChat();
    } else {
      _model = null;
      _chatSession = null;
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onMenuSelected(String value) {
    final lang = widget.lang;

    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.of("profile_coming_soon", lang))),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.of("settings_coming_soon", lang))),
        );
        break;
      case 'notifications':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.of("notifications_coming_soon", lang)),
          ),
        );
        break;
      case 'logout':
        _signOut();
        break;
    }
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

    if (_chatSession == null) {
      // API Key is empty, show a warning
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            _ChatMessage(
              text: "API anahtarı eksik. Lütfen geliştiriciye API anahtarını verin veya koda ekleyin.",
              isUser: false,
            ),
          );
        });
      }
      return;
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      final replyText = response.text ?? "Yanıt alınamadı.";
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(text: replyText, isUser: false));
        });
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
          colors: [Color(0xFFEAF4FF), Color(0xFFF8FBFF), Color(0xFFEFFAF6)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            _AnimatedHeroCard(lang: lang),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${AppTexts.of("welcome", lang)} $displayName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppTexts.of("brand_name", lang)}: $brand',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _AssistantChatCard(
              lang: lang,
              controller: _messageController,
              messages: _messages,
              onSend: _sendMessage,
              isTyping: _isTyping,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.auto_awesome,
                    title: AppTexts.of("smart_suggestion", lang),
                    subtitle: AppTexts.of("smart_suggestion_subtitle", lang),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.notifications_active_outlined,
                    title: AppTexts.of("reminders", lang),
                    subtitle: AppTexts.of("reminders_subtitle", lang),
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
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
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: selectedIndex == 0
              ? AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    AppTexts.of("app_name", lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: PopupMenuButton<String>(
                        onSelected: _onMenuSelected,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Text(AppTexts.of("profile", lang)),
                          ),
                          PopupMenuItem(
                            value: 'notifications',
                            child: Text(AppTexts.of("notifications", lang)),
                          ),
                          PopupMenuItem(
                            value: 'settings',
                            child: Text(AppTexts.of("settings", lang)),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            child: Text(AppTexts.of("logout", lang)),
                          ),
                        ],
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF60A5FA), Color(0xFF34D399)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: _buildBody(lang, displayName: displayName, brand: brand),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                    icon: Icons.receipt_long_outlined,
                    label: AppTexts.of("nav_recipes", lang),
                    isSelected: selectedIndex == 2,
                    onTap: () => setState(() => selectedIndex = 2),
                  ),
                  _NavItem(
                    icon: Icons.kitchen_outlined,
                    label: AppTexts.of("nav_my_fridge", lang),
                    isSelected: selectedIndex == 3,
                    onTap: () => setState(() => selectedIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AssistantChatCard extends StatelessWidget {
  final Language lang;
  final TextEditingController controller;
  final List<_ChatMessage> messages;
  final VoidCallback onSend;
  final bool isTyping;

  const _AssistantChatCard({
    required this.lang,
    required this.controller,
    required this.messages,
    required this.onSend,
    required this.isTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined, color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Text(
                AppTexts.of("assistant_chat_title", lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppTexts.of("assistant_chat_subtitle", lang),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 240),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: messages.length + (isTyping ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text("Yazıyor...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                final message = messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: message.isUser
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : const Color(0xFF0F172A),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppTexts.of("assistant_chat_hint", lang),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onSend,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                    ),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.18),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.of("app_name", widget.lang),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.10),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: Align(
                  key: ValueKey('$sloganIndex-${slogans[sloganIndex]}'),
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: double.infinity,
                    child: AutoSizeText(
                      slogans[sloganIndex],
                      maxLines: 2,
                      minFontSize: 16,
                      maxFontSize: 22,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
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

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.5,
              height: 1.35,
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
    final activeColor = const Color(0xFF2563EB);
    final normalColor = const Color(0xFF64748B);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : normalColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : normalColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
