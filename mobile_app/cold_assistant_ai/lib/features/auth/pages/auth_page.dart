import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_header.dart';
import '../widgets/language_toggle.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_repository.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  Language lang = LanguageController.instance.value;
  final _auth = AuthService();

  void toggleMode() => setState(() => isLogin = !isLogin);
  void setLang(Language v) {
    setState(() => lang = v);
    LanguageController.instance.setLanguage(v);
  }
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF2FF), // Indigo 50
              Color(0xFFF8FAFC), // Slate 50
              Color(0xFFF0FDFA), // Emerald 50
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Dil Seçimi
              Positioned(
                top: 16,
                right: 16,
                child: LanguageToggle(current: lang, onChanged: setLang),
              ),

              // İçerik
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthHeader(isLogin: isLogin, lang: lang),
                        const SizedBox(height: 32),

                        // Kart
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                                color: const Color(0xFF6366F1).withOpacity(0.08),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutQuart,
                            switchOutCurve: Curves.easeInQuart,
                            transitionBuilder: (child, anim) {
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              );
                            },
                            child: isLogin
                                ? LoginForm(
                                    key: const ValueKey("login"),
                                    lang: lang,
                                    onSubmit: (email, password) async {
                                      try {
                                        await _auth.signIn(
                                          email: email,
                                          password: password,
                                        );
                                      } on Exception catch (e) {
                                        _showError(e.toString());
                                      }
                                    },
                                  )
                                : RegisterForm(
                                    key: const ValueKey("register"),
                                    lang: lang,
                                    onSubmit: (name, email, password, confirmPassword) async {
                                      if (password != confirmPassword) {
                                        _showError(
                                          lang == Language.tr
                                              ? "Şifreler eşleşmiyor"
                                              : "Passwords do not match",
                                        );
                                        return;
                                      }
                                      try {
                                        final cred = await _auth.signUp(
                                          email: email,
                                          password: password,
                                        );
                                        await UserRepository().createUserIfNotExists(
                                          uid: cred.user!.uid,
                                          name: name,
                                          email: email,
                                          language: lang == Language.tr ? 'tr' : 'en',
                                        );
                                      } on Exception catch (e) {
                                        _showError(e.toString());
                                      }
                                    },
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Alt geçiş metni
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? AppTexts.of("no_account", lang)
                                  : AppTexts.of("have_account", lang),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: toggleMode,
                              child: Text(
                                isLogin
                                    ? AppTexts.of("go_register", lang)
                                    : AppTexts.of("go_login", lang),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
