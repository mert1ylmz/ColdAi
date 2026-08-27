import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExists({
    required String uid,
    required String name,
    required String email,
    required String language,
  }) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'name': name,
        'email': email,
        'language': language,
        'onboardingCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> isOnboardingCompleted(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data()?['onboardingCompleted'] == true;
  }

  Future<void> completeOnboarding(String uid) {
    return _db.collection('users').doc(uid).update({
      'onboardingCompleted': true,
    });
  }
}
