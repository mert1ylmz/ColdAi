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
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/images/Logo.png', fit: BoxFit.contain),
          ),
        ),

        const SizedBox(height: 14),
        Text(
          brand,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.muted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
