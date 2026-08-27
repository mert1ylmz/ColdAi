import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../models/activity_log_model.dart';
import '../services/activity_log_service.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

enum _RangeFilter { all, today, week, month }

class _ActivityLogPageState extends State<ActivityLogPage> {
  List<ActivityLogModel> _all = [];
  bool _loading = true;
  _RangeFilter _range = _RangeFilter.all;
  ActivityAction? _actionFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await ActivityLogService.instance.getAll();
    setState(() {
      _all = logs;
      _loading = false;
    });
  }

  List<ActivityLogModel> get _filtered {
    final now = DateTime.now();
    return _all.where((e) {
      if (_actionFilter != null && e.action != _actionFilter) return false;
      switch (_range) {
        case _RangeFilter.all:
          return true;
        case _RangeFilter.today:
          return e.timestamp.year == now.year &&
              e.timestamp.month == now.month &&
              e.timestamp.day == now.day;
        case _RangeFilter.week:
          return now.difference(e.timestamp).inDays < 7;
        case _RangeFilter.month:
          return now.difference(e.timestamp).inDays < 31;
      }
    }).toList();
  }

  Map<String, List<ActivityLogModel>> get _grouped {
    final map = <String, List<ActivityLogModel>>{};
    for (final e in _filtered) {
      final key = _dayKey(e.timestamp);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  String _dayKey(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(t.year, t.month, t.day);
    final tr = LanguageController.instance.value == Language.tr;
    final diff = today.difference(d).inDays;
    if (diff == 0) return tr ? "Bugün" : "Today";
    if (diff == 1) return tr ? "Dün" : "Yesterday";
    return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Language>(
      valueListenable: LanguageController.instance.notifier,
      builder: (context, lang, _) {
        final tr = lang == Language.tr;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(tr ? "Aktivite Geçmişi" : "Activity Log"),
            centerTitle: true,
            actions: [
              if (_all.isNotEmpty)
                IconButton(
                  tooltip: tr ? "Temizle" : "Clear",
                  icon: const Icon(Icons.delete_sweep_rounded),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(tr ? "Geçmişi temizle?" : "Clear log?"),
                        content: Text(
                          tr
                              ? "Tüm aktivite kayıtları silinecek."
                              : "All activity records will be deleted.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: Text(tr ? "Vazgeç" : "Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: Text(
                              tr ? "Sil" : "Delete",
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ActivityLogService.instance.clear();
                      _load();
                    }
                  },
                ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFilters(lang),
                    Expanded(child: _buildList(lang)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFilters(Language lang) {
    final tr = lang == Language.tr;
    final ranges = <(_RangeFilter, String)>[
      (_RangeFilter.all, tr ? "Tümü" : "All"),
      (_RangeFilter.today, tr ? "Bugün" : "Today"),
      (_RangeFilter.week, tr ? "Bu hafta" : "This week"),
      (_RangeFilter.month, tr ? "Bu ay" : "This month"),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ranges.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (c, i) {
            final r = ranges[i];
            final selected = _range == r.$1;
            return GestureDetector(
              onTap: () => setState(() => _range = r.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    r.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(Language lang) {
    final tr = lang == Language.tr;
    final groups = _grouped;
    if (groups.isEmpty) {
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
                  color: AppColors.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr ? "Henüz aktivite yok" : "No activity yet",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr
                    ? "Ürün ekledikçe, tükettikçe veya askıya aldıkça burada görünecek."
                    : "Your add/consume/share actions will appear here.",
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
    final keys = groups.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: keys.length,
      itemBuilder: (c, i) {
        final k = keys[i];
        final entries = groups[k]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  k,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              ...entries.map((e) => _entryTile(e, lang)),
            ],
          ),
        );
      },
    );
  }

  Widget _entryTile(ActivityLogModel e, Language lang) {
    final visual = _visualFor(e.action, lang);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: visual.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(visual.icon, color: visual.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.itemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${visual.label}${e.quantity != null && e.quantity!.isNotEmpty ? " · ${e.quantity}" : ""}${e.reason != null && e.reason!.isNotEmpty ? " · ${e.reason}" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) _visualFor(
    ActivityAction a,
    Language lang,
  ) {
    final tr = lang == Language.tr;
    switch (a) {
      case ActivityAction.added:
        return (
          color: AppColors.success,
          icon: Icons.add_circle_rounded,
          label: tr ? "Eklendi" : "Added",
        );
      case ActivityAction.consumed:
        return (
          color: AppColors.primary,
          icon: Icons.restaurant_rounded,
          label: tr ? "Tüketildi" : "Consumed",
        );
      case ActivityAction.partiallyConsumed:
        return (
          color: const Color(0xFF0EA5E9),
          icon: Icons.remove_circle_rounded,
          label: tr ? "Kısmen tüketildi" : "Partially consumed",
        );
      case ActivityAction.wasted:
        return (
          color: AppColors.error,
          icon: Icons.delete_rounded,
          label: tr ? "Atıldı" : "Wasted",
        );
      case ActivityAction.shared:
        return (
          color: const Color(0xFF8B5CF6),
          icon: Icons.volunteer_activism_rounded,
          label: tr ? "Askıya bırakıldı" : "Shared (pending)",
        );
      case ActivityAction.expired:
        return (
          color: const Color(0xFFEA580C),
          icon: Icons.warning_amber_rounded,
          label: tr ? "Süresi geçti" : "Expired",
        );
      case ActivityAction.updated:
        return (
          color: const Color(0xFFCA8A04),
          icon: Icons.edit_rounded,
          label: tr ? "Düzenlendi" : "Updated",
        );
      case ActivityAction.deleted:
        return (
          color: AppColors.textMuted,
          icon: Icons.delete_outline_rounded,
          label: tr ? "Silindi" : "Deleted",
        );
    }
  }
}
