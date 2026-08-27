import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'localization/language_controller.dart';
import '../features/auth/pages/auth_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/onboarding/pages/onboarding_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Widget _loading(String msg) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(msg),
        ],
      ),
    ),
  );

  Widget _error(String msg) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.hasError) {
          return _error('Auth error: ${authSnap.error}');
        }

        if (authSnap.connectionState == ConnectionState.waiting) {
          return _loading('Auth kontrol ediliyor...');
        }

        final user = authSnap.data;

        if (user == null) {
          return const AuthPage();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (userSnap.hasError) {
              return _error('Firestore error: ${userSnap.error}');
            }

            if (userSnap.connectionState == ConnectionState.waiting) {
              return _loading('Kullanıcı verisi yükleniyor...');
            }

            final data = userSnap.data?.data();
            final completed = (data?['onboardingCompleted'] as bool?) ?? false;
            final remoteLang = data?['language'] as String?;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              LanguageController.instance.hydrateFromRemote(remoteLang);
            });

            final lang = LanguageController.instance.value;

            if (!completed) {
              return OnboardingPage(lang: lang);
            }

            return HomePage(lang: lang);
          },
        );
      },
    );
  }
}
