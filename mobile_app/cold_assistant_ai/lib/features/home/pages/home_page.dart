import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cold_assistant_ai/core/localization/app_texts.dart';
import 'package:cold_assistant_ai/core/localization/language.dart';
import 'package:cold_assistant_ai/core/theme/app_colors.dart';
import '../../my_fridge/pages/my_fridge_page.dart';
import '../../recipes/pages/recipes_page.dart';
import '../../pending/pages/pending_page.dart';
import '../widgets/assistant_chat_widget.dart';
import '../widgets/expiry_reminder_card.dart';
import 'smart_suggestion_page.dart';

class HomePage extends StatefulWidget {
  final Language lang;

  const HomePage({super.key, required this.lang});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
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

  Widget _buildBody(
    Language lang, {
    required String displayName,
    required String brand,
  }) {
    switch (selectedIndex) {
      case 0:
        return _buildHomeContent(lang, displayName: displayName, brand: brand);
      case 1:
        return PendingPage(lang: lang);
      case 2:
        return RecipesPage(lang: lang);
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

            // Expiry Reminder Card (enlarged, right after welcome)
            ExpiryReminderCard(lang: lang),

            const SizedBox(height: 24),

            // Assistant Chat Widget (separate StatefulWidget – no full rebuild)
            AssistantChatWidget(lang: lang),

            const SizedBox(height: 24),

            // Smart Suggestion Card (tappable)
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SmartSuggestionPage(lang: lang),
                  ),
                );
                if (result == 'go_recipes') {
                  setState(() {
                    selectedIndex = 2;
                  });
                }
              },
              child: _InfoCard(
                icon: Icons.auto_awesome_rounded,
                title: AppTexts.of("smart_suggestion", lang),
                subtitle: AppTexts.of("smart_suggestion_subtitle", lang),
                color: AppColors.primary,
                isFullWidth: true,
              ),
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
              icon: Icons.volunteer_activism_rounded,
              label: AppTexts.of("nav_pending", lang),
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
  final bool isFullWidth;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isFullWidth ? null : 160,
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
      child: isFullWidth
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.border,
                ),
              ],
            )
          : Column(
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
