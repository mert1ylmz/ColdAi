import '../../../core/services/database_service.dart';
import '../models/activity_log_model.dart';

class ActivityLogService {
  static final ActivityLogService instance = ActivityLogService._();
  ActivityLogService._();

  Future<void> log({
    required String itemId,
    required String itemName,
    required ActivityAction action,
    String? quantity,
    String? reason,
  }) async {
    final db = await DatabaseService().database;
    final entry = ActivityLogModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      itemId: itemId,
      itemName: itemName,
      action: action,
      quantity: quantity,
      reason: reason,
      timestamp: DateTime.now(),
    );
    await db.insert('activity_log', entry.toMap());
  }

  Future<List<ActivityLogModel>> getAll({int limit = 500}) async {
    final db = await DatabaseService().database;
    final rows = await db.query(
      'activity_log',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(ActivityLogModel.fromMap).toList();
  }

  Future<void> clear() async {
    final db = await DatabaseService().database;
    await db.delete('activity_log');
  }
}
