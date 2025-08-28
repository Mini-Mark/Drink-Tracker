import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  final Uuid _uuid = Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'drinktracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create drinks table
    await db.execute('''
      CREATE TABLE drinks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create history table
    await db.execute('''
      CREATE TABLE history (
        id TEXT PRIMARY KEY,
        drinks_id TEXT NOT NULL,
        ml_amount INTEGER NOT NULL,
        datetime TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (drinks_id) REFERENCES drinks (id)
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'key': 'maximum_ML',
      'value': '2500',
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert default drinks
    await _insertDefaultDrinks(db);
  }

  Future<void> _insertDefaultDrinks(Database db) async {
    final defaultDrinks = [
      {
        'id': _uuid.v4(),
        'name': 'Water',
        'icon': 'Icons.water_drop',
        'color': '#2196F3',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'name': 'Coffee',
        'icon': 'Icons.coffee',
        'color': '#795548',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'name': 'Tea',
        'icon': 'Icons.local_cafe',
        'color': '#4CAF50',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'name': 'Juice',
        'icon': 'Icons.local_bar',
        'color': '#FF9800',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'name': 'Soda',
        'icon': 'Icons.local_drink',
        'color': '#E91E63',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (var drink in defaultDrinks) {
      await db.insert('drinks', drink);
    }
  }

  // Drinks operations
  Future<List<Map<String, dynamic>>> getAllDrinks() async {
    final db = await database;
    return await db.query('drinks', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getDrinkById(String id) async {
    final db = await database;
    final results = await db.query(
      'drinks',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<String> addDrink(String name, String icon, String? color) async {
    final db = await database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await db.insert('drinks', {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'created_at': now,
      'updated_at': now,
    });
    
    return id;
  }

  Future<void> updateDrink(String id, String name, String icon, String? color) async {
    final db = await database;
    await db.update(
      'drinks',
      {
        'name': name,
        'icon': icon,
        'color': color,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDrink(String id) async {
    final db = await database;
    await db.delete(
      'drinks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // History operations
  Future<List<Map<String, dynamic>>> getHistoryByDate(DateTime date) async {
    final db = await database;
    final dateString = '${date.month}/${date.day}/${date.year}';
    
    return await db.rawQuery('''
      SELECT h.*, d.name as drink_name, d.icon as drink_icon, d.color as drink_color
      FROM history h
      JOIN drinks d ON h.drinks_id = d.id
      WHERE h.datetime LIKE ?
      ORDER BY h.datetime DESC
    ''', ['$dateString%']);
  }

  Future<List<Map<String, dynamic>>> getHistoryByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startString = '${startDate.month}/${startDate.day}/${startDate.year}';
    final endString = '${endDate.month}/${endDate.day}/${endDate.year}';
    
    return await db.rawQuery('''
      SELECT h.*, d.name as drink_name, d.icon as drink_icon, d.color as drink_color
      FROM history h
      JOIN drinks d ON h.drinks_id = d.id
      WHERE h.datetime BETWEEN ? AND ?
      ORDER BY h.datetime DESC
    ''', ['$startString 00:00am', '$endString 23:59pm']);
  }

  Future<String> addHistoryEntry(String drinksId, int mlAmount) async {
    final db = await database;
    final id = _uuid.v4();
    final now = DateTime.now();
    final formattedDate = '${now.month}/${now.day}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}${now.hour >= 12 ? 'pm' : 'am'}';
    
    await db.insert('history', {
      'id': id,
      'drinks_id': drinksId,
      'ml_amount': mlAmount,
      'datetime': formattedDate,
      'created_at': now.toIso8601String(),
    });
    
    return id;
  }

  Future<void> deleteHistoryEntry(String id) async {
    final db = await database;
    await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalMLForDate(DateTime date) async {
    final history = await getHistoryByDate(date);
    return history.fold(0, (sum, entry) => sum + (entry['ml_amount'] as int));
  }

  // Settings operations
  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    return results.isNotEmpty ? results.first['value'] as String : null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getMaximumML() async {
    final value = await getSetting('maximum_ML');
    return int.tryParse(value ?? '2500') ?? 2500;
  }

  Future<void> setMaximumML(int ml) async {
    await setSetting('maximum_ML', ml.toString());
  }

  // Statistics operations
  Future<Map<String, dynamic>> getWeeklyStats(DateTime startDate) async {
    final db = await database;
    final endDate = startDate.add(Duration(days: 6));
    final startString = '${startDate.month}/${startDate.day}/${startDate.year}';
    final endString = '${endDate.month}/${endDate.day}/${endDate.year}';
    
    final results = await db.rawQuery('''
      SELECT 
        DATE(h.datetime) as date,
        SUM(h.ml_amount) as total_ml,
        COUNT(*) as entries_count
      FROM history h
      WHERE h.datetime BETWEEN ? AND ?
      GROUP BY DATE(h.datetime)
      ORDER BY date
    ''', ['$startString 00:00am', '$endString 23:59pm']);
    
    return {
      'daily_stats': results,
      'total_ml': results.fold(0, (sum, day) => sum + (day['total_ml'] as int)),
      'total_entries': results.fold(0, (sum, day) => sum + (day['entries_count'] as int)),
    };
  }

  Future<Map<String, dynamic>> getMonthlyStats(int year, int month) async {
    final db = await database;
    final startString = '$month/1/$year';
    final endString = '$month/31/$year';
    
    final results = await db.rawQuery('''
      SELECT 
        DATE(h.datetime) as date,
        SUM(h.ml_amount) as total_ml,
        COUNT(*) as entries_count
      FROM history h
      WHERE h.datetime BETWEEN ? AND ?
      GROUP BY DATE(h.datetime)
      ORDER BY date
    ''', ['$startString 00:00am', '$endString 23:59pm']);
    
    return {
      'daily_stats': results,
      'total_ml': results.fold(0, (sum, day) => sum + (day['total_ml'] as int)),
      'total_entries': results.fold(0, (sum, day) => sum + (day['entries_count'] as int)),
    };
  }

  // Database maintenance
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('history');
    await db.delete('drinks');
    await db.delete('settings');
    await _insertDefaultDrinks(db);
    await setSetting('maximum_ML', '2500');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}