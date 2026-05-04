import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
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
  Language lang = Language.tr;
  final _auth = AuthService();

  void toggleMode() => setState(() => isLogin = !isLogin);
  void setLang(Language v) => setState(() => lang = v);
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Sağ üst dil seçimi
            Positioned(
              top: 12,
              right: 12,
              child: LanguageToggle(current: lang, onChanged: setLang),
            ),

            // İçerik
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(isLogin: isLogin, lang: lang),
                      const SizedBox(height: 18),

                      // Kart
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 24,
                              offset: Offset(0, 12),
                              color: Color(0x14000000),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) {
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.03),
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
                                      // başarılı giriş -> birazdan AuthGate ile yönlendireceğiz
                                    } on Exception catch (e) {
                                      _showError(e.toString());
                                    }
                                  },
                                )
                              : RegisterForm(
                                  key: const ValueKey("register"),
                                  lang: lang,
                                  onSubmit:
                                      (
                                        name,
                                        email,
                                        password,
                                        confirmPassword,
                                      ) async {
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

                                          await UserRepository()
                                              .createUserIfNotExists(
                                                uid: cred.user!.uid,
                                                name: name,
                                                email: email,
                                                language: lang == Language.tr
                                                    ? 'tr'
                                                    : 'en',
                                              );
                                        } on Exception catch (e) {
                                          _showError(e.toString());
                                        }
                                      },
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Alt geçiş metni
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin
                                ? AppTexts.of("no_account", lang)
                                : AppTexts.of("have_account", lang),
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: toggleMode,
                            child: Text(
                              isLogin
                                  ? AppTexts.of("go_register", lang)
                                  : AppTexts.of("go_login", lang),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
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
    );
  }
}
