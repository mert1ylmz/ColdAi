class FridgeItemModel {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final String note;
  final DateTime createdAt;
  final DateTime expiryDate;

  const FridgeItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.note,
    required this.createdAt,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory FridgeItemModel.fromMap(Map<String, dynamic> map) {
    return FridgeItemModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
      expiryDate: DateTime.parse(map['expiryDate']),
    );
  }
}
