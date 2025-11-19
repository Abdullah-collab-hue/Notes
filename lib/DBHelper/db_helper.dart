import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT
          )
        ''');
      },
    );
  }

  // Insert
  Future<int> insertNote(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.insert('notes', row);
  }

  // Query all
  Future<List<Map<String, dynamic>>> getNotes() async {
    final dbClient = await db;
    return await dbClient.query('notes', orderBy: "id DESC");
  }

  // Update
  Future<int> updateNote(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.update(
      'notes',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  // Delete
  Future<int> deleteNote(int id) async {
    final dbClient = await db;
    return await dbClient.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
