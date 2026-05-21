import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final Language lang;

  const ProfilePage({super.key, required this.lang});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late String _email;
  late String _name;
  late String _fridgeType;
  late String _usageArea;
  late String _fridgeSize;
  late String _energyClass;
  late String _brandName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _email = user.email ?? '';
          _name = data['name'] ?? '';
          _fridgeType = data['fridgeType'] ?? 'N/A';
          _usageArea = data['usageArea'] ?? 'N/A';
          _fridgeSize = data['fridgeSize'] ?? 'N/A';
          _energyClass = data['energyClass'] ?? 'N/A';
          _brandName = data['brandName'] ?? 'N/A';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppTexts.of("profile", lang)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF5E5CE6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _name.isNotEmpty ? _name : 'Kullanıcı',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Fridge info section
                  Text(
                    lang == Language.tr
                        ? "BUZDOLABI BİLGİLERİ"
                        : "REFRIGERATOR INFO",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.kitchen_rounded,
                    label: lang == Language.tr ? "Buzdolabı Tipi" : "Fridge Type",
                    value: _translateFridgeInfo(_fridgeType, lang),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    label:
                        lang == Language.tr ? "Kullanım Alanı" : "Usage Area",
                    value: _translateFridgeInfo(_usageArea, lang),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.straighten_rounded,
                    label: lang == Language.tr ? "Buzdolabı Boyutu" : "Size",
                    value: _translateFridgeInfo(_fridgeSize, lang),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.bolt_rounded,
                    label:
                        lang == Language.tr ? "Enerji Sınıfı" : "Energy Class",
                    value: _translateFridgeInfo(_energyClass, lang),
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.business_rounded,
                    label: lang == Language.tr ? "Marka" : "Brand",
                    value: _brandName,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 28),

                  // Account section
                  Text(
                    lang == Language.tr ? "HESAP" : "ACCOUNT",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lang == Language.tr
                                ? "Profil bilgileri ilk açılışta doldurduğunuz verilerden alıyor."
                                : "Profile information is from your initial setup.",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppTexts.of("cancel", widget.lang),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateFridgeInfo(String info, Language lang) {
    final translations = {
      'usage_home': lang == Language.tr ? 'Ev' : 'Home',
      'usage_workplace': lang == Language.tr ? 'İşyeri' : 'Workplace',
      'usage_office': lang == Language.tr ? 'Ofis' : 'Office',
      'usage_store': lang == Language.tr ? 'Mağaza' : 'Store',
      'usage_warehouse': lang == Language.tr ? 'Depo' : 'Warehouse',
      'usage_restaurant': lang == Language.tr ? 'Restoran / Kafe' : 'Restaurant / Cafe',
    };
    return translations[info] ?? info;
  }
}
