import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local database service for offline storage
class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'viesmfix.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Movies cache table
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        original_title TEXT,
        overview TEXT,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT,
        vote_average REAL,
        vote_count INTEGER,
        popularity REAL,
        adult INTEGER DEFAULT 0,
        genres TEXT,
        runtime INTEGER,
        cached_at TEXT NOT NULL
      )
    ''');

    // Watchlist table
    await db.execute('''
      CREATE TABLE watchlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        movie_id INTEGER NOT NULL,
        added_at TEXT NOT NULL,
        watched INTEGER DEFAULT 0,
        watched_at TEXT,
        rating REAL,
        notes TEXT,
        UNIQUE(user_id, movie_id)
      )
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        user_id TEXT PRIMARY KEY,
        theme_mode TEXT DEFAULT 'dark',
        language TEXT DEFAULT 'en',
        notifications_enabled INTEGER DEFAULT 1,
        preferences TEXT
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        query TEXT NOT NULL,
        searched_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_movies_id ON movies(id)');
    await db.execute(
      'CREATE INDEX idx_watchlist_user_id ON watchlist(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_watchlist_movie_id ON watchlist(movie_id)',
    );
    await db.execute(
      'CREATE INDEX idx_search_history_user_id ON search_history(user_id)',
    );
  }

  /// Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Migration from version 1 to 2
      // Example: await db.execute('ALTER TABLE movies ADD COLUMN new_column TEXT');
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('movies');
  }

  /// Clear old cache (older than specified days)
  Future<void> clearOldCache(int days) async {
    final db = await database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String();

    await db.delete('movies', where: 'cached_at < ?', whereArgs: [cutoffDate]);
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'viesmfix.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
