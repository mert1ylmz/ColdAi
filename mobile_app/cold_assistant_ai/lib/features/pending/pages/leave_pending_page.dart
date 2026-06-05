import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../my_fridge/models/fridge_item_model.dart';
import '../models/pending_item_model.dart';
import '../services/pending_repository.dart';

class LeavePendingPage extends StatefulWidget {
  final Language lang;
  final FridgeItemModel? source;

  const LeavePendingPage({super.key, required this.lang, this.source});

  @override
  State<LeavePendingPage> createState() => _LeavePendingPageState();
}

class _LeavePendingPageState extends State<LeavePendingPage> {
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _quantity;
  late final TextEditingController _note;
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    final s = widget.source;
    _name = TextEditingController(text: s?.name ?? '');
    _category = TextEditingController(text: s?.category ?? '');
    _quantity = TextEditingController(text: s?.quantity ?? '');
    _note = TextEditingController(text: s?.note ?? '');
    _location = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _quantity.dispose();
    _note.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tr = widget.lang == Language.tr;
    if (_name.text.trim().isEmpty || _location.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr ? "İsim ve konum zorunlu" : "Name and location required",
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final entry = PendingItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourceItemId: widget.source?.id,
      name: _name.text.trim(),
      category: _category.text.trim(),
      quantity: _quantity.text.trim(),
      note: _note.text.trim(),
      locationLabel: _location.text.trim(),
      expiryDate: widget.source?.expiryDate,
      createdAt: DateTime.now(),
      isMine: true,
    );
    await PendingRepository.instance.insert(entry);
    if (!mounted) return;
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.lang == Language.tr;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(tr ? "Askıya Bırak" : "Share (Pending)"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFFFF7ED)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _heroCard(tr),
            const SizedBox(height: 18),
            _formCard(tr),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.volunteer_activism_rounded),
                label: Text(
                  tr ? "Askıya Bırak" : "Share Now",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(bool tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr ? "Fazlanı paylaş" : "Share your surplus",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr
                      ? "İhtiyacı olana ulaşsın, israfa son."
                      : "Reach someone in need, stop waste.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(bool tr) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _input(_name, tr ? "Ürün adı" : "Product name", Icons.label_rounded),
          const SizedBox(height: 12),
          _input(
            _category,
            tr ? "Kategori" : "Category",
            Icons.category_rounded,
          ),
          const SizedBox(height: 12),
          _input(
            _quantity,
            tr ? "Miktar" : "Quantity",
            Icons.numbers_rounded,
          ),
          const SizedBox(height: 12),
          _input(
            _location,
            tr ? "Alma noktası / mahalle" : "Pickup location / area",
            Icons.location_on_rounded,
          ),
          const SizedBox(height: 12),
          _input(
            _note,
            tr ? "Not (opsiyonel)" : "Note (optional)",
            Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
      ),
    );
  }
}
