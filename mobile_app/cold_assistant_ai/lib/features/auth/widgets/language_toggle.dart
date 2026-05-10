import 'package:flutter/material.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';

class LanguageToggle extends StatelessWidget {
  final Language current;
  final ValueChanged<Language> onChanged;

  const LanguageToggle({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption("TR", current == Language.tr, () => onChanged(Language.tr)),
          _buildOption("EN", current == Language.en, () => onChanged(Language.en)),
        ],
      ),
    );
  }

  Widget _buildOption(String text, bool active, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: active ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : AppColors.textMuted,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
