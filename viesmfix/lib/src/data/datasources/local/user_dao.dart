import 'package:sqflite/sqflite.dart';
import '../local/app_database.dart';
import '../../models/local/user_preferences_model.dart';

/// Data Access Object for user data
class UserDao {
  final AppDatabase _database;

  UserDao(this._database);

  /// Get user preferences
  Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    final db = await _database.database;
    final maps = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return UserPreferencesModel.fromMap(maps.first);
  }

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    final db = await _database.database;
    await db.insert(
      'user_preferences',
      preferences.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update user preferences
  Future<void> updateUserPreferences(UserPreferencesModel preferences) async {
    final db = await _database.database;
    await db.update(
      'user_preferences',
      preferences.toMap(),
      where: 'user_id = ?',
      whereArgs: [preferences.userId],
    );
  }

  /// Delete user preferences
  Future<void> deleteUserPreferences(String userId) async {
    final db = await _database.database;
    await db.delete(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get search history for user
  Future<List<String>> getSearchHistory(String userId, {int limit = 10}) async {
    final db = await _database.database;
    final maps = await db.query(
      'search_history',
      columns: ['query'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'searched_at DESC',
      limit: limit,
      distinct: true,
    );

    return maps.map((map) => map['query'] as String).toList();
  }

  /// Add search query to history
  Future<void> addSearchQuery(String userId, String query) async {
    final db = await _database.database;
    await db.insert('search_history', {
      'user_id': userId,
      'query': query,
      'searched_at': DateTime.now().toIso8601String(),
    });
  }

  /// Clear search history for user
  Future<void> clearSearchHistory(String userId) async {
    final db = await _database.database;
    await db.delete(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Delete old search history
  Future<void> deleteOldSearchHistory(String userId, Duration maxAge) async {
    final db = await _database.database;
    final cutoffDate = DateTime.now().subtract(maxAge).toIso8601String();

    await db.delete(
      'search_history',
      where: 'user_id = ? AND searched_at < ?',
      whereArgs: [userId, cutoffDate],
    );
  }

  /// Get watchlist item count for user
  Future<int> getWatchlistCount(String userId) async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM watchlist WHERE user_id = ?', [
        userId,
      ]),
    );
    return count ?? 0;
  }

  /// Get watched movies count for user
  Future<int> getWatchedCount(String userId) async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM watchlist WHERE user_id = ? AND watched = 1',
        [userId],
      ),
    );
    return count ?? 0;
  }

  /// Clear all user data
  Future<void> clearUserData(String userId) async {
    final db = await _database.database;
    await db.delete('watchlist', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.delete(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
