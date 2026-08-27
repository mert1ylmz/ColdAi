import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/auth_gate.dart';
import 'core/localization/language.dart';
import 'core/localization/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase başlatma hatası: $e');
  }

  await LanguageController.instance.loadInitial();

  runApp(const ColdAssistantApp());
}

class ColdAssistantApp extends StatelessWidget {
  const ColdAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Language>(
      valueListenable: LanguageController.instance.notifier,
      builder: (context, _, __) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthGate(),
        );
      },
    );
  }
}
