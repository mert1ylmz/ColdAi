import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/pending_item_model.dart';
import '../services/pending_repository.dart';
import '../widgets/pending_card.dart';

class BrowsePendingPage extends StatefulWidget {
  final Language lang;
  const BrowsePendingPage({super.key, required this.lang});

  @override
  State<BrowsePendingPage> createState() => _BrowsePendingPageState();
}

class _BrowsePendingPageState extends State<BrowsePendingPage> {
  List<PendingItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await PendingRepository.instance.seedDemoIfEmpty();
    final items = await PendingRepository.instance.getNearby();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _request(PendingItemModel item) {
    final tr = widget.lang == Language.tr;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr ? "Bu ürünü istiyorum" : "Request this item"),
        content: Text(
          tr
              ? "${item.name} için ${item.locationLabel} konumundaki kişiye talep göndereceksin. Devam edilsin mi?"
              : "Send a request for ${item.name} at ${item.locationLabel}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(tr ? "Vazgeç" : "Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await PendingRepository.instance
                  .updateStatus(item.id, PendingStatus.requested);
              if (mounted) Navigator.pop(c);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr ? "Talep gönderildi" : "Request sent"),
                    backgroundColor: const Color(0xFF8B5CF6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
              _load();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: Text(tr ? "Talep et" : "Request"),
          ),
        ],
      ),
    );
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
        title: Text(tr ? "Yakındaki Askıdakiler" : "Nearby Pending"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    tr ? "Yakında askıda ürün yok" : "No pending items nearby",
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (c, i) {
                    final it = _items[i];
                    return PendingCard(
                      item: it,
                      lang: widget.lang,
                      onTap: it.status == PendingStatus.active
                          ? () => _request(it)
                          : null,
                    );
                  },
                ),
    );
  }
}
