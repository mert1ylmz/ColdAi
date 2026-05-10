import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/local_ai_service.dart';
import 'core/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase başlatma hatası: $e');
  }

  try {
    // Local AI Model'lerini önceden yükle
    await LocalAIService().loadModels();
  } catch (e) {
    debugPrint('Model yükleme hatası: $e');
  }

  runApp(const ColdAssistantApp());
}

class ColdAssistantApp extends StatelessWidget {
  const ColdAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
