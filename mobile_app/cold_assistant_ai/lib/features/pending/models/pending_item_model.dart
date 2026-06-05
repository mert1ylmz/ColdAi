enum PendingStatus { active, requested, completed, cancelled }

extension PendingStatusX on PendingStatus {
  String get code {
    switch (this) {
      case PendingStatus.active:
        return 'active';
      case PendingStatus.requested:
        return 'requested';
      case PendingStatus.completed:
        return 'completed';
      case PendingStatus.cancelled:
        return 'cancelled';
    }
  }

  static PendingStatus fromCode(String? c) {
    switch (c) {
      case 'requested':
        return PendingStatus.requested;
      case 'completed':
        return PendingStatus.completed;
      case 'cancelled':
        return PendingStatus.cancelled;
      case 'active':
      default:
        return PendingStatus.active;
    }
  }
}

class PendingItemModel {
  final String id;
  final String? sourceItemId;
  final String name;
  final String category;
  final String quantity;
  final String note;
  final String locationLabel;
  final DateTime? expiryDate;
  final PendingStatus status;
  final DateTime createdAt;
  final bool isMine;

  const PendingItemModel({
    required this.id,
    this.sourceItemId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.note,
    required this.locationLabel,
    this.expiryDate,
    this.status = PendingStatus.active,
    required this.createdAt,
    this.isMine = true,
  });

  PendingItemModel copyWith({
    PendingStatus? status,
    String? note,
    String? locationLabel,
  }) {
    return PendingItemModel(
      id: id,
      sourceItemId: sourceItemId,
      name: name,
      category: category,
      quantity: quantity,
      note: note ?? this.note,
      locationLabel: locationLabel ?? this.locationLabel,
      expiryDate: expiryDate,
      status: status ?? this.status,
      createdAt: createdAt,
      isMine: isMine,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'sourceItemId': sourceItemId,
    'name': name,
    'category': category,
    'quantity': quantity,
    'note': note,
    'locationLabel': locationLabel,
    'expiryDate': expiryDate?.toIso8601String(),
    'status': status.code,
    'createdAt': createdAt.toIso8601String(),
    'isMine': isMine ? 1 : 0,
  };

  factory PendingItemModel.fromMap(Map<String, dynamic> map) =>
      PendingItemModel(
        id: map['id'],
        sourceItemId: map['sourceItemId'] as String?,
        name: map['name'] ?? '',
        category: map['category'] ?? '',
        quantity: map['quantity'] ?? '',
        note: map['note'] ?? '',
        locationLabel: map['locationLabel'] ?? '',
        expiryDate: map['expiryDate'] != null
            ? DateTime.parse(map['expiryDate'])
            : null,
        status: PendingStatusX.fromCode(map['status'] as String?),
        createdAt: DateTime.parse(map['createdAt']),
        isMine: (map['isMine'] ?? 1) == 1,
      );
}
