import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/my_fridge/models/fridge_item_model.dart';
import '../../features/recipes/models/recipe_model.dart';

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
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fridge_items(
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            quantity TEXT,
            note TEXT,
            createdAt TEXT,
            expiryDate TEXT,
            categoryKey TEXT,
            status TEXT,
            productionDate TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE recipes(
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            ingredients TEXT,
            prepMinutes INTEGER,
            difficulty TEXT,
            iconCode INTEGER,
            gradientColors TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE activity_log(
            id TEXT PRIMARY KEY,
            itemId TEXT,
            itemName TEXT,
            action TEXT,
            quantity TEXT,
            reason TEXT,
            timestamp TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_items(
            id TEXT PRIMARY KEY,
            sourceItemId TEXT,
            name TEXT,
            category TEXT,
            quantity TEXT,
            note TEXT,
            locationLabel TEXT,
            expiryDate TEXT,
            status TEXT,
            createdAt TEXT,
            isMine INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE recipes(
              id TEXT PRIMARY KEY,
              name TEXT,
              description TEXT,
              ingredients TEXT,
              prepMinutes INTEGER,
              difficulty TEXT,
              iconCode INTEGER,
              gradientColors TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE fridge_items ADD COLUMN categoryKey TEXT",
          );
          await db.execute(
            "ALTER TABLE fridge_items ADD COLUMN status TEXT",
          );
          await db.execute(
            "ALTER TABLE fridge_items ADD COLUMN productionDate TEXT",
          );
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS activity_log(
              id TEXT PRIMARY KEY,
              itemId TEXT,
              itemName TEXT,
              action TEXT,
              quantity TEXT,
              reason TEXT,
              timestamp TEXT
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pending_items(
              id TEXT PRIMARY KEY,
              sourceItemId TEXT,
              name TEXT,
              category TEXT,
              quantity TEXT,
              note TEXT,
              locationLabel TEXT,
              expiryDate TEXT,
              status TEXT,
              createdAt TEXT,
              isMine INTEGER
            )
          ''');
        }
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

  // Recipes CRUD operations
  Future<void> insertRecipe(RecipeModel recipe) async {
    final db = await database;
    await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RecipeModel>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) {
      return RecipeModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteRecipe(String id) async {
    final db = await database;
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
