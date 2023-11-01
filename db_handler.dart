import 'package:flutter_sqlite/models/saham.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  DatabaseHandler._();
  static final DatabaseHandler instance = DatabaseHandler._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'saham_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saham(
        tickerId INTEGER PRIMARY KEY AUTOINCREMENT,
        ticker TEXT NOT NULL,
        open INTEGER,
        high INTEGER,
        last INTEGER,
        change TEXT
      )
    ''');
  }

  Future<int> insertSaham(Saham saham) async {
    final db = await database;
    return await db.insert('saham', saham.toMap());
  }

  Future<List<Saham>> getSahamList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('saham');
    return List.generate(maps.length, (i) {
      return Saham.fromMap(maps[i]);
    });
  }
}
