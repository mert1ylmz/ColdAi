import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
