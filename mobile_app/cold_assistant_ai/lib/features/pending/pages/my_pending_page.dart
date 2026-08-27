import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../activity/models/activity_log_model.dart';
import '../../activity/services/activity_log_service.dart';
import '../models/pending_item_model.dart';
import '../services/pending_repository.dart';
import '../widgets/pending_card.dart';

class MyPendingPage extends StatefulWidget {
  final Language lang;
  const MyPendingPage({super.key, required this.lang});

  @override
  State<MyPendingPage> createState() => _MyPendingPageState();
}

class _MyPendingPageState extends State<MyPendingPage> {
  List<PendingItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await PendingRepository.instance.getMine();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _changeStatus(PendingItemModel item, PendingStatus s) async {
    await PendingRepository.instance.updateStatus(item.id, s);
    if (s == PendingStatus.completed) {
      await ActivityLogService.instance.log(
        itemId: item.id,
        itemName: item.name,
        action: ActivityAction.shared,
        reason: widget.lang == Language.tr
            ? "Askıdan tamamlandı"
            : "Pending completed",
      );
    }
    _load();
  }

  Future<void> _delete(PendingItemModel item) async {
    await PendingRepository.instance.delete(item.id);
    _load();
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
        title: Text(tr ? "Askıdaki Ürünlerim" : "My Pending Items"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _empty(tr)
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (c, i) {
                    final it = _items[i];
                    return PendingCard(
                      item: it,
                      lang: widget.lang,
                      onTap: () => _showActions(it),
                    );
                  },
                ),
    );
  }

  void _showActions(PendingItemModel item) {
    final tr = widget.lang == Language.tr;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (item.status == PendingStatus.active)
              ListTile(
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                title: Text(tr ? "Tamamlandı olarak işaretle" : "Mark completed"),
                onTap: () {
                  Navigator.pop(c);
                  _changeStatus(item, PendingStatus.completed);
                },
              ),
            if (item.status == PendingStatus.active)
              ListTile(
                leading: const Icon(Icons.close_rounded, color: AppColors.error),
                title: Text(tr ? "İptal et" : "Cancel"),
                onTap: () {
                  Navigator.pop(c);
                  _changeStatus(item, PendingStatus.cancelled);
                },
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textMuted,
              ),
              title: Text(tr ? "Sil" : "Delete"),
              onTap: () {
                Navigator.pop(c);
                _delete(item);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _empty(bool tr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF8B5CF6),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr ? "Henüz askıya bıraktığın bir şey yok" : "Nothing shared yet",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr
                  ? "Dolaptaki bir ürünü uzun bas → \"Askıya bırak\""
                  : "Long-press a fridge item → \"Share (pending)\"",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
