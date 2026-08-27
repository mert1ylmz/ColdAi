class DetectedProductModel {
  final String name;
  final String category;
  final DateTime createdAt;
  final DateTime expiryDate;

  const DetectedProductModel({
    required this.name,
    required this.category,
    required this.createdAt,
    required this.expiryDate,
  });
}
