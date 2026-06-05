enum FreshnessStatus { fresh, sealed, opened }

extension FreshnessStatusX on FreshnessStatus {
  String get code {
    switch (this) {
      case FreshnessStatus.fresh:
        return 'fresh';
      case FreshnessStatus.sealed:
        return 'sealed';
      case FreshnessStatus.opened:
        return 'opened';
    }
  }

  static FreshnessStatus fromCode(String? code) {
    switch (code) {
      case 'opened':
        return FreshnessStatus.opened;
      case 'sealed':
        return FreshnessStatus.sealed;
      case 'fresh':
      default:
        return FreshnessStatus.fresh;
    }
  }
}

/// SKT'ye kalan güne göre uyarı seviyesi.
enum ExpiryLevel { fresh, soon, critical, expired }

class FridgeItemModel {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final String note;
  final DateTime createdAt;
  final DateTime expiryDate;

  // Hibrit SKT alanları (opsiyonel — eski kayıtlar için backward compatible).
  final String? categoryKey;
  final FreshnessStatus status;
  final DateTime? productionDate;

  const FridgeItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.note,
    required this.createdAt,
    required this.expiryDate,
    this.categoryKey,
    this.status = FreshnessStatus.fresh,
    this.productionDate,
  });

  int get daysToExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    return exp.difference(today).inDays;
  }

  ExpiryLevel get expiryLevel {
    final d = daysToExpiry;
    if (d < 0) return ExpiryLevel.expired;
    if (d <= 2) return ExpiryLevel.critical;
    if (d <= 6) return ExpiryLevel.soon;
    return ExpiryLevel.fresh;
  }

  FridgeItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    String? note,
    DateTime? createdAt,
    DateTime? expiryDate,
    String? categoryKey,
    FreshnessStatus? status,
    DateTime? productionDate,
  }) {
    return FridgeItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      categoryKey: categoryKey ?? this.categoryKey,
      status: status ?? this.status,
      productionDate: productionDate ?? this.productionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'categoryKey': categoryKey,
      'status': status.code,
      'productionDate': productionDate?.toIso8601String(),
    };
  }

  factory FridgeItemModel.fromMap(Map<String, dynamic> map) {
    return FridgeItemModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'] ?? '',
      note: map['note'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      expiryDate: DateTime.parse(map['expiryDate']),
      categoryKey: map['categoryKey'] as String?,
      status: FreshnessStatusX.fromCode(map['status'] as String?),
      productionDate: map['productionDate'] != null
          ? DateTime.parse(map['productionDate'] as String)
          : null,
    );
  }
}
