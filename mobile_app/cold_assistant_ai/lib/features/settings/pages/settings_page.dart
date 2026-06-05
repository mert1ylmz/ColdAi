import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../activity/pages/activity_log_page.dart';

class SettingsPage extends StatefulWidget {
  final Language lang;

  const SettingsPage({super.key, required this.lang});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    final lang = LanguageController.instance.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == Language.tr ? "Çıkış Yap?" : "Sign Out?"),
        content: Text(
          lang == Language.tr
              ? "Hesaptan çıkış yapmak istediğinden emin misin?"
              : "Are you sure you want to sign out?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTexts.of("cancel", lang)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppTexts.of("logout", lang),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Language>(
      valueListenable: LanguageController.instance.notifier,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppTexts.of("settings", lang)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(lang == Language.tr ? "UYGULAMA" : "APPLICATION"),
                const SizedBox(height: 12),
                _LanguageCard(currentLang: lang),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.history_rounded,
                  color: const Color(0xFF8B5CF6),
                  label: lang == Language.tr
                      ? "Aktivite Geçmişi"
                      : "Activity Log",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityLogPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _sectionLabel(lang == Language.tr ? "GÜVENLİK" : "SECURITY"),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.lock_rounded,
                  color: Colors.blue,
                  label: lang == Language.tr
                      ? "Şifreyi Değiştir"
                      : "Change Password",
                  onTap: () => _comingSoon(lang),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  color: Colors.green,
                  label: lang == Language.tr
                      ? "Gizlilik Politikası"
                      : "Privacy Policy",
                  onTap: () => _comingSoon(lang),
                ),
                const SizedBox(height: 24),

                _sectionLabel(lang == Language.tr ? "HAKKINDA" : "ABOUT"),
                const SizedBox(height: 12),
                _VersionCard(lang: lang),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(
                      AppTexts.of("logout", lang),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: AppColors.textMuted,
      letterSpacing: 1.2,
    ),
  );

  void _comingSoon(Language lang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == Language.tr ? "Yakında eklenecek" : "Coming soon",
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language currentLang;
  const _LanguageCard({required this.currentLang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                currentLang == Language.tr ? "Uygulama Dili" : "App Language",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _LangChip(
                  flag: '🇹🇷',
                  label: 'Türkçe',
                  selected: currentLang == Language.tr,
                  onTap: () =>
                      LanguageController.instance.setLanguage(Language.tr),
                ),
                _LangChip(
                  flag: '🇬🇧',
                  label: 'English',
                  selected: currentLang == Language.en,
                  onTap: () =>
                      LanguageController.instance.setLanguage(Language.en),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final Language lang;
  const _VersionCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == Language.tr ? "Sürüm" : "Version",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "1.0.0",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
