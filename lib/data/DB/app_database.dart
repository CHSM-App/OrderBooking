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
      version: 9, // incremented version
      onCreate: (db, _) async {
        await _createOfflineVisitsTable(db);
        await _createShopsTable(db);
        await _createRegionTable(db);
        await _createProductsTable(db);
        await _createProductSubtypesTable(db);
        await _createOfflineOrdersTable(db);
        await _createOfflineOrdersItemsTable(db);
        await _createOfflineCheckinStatusTable(db);
        await _createDeliveredOrdersTable(db);
        await createEmployeeTable(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  static Future<void> _createOfflineVisitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE,
        server_location_id INTEGER,
        payload TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        captured_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_offline_visits_server_location_id '
      'ON offline_visits(server_location_id)',
    );
  }

  static Future<void> _createShopsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS shops (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      local_id TEXT UNIQUE,
      server_id INTEGER UNIQUE,
      shop_name TEXT,
      owner_name TEXT,
      address TEXT,
      mobile_no TEXT,
      email TEXT,
      region_id INTEGER,
      created_by INTEGER,
      latitude REAL,
      longitude REAL,
      shop_selfie TEXT,
      company_id TEXT,
        type INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      sync_action TEXT, -- create | update | delete
      updated_at TEXT,
      type INTEGER
    )
  ''');
  }

  static Future<void> _createRegionTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS offline_regions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      local_id TEXT UNIQUE,
      server_id INTEGER UNIQUE,
      region_name TEXT,
      pincode TEXT,
      district TEXT,
      state TEXT,
      company_id TEXT,
      created_by INTEGER,
      status TEXT NOT NULL DEFAULT 'synced',
      retry_count INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      captured_at TEXT NOT NULL,
      updated_at TEXT
    )
  ''');
  }

  static Future<void> _createProductsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      local_id TEXT UNIQUE,
      product_id INTEGER UNIQUE,  -- ðŸ”¥ IMPORTANT
      product_name TEXT,
   
      created_by INTEGER,
      admin_id INTEGER,
      company_id TEXT,
      product_unit TEXT,
      total_price REAL,
      shop_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      updated_at TEXT
    )
  ''');
  }

  static Future<void> _createProductSubtypesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_subtypes (
        sub_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE,
        product_local_id TEXT,
        server_product_id INTEGER,
        server_sub_item_id INTEGER,
        measuring_unit TEXT,
        available_unit REAL,
    
        total REAL,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT,
        is_deleted INTEGER DEFAULT 0,
        delete_retry INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _createOfflineOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE offline_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_order_id TEXT UNIQUE,
        server_order_id INTEGER,      
        employee_id INTEGER,
        shop_id INTEGER,
        owner_name TEXT,
         mobile_no TEXT,
        shop_name TEXT,
        emp_name TEXT,
        address TEXT,
        order_date TEXT,
        total_price REAL,
        company_id TEXT,
        status TEXT,                
        is_delivered INTEGER DEFAULT 0,
        retry_count INTEGER DEFAULT 0,
        created_at TEXT
    )
  ''');
  }

  static Future<void> _createOfflineCheckinStatusTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_checkin_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE,
        emp_id INTEGER,
        in_date TEXT,
        in_time TEXT,
        out_date TEXT,
        out_time TEXT,
        checkin_status INTEGER,
        latitude REAL,
        longitude REAL,
        payload TEXT NOT NULL,
        captured_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createDeliveredOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS delivered_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_order_id INTEGER UNIQUE,
        status TEXT,
        delivered_on TEXT
      )
    ''');
  }

  static Future<void> _createOfflineOrdersItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE offline_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_order_id TEXT,          
        product_id INTEGER,
        sub_item_id INTEGER,
        product_name TEXT,
        product_unit TEXT,
        price REAL,
        quantity INTEGER,
        total_price REAL
      
    )
  ''');
  }

  static Future<void> createEmployeeTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS employee (
      emp_id INTEGER PRIMARY KEY,
      emp_name TEXT,
      emp_mobile TEXT,
      emp_address TEXT,
      emp_email TEXT,
      region_id INTEGER,
      image_url TEXT,
      id_proof TEXT,
      active_status INTEGER,
      joining_date TEXT,
      role_id INTEGER,
      company_id TEXT,
      admin_id INTEGER,
      region_name TEXT,
      company_name TEXT,
      checkin_status INTEGER
    )
  ''');
  }

  static Future<void> clearAllTables() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('products');
      await txn.delete('product_subtypes');
      await txn.delete('offline_orders');
      await txn.delete('offline_order_items');
      await txn.delete('offline_visits');
      await txn.delete('offline_checkin_status');
      await txn.delete('shops');
      await txn.delete('offline_regions');
      await txn.delete('employee');
    });
  }
}










