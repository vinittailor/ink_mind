import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ink_mind/core/constants/app_constants.dart';

/// Database helper managing the local SQLite database via [sqflite].
class AppDatabase {
  static Database? _database;

  /// Returns the singleton [Database] instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE note_chunks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        embedding TEXT NOT NULL,
        sourceTitle TEXT,
        chunkIndex INTEGER,
        createdAt TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE note_chunks ADD COLUMN sourceTitle TEXT;');
      await db.execute('ALTER TABLE note_chunks ADD COLUMN chunkIndex INTEGER;');
      await db.execute('ALTER TABLE note_chunks ADD COLUMN createdAt TEXT;');
    }
  }
}
