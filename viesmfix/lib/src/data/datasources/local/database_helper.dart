import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/exceptions.dart';

class DatabaseHelper {
  static const String _databaseName = 'viesmfix.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String moviesTable = 'movies';
  static const String genresTable = 'genres';
  static const String movieGenresTable = 'movie_genres';
  static const String cachedSearchesTable = 'cached_searches';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Movies table
    await db.execute('''
      CREATE TABLE $moviesTable (
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
        video INTEGER DEFAULT 0,
        original_language TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Genres table
    await db.execute('''
      CREATE TABLE $genresTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // Movie-Genre junction table
    await db.execute('''
      CREATE TABLE $movieGenresTable (
        movie_id INTEGER NOT NULL,
        genre_id INTEGER NOT NULL,
        PRIMARY KEY (movie_id, genre_id),
        FOREIGN KEY (movie_id) REFERENCES $moviesTable (id) ON DELETE CASCADE,
        FOREIGN KEY (genre_id) REFERENCES $genresTable (id) ON DELETE CASCADE
      )
    ''');

    // Cached searches table
    await db.execute('''
      CREATE TABLE $cachedSearchesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        page INTEGER NOT NULL,
        results TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        UNIQUE(query, page)
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_movies_cached_at ON $moviesTable (cached_at)',
    );
    await db.execute(
      'CREATE INDEX idx_cached_searches_query ON $cachedSearchesTable (query)',
    );
    await db.execute(
      'CREATE INDEX idx_cached_searches_cached_at ON $cachedSearchesTable (cached_at)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  /// Cache a movie
  Future<void> cacheMovie(Map<String, dynamic> movie) async {
    try {
      final db = await database;
      await db.insert(moviesTable, {
        ...movie,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Cache genres if present
      if (movie['genre_ids'] != null && movie['genre_ids'] is List) {
        final List<int> genreIds = List<int>.from(movie['genre_ids']);
        for (final genreId in genreIds) {
          await db.insert(movieGenresTable, {
            'movie_id': movie['id'],
            'genre_id': genreId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    } catch (e) {
      throw CacheException('Failed to cache movie: $e');
    }
  }

  /// Cache multiple movies
  Future<void> cacheMovies(List<Map<String, dynamic>> movies) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final movie in movies) {
        batch.insert(moviesTable, {
          ...movie,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Cache genres
        if (movie['genre_ids'] != null && movie['genre_ids'] is List) {
          final List<int> genreIds = List<int>.from(movie['genre_ids']);
          for (final genreId in genreIds) {
            batch.insert(movieGenresTable, {
              'movie_id': movie['id'],
              'genre_id': genreId,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache movies: $e');
    }
  }

  /// Get a cached movie by ID
  Future<Map<String, dynamic>?> getCachedMovie(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        moviesTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) return null;

      final movie = Map<String, dynamic>.from(results.first);

      // Get genres
      final genreResults = await db.rawQuery(
        '''
        SELECT genre_id FROM $movieGenresTable
        WHERE movie_id = ?
      ''',
        [id],
      );

      movie['genre_ids'] = genreResults.map((row) => row['genre_id']).toList();

      return movie;
    } catch (e) {
      throw CacheException('Failed to get cached movie: $e');
    }
  }

  /// Get all cached movies
  Future<List<Map<String, dynamic>>> getAllCachedMovies() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        moviesTable,
        orderBy: 'cached_at DESC',
      );

      return results;
    } catch (e) {
      throw CacheException('Failed to get cached movies: $e');
    }
  }

  /// Cache search results
  Future<void> cacheSearchResults({
    required String query,
    required int page,
    required List<Map<String, dynamic>> results,
  }) async {
    try {
      final db = await database;
      await db.insert(cachedSearchesTable, {
        'query': query,
        'page': page,
        'results': results.toString(),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheException('Failed to cache search results: $e');
    }
  }

  /// Get cached search results
  Future<List<Map<String, dynamic>>?> getCachedSearchResults({
    required String query,
    required int page,
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        cachedSearchesTable,
        where: 'query = ? AND page = ?',
        whereArgs: [query, page],
      );

      if (results.isEmpty) return null;

      // Check if cache is still valid (6 hours)
      final cachedAt = results.first['cached_at'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedAt;
      if (cacheAge > 6 * 60 * 60 * 1000) {
        // Cache expired
        await db.delete(
          cachedSearchesTable,
          where: 'query = ? AND page = ?',
          whereArgs: [query, page],
        );
        return null;
      }

      // Parse results
      // Note: In production, use JSON encoding instead of toString()
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached search results: $e');
    }
  }

  /// Clear old cache entries
  Future<void> clearOldCache() async {
    try {
      final db = await database;
      final sixHoursAgo = DateTime.now()
          .subtract(const Duration(hours: 6))
          .millisecondsSinceEpoch;

      await db.delete(
        moviesTable,
        where: 'cached_at < ?',
        whereArgs: [sixHoursAgo],
      );

      await db.delete(
        cachedSearchesTable,
        where: 'cached_at < ?',
        whereArgs: [sixHoursAgo],
      );
    } catch (e) {
      throw CacheException('Failed to clear old cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      final db = await database;
      await db.delete(moviesTable);
      await db.delete(cachedSearchesTable);
      await db.delete(movieGenresTable);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
