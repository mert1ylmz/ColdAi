import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/my_fridge/models/fridge_item_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cold_ai.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fridge_items(
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            quantity TEXT,
            note TEXT,
            createdAt TEXT,
            expiryDate TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertItem(FridgeItemModel item) async {
    final db = await database;
    await db.insert(
      'fridge_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FridgeItemModel>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fridge_items');
    return List.generate(maps.length, (i) {
      return FridgeItemModel.fromMap(maps[i]);
    });
  }

  Future<void> updateItem(FridgeItemModel item) async {
    final db = await database;
    await db.update(
      'fridge_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete(
      'fridge_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
