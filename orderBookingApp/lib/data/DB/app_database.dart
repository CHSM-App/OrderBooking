import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'offline_queue.db');

    return openDatabase(
      path,
      version: 3, // 👈 bumped version
      onCreate: (db, _) async {
        // Runs only on fresh install
        await _createOfflineVisitsTable(db);
        await _createShopsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Runs for existing users
        if (oldVersion < 2) {
          await _createShopsTable(db);
        }
      },
    );
  }

  static Future<void> _createOfflineVisitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE,
        payload TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        captured_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createShopsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE,
        server_id INTEGER,
        shop_name TEXT,
        owner_name TEXT,
        address TEXT,
        mobile_no TEXT,
        email TEXT,
        region_id INTEGER,
        created_by INTEGER,
        latitude REAL,
        longitude REAL,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT
      )
    ''');
  }
}
