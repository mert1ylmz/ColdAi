import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final bool isLogin;
  final Language lang;

  const AuthHeader({super.key, required this.isLogin, required this.lang});

  @override
  Widget build(BuildContext context) {
    final brand = AppTexts.of("brand", lang);
    final subtitle = isLogin
        ? AppTexts.of("login_hint", lang)
        : AppTexts.of("register_hint", lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo with glow
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Image.asset('assets/images/Logo.png', fit: BoxFit.contain),
        ),

        const SizedBox(height: 28),
        
        Text(
          brand,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 10),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
