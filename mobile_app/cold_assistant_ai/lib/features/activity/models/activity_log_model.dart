enum ActivityAction { added, consumed, partiallyConsumed, wasted, shared, expired, updated, deleted }

extension ActivityActionX on ActivityAction {
  String get code {
    switch (this) {
      case ActivityAction.added:
        return 'added';
      case ActivityAction.consumed:
        return 'consumed';
      case ActivityAction.partiallyConsumed:
        return 'partially_consumed';
      case ActivityAction.wasted:
        return 'wasted';
      case ActivityAction.shared:
        return 'shared';
      case ActivityAction.expired:
        return 'expired';
      case ActivityAction.updated:
        return 'updated';
      case ActivityAction.deleted:
        return 'deleted';
    }
  }

  static ActivityAction fromCode(String? code) {
    switch (code) {
      case 'consumed':
        return ActivityAction.consumed;
      case 'partially_consumed':
        return ActivityAction.partiallyConsumed;
      case 'wasted':
        return ActivityAction.wasted;
      case 'shared':
        return ActivityAction.shared;
      case 'expired':
        return ActivityAction.expired;
      case 'updated':
        return ActivityAction.updated;
      case 'deleted':
        return ActivityAction.deleted;
      case 'added':
      default:
        return ActivityAction.added;
    }
  }
}

class ActivityLogModel {
  final String id;
  final String itemId;
  final String itemName;
  final ActivityAction action;
  final String? quantity;
  final String? reason;
  final DateTime timestamp;

  const ActivityLogModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.action,
    this.quantity,
    this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemId': itemId,
    'itemName': itemName,
    'action': action.code,
    'quantity': quantity,
    'reason': reason,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) =>
      ActivityLogModel(
        id: map['id'],
        itemId: map['itemId'] ?? '',
        itemName: map['itemName'] ?? '',
        action: ActivityActionX.fromCode(map['action'] as String?),
        quantity: map['quantity'] as String?,
        reason: map['reason'] as String?,
        timestamp: DateTime.parse(map['timestamp']),
      );
}
