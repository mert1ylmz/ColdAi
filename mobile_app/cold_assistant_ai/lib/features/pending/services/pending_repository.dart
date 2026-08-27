import '../../../core/services/database_service.dart';
import '../models/pending_item_model.dart';

class PendingRepository {
  static final PendingRepository instance = PendingRepository._();
  PendingRepository._();

  Future<void> insert(PendingItemModel item) async {
    final db = await DatabaseService().database;
    await db.insert('pending_items', item.toMap());
  }

  Future<List<PendingItemModel>> getMine() async {
    final db = await DatabaseService().database;
    final rows = await db.query(
      'pending_items',
      where: 'isMine = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return rows.map(PendingItemModel.fromMap).toList();
  }

  Future<List<PendingItemModel>> getNearby() async {
    final db = await DatabaseService().database;
    final rows = await db.query(
      'pending_items',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'createdAt DESC',
    );
    return rows.map(PendingItemModel.fromMap).toList();
  }

  Future<void> updateStatus(String id, PendingStatus status) async {
    final db = await DatabaseService().database;
    await db.update(
      'pending_items',
      {'status': status.code},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService().database;
    await db.delete('pending_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> seedDemoIfEmpty() async {
    final db = await DatabaseService().database;
    final mine = await db.query(
      'pending_items',
      where: 'isMine = ?',
      whereArgs: [0],
      limit: 1,
    );
    if (mine.isNotEmpty) return;
    final now = DateTime.now();
    final demos = [
      PendingItemModel(
        id: 'demo_1',
        name: 'Süt (2L)',
        category: 'Süt Ürünü',
        quantity: '2 L',
        note: 'Açılmamış, son 3 günü kaldı',
        locationLabel: 'Kadıköy, İstanbul',
        expiryDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(hours: 2)),
        isMine: false,
      ),
      PendingItemModel(
        id: 'demo_2',
        name: 'Ekmek',
        category: 'Paketli',
        quantity: '2 adet',
        note: 'Bugün alındı',
        locationLabel: 'Beşiktaş, İstanbul',
        expiryDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(hours: 5)),
        isMine: false,
      ),
      PendingItemModel(
        id: 'demo_3',
        name: 'Domates',
        category: 'Sebze',
        quantity: '500 g',
        note: 'Taze, kullanmak isteyene',
        locationLabel: 'Şişli, İstanbul',
        expiryDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
        isMine: false,
      ),
    ];
    for (final d in demos) {
      await db.insert('pending_items', d.toMap());
    }
  }
}
