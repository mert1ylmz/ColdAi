import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language.dart';

class LanguageController {
  LanguageController._();
  static final LanguageController instance = LanguageController._();

  static const _prefsKey = 'app_language';

  final ValueNotifier<Language> notifier = ValueNotifier<Language>(Language.tr);

  Language get value => notifier.value;

  Future<void> loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      notifier.value = _fromCode(stored);
    }
  }

  Future<void> setLanguage(Language lang, {bool writeRemote = true}) async {
    if (notifier.value == lang && !writeRemote) return;
    notifier.value = lang;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _toCode(lang));

    if (writeRemote) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'language': _toCode(lang)}, SetOptions(merge: true));
        } catch (_) {
          // offline / yetki sorunları; lokal değer korunur.
        }
      }
    }
  }

  /// Firestore'dan gelen dili lokale uygula (yalnızca farklıysa).
  Future<void> hydrateFromRemote(String? code) async {
    if (code == null) return;
    final remote = _fromCode(code);
    if (remote != notifier.value) {
      await setLanguage(remote, writeRemote: false);
    }
  }

  static String _toCode(Language lang) => lang == Language.tr ? 'tr' : 'en';
  static Language _fromCode(String code) =>
      code.toLowerCase() == 'en' ? Language.en : Language.tr;
}
