import 'package:sqflite/sqflite.dart';
import '../local/app_database.dart';
import '../../models/local/cached_movie_model.dart';

/// Data Access Object for movies
class MovieDao {
  final AppDatabase _database;

  MovieDao(this._database);

  /// Insert movie into cache
  Future<void> insertMovie(CachedMovieModel movie) async {
    final db = await _database.database;
    await db.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get movie from cache
  Future<CachedMovieModel?> getMovie(int id) async {
    final db = await _database.database;
    final maps = await db.query('movies', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return CachedMovieModel.fromMap(maps.first);
  }

  /// Get all cached movies
  Future<List<CachedMovieModel>> getAllMovies() async {
    final db = await _database.database;
    final maps = await db.query('movies');
    return maps.map((map) => CachedMovieModel.fromMap(map)).toList();
  }

  /// Update movie in cache
  Future<void> updateMovie(CachedMovieModel movie) async {
    final db = await _database.database;
    await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  /// Delete movie from cache
  Future<void> deleteMovie(int id) async {
    final db = await _database.database;
    await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all cached movies
  Future<void> deleteAllMovies() async {
    final db = await _database.database;
    await db.delete('movies');
  }

  /// Delete old cached movies
  Future<void> deleteOldMovies(Duration maxAge) async {
    final db = await _database.database;
    final cutoffDate = DateTime.now().subtract(maxAge).toIso8601String();

    await db.delete('movies', where: 'cached_at < ?', whereArgs: [cutoffDate]);
  }

  /// Check if movie is cached
  Future<bool> isMovieCached(int id) async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM movies WHERE id = ?', [id]),
    );
    return count != null && count > 0;
  }

  /// Get cached movies by IDs
  Future<List<CachedMovieModel>> getMoviesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final db = await _database.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final maps = await db.query(
      'movies',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );

    return maps.map((map) => CachedMovieModel.fromMap(map)).toList();
  }

  /// Search cached movies
  Future<List<CachedMovieModel>> searchMovies(String query) async {
    final db = await _database.database;
    final maps = await db.query(
      'movies',
      where: 'title LIKE ? OR original_title LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((map) => CachedMovieModel.fromMap(map)).toList();
  }

  /// Get popular cached movies
  Future<List<CachedMovieModel>> getPopularMovies({int limit = 20}) async {
    final db = await _database.database;
    final maps = await db.query(
      'movies',
      orderBy: 'popularity DESC',
      limit: limit,
    );

    return maps.map((map) => CachedMovieModel.fromMap(map)).toList();
  }

  /// Get top rated cached movies
  Future<List<CachedMovieModel>> getTopRatedMovies({int limit = 20}) async {
    final db = await _database.database;
    final maps = await db.query(
      'movies',
      where: 'vote_average IS NOT NULL',
      orderBy: 'vote_average DESC',
      limit: limit,
    );

    return maps.map((map) => CachedMovieModel.fromMap(map)).toList();
  }
}
