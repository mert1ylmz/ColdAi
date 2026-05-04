import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';

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
      DropdownMenuItem(
        value: 'home',
        child: Text(AppTexts.of("usage_home", lang)),
      ),
      DropdownMenuItem(
        value: 'workplace',
        child: Text(AppTexts.of("usage_workplace", lang)),
      ),
      DropdownMenuItem(
        value: 'office',
        child: Text(AppTexts.of("usage_office", lang)),
      ),
      DropdownMenuItem(
        value: 'store',
        child: Text(AppTexts.of("usage_store", lang)),
      ),
      DropdownMenuItem(
        value: 'warehouse',
        child: Text(AppTexts.of("usage_warehouse", lang)),
      ),
      DropdownMenuItem(
        value: 'restaurant',
        child: Text(AppTexts.of("usage_restaurant", lang)),
      ),
      DropdownMenuItem(
        value: 'other',
        child: Text(AppTexts.of("usage_other", lang)),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _buildEnergyClassItems() {
    const values = ['A+++', 'A++', 'A+', 'A', 'B', 'C'];

    return values
        .map(
          (value) => DropdownMenuItem<String>(value: value, child: Text(value)),
        )
        .toList();
  }

  Future<void> completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final lang = widget.lang;
    final brand = brandController.text.trim();

    if (brand.isEmpty ||
        selectedUsageArea == null ||
        selectedEnergyClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.of("fill_all_fields", lang))),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'usageArea': selectedUsageArea,
        'energyClass': selectedEnergyClass,
        'brand': brand,
        'onboardingCompleted': true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.of("onboarding_done", lang))),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppTexts.of("error_prefix", lang)}$e')),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
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
      appBar: AppBar(
        title: Text(AppTexts.of("onboarding_title", lang)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedUsageArea,
              items: _buildUsageAreaItems(lang),
              decoration: InputDecoration(
                labelText: AppTexts.of("usage_area", lang),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  selectedUsageArea = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedEnergyClass,
              items: _buildEnergyClassItems(),
              decoration: InputDecoration(
                labelText: AppTexts.of("energy_class", lang),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  selectedEnergyClass = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: brandController,
              decoration: InputDecoration(
                labelText: AppTexts.of("brand_name", lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : completeOnboarding,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppTexts.of("continue", lang)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
