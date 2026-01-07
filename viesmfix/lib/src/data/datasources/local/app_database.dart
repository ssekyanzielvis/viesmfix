import 'package:sqflite/sqflite.dart';

/// Database definition
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  factory AppDatabase() => instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/viesmfix.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE user_preferences (
        user_id TEXT PRIMARY KEY,
        theme_mode TEXT DEFAULT 'dark',
        language TEXT DEFAULT 'en',
        notifications_enabled INTEGER DEFAULT 1,
        preferences TEXT
      )
    ''');

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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
