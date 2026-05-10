import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  final Language lang;

  const OnboardingPage({super.key, required this.lang});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController brandController = TextEditingController();

  String? selectedUsageArea;
  String? selectedEnergyClass;

  bool isLoading = false;

  List<DropdownMenuItem<String>> _buildUsageAreaItems(Language lang) {
    return [
      DropdownMenuItem(value: 'home', child: Text(AppTexts.of("usage_home", lang))),
      DropdownMenuItem(value: 'workplace', child: Text(AppTexts.of("usage_workplace", lang))),
      DropdownMenuItem(value: 'office', child: Text(AppTexts.of("usage_office", lang))),
      DropdownMenuItem(value: 'store', child: Text(AppTexts.of("usage_store", lang))),
      DropdownMenuItem(value: 'warehouse', child: Text(AppTexts.of("usage_warehouse", lang))),
      DropdownMenuItem(value: 'restaurant', child: Text(AppTexts.of("usage_restaurant", lang))),
    ];
  }

  List<DropdownMenuItem<String>> _buildEnergyClassItems() {
    const values = ['A+++', 'A++', 'A+', 'A', 'B', 'C'];
    return values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList();
  }

  Future<void> completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final lang = widget.lang;
    final brand = brandController.text.trim();

    if (brand.isEmpty || selectedUsageArea == null || selectedEnergyClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.of("fill_all_fields", lang)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'usageArea': selectedUsageArea,
        'energyClass': selectedEnergyClass,
        'brand': brand,
        'onboardingCompleted': true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.of("onboarding_done", lang)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppTexts.of("error_prefix", lang)}: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F5F9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(lang),
                const SizedBox(height: 40),
                _buildForm(lang),
                const SizedBox(height: 40),
                _buildButton(lang),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Language lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.kitchen_rounded, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          AppTexts.of("onboarding_title", lang),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppTexts.of("onboarding_subtitle", lang),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(Language lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDropdown(
            label: AppTexts.of("usage_area", lang),
            value: selectedUsageArea,
            items: _buildUsageAreaItems(lang),
            onChanged: (v) => setState(() => selectedUsageArea = v),
            icon: Icons.place_rounded,
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: AppTexts.of("energy_class", lang),
            value: selectedEnergyClass,
            items: _buildEnergyClassItems(),
            onChanged: (v) => setState(() => selectedEnergyClass = v),
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: AppTexts.of("brand_name", lang),
            controller: brandController,
            icon: Icons.branding_watermark_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            filled: true,
            fillColor: AppColors.fieldFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            filled: true,
            fillColor: AppColors.fieldFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: label,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(Language lang) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : completeOnboarding,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  AppTexts.of("continue", lang),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
        ),
      ),
    );
  }
}
