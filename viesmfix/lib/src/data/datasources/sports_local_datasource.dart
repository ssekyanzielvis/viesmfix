import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sport_event_model.dart';

/// Local data source for caching sports data and user preferences
class SportsLocalDataSource {
  final SharedPreferences prefs;

  static const String _cachePrefix = 'sports_cache_';
  static const String _bookmarksKey = 'sports_bookmarks';
  static const String _notificationsKey = 'sports_notifications';
  static const String _preferencesKey = 'sports_preferences';
  static const String _cacheTimestampPrefix = 'sports_cache_timestamp_';
  static const int _cacheDurationMinutes = 5; // Shorter cache for live events

  SportsLocalDataSource(this.prefs);

  /// Cache sport events
  Future<void> cacheEvents(
    String cacheKey,
    List<SportEventModel> events,
  ) async {
    final jsonList = events.map((event) => event.toJson()).toList();
    await prefs.setString('$_cachePrefix$cacheKey', jsonEncode(jsonList));
    await prefs.setInt(
      '$_cacheTimestampPrefix$cacheKey',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached events
  Future<List<SportEventModel>?> getCachedEvents(String cacheKey) async {
    final timestamp = prefs.getInt('$_cacheTimestampPrefix$cacheKey');

    if (timestamp == null) return null;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    final cacheValidDuration = Duration(
      minutes: _cacheDurationMinutes,
    ).inMilliseconds;

    if (cacheAge > cacheValidDuration) {
      // Cache expired
      await prefs.remove('$_cachePrefix$cacheKey');
      await prefs.remove('$_cacheTimestampPrefix$cacheKey');
      return null;
    }

    final jsonString = prefs.getString('$_cachePrefix$cacheKey');
    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => SportEventModel.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Bookmark a match
  Future<void> bookmarkMatch(Map<String, dynamic> matchData) async {
    final bookmarks = await getBookmarks();
    final matchId = matchData['id'] as String;

    // Remove if already exists to avoid duplicates
    bookmarks.removeWhere((b) => b['matchId'] == matchId);

    // Add new bookmark
    bookmarks.add({
      ...matchData,
      'bookmarkedAt': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
  }

  /// Remove bookmark
  Future<void> removeBookmark(String matchId) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b['matchId'] == matchId);
    await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
  }

  /// Get all bookmarks
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final jsonString = prefs.getString(_bookmarksKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Check if match is bookmarked
  Future<bool> isMatchBookmarked(String matchId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b['matchId'] == matchId);
  }

  /// Enable notification for a match
  Future<void> enableNotification(String matchId) async {
    final notifications = await getNotifications();
    if (!notifications.contains(matchId)) {
      notifications.add(matchId);
      await prefs.setStringList(_notificationsKey, notifications);
    }
  }

  /// Disable notification for a match
  Future<void> disableNotification(String matchId) async {
    final notifications = await getNotifications();
    notifications.remove(matchId);
    await prefs.setStringList(_notificationsKey, notifications);
  }

  /// Get all enabled notifications
  Future<List<String>> getNotifications() async {
    return prefs.getStringList(_notificationsKey) ?? [];
  }

  /// Check if notification is enabled for match
  Future<bool> hasNotification(String matchId) async {
    final notifications = await getNotifications();
    return notifications.contains(matchId);
  }

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await prefs.setString(_preferencesKey, jsonEncode(preferences));
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final jsonString = prefs.getString(_preferencesKey);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save favorite leagues
  Future<void> saveFavoriteLeagues(List<String> leagueIds) async {
    final prefs = await getUserPreferences() ?? {};
    prefs['favoriteLeagues'] = leagueIds;
    await saveUserPreferences(prefs);
  }

  /// Get favorite leagues
  Future<List<String>> getFavoriteLeagues() async {
    final prefs = await getUserPreferences();
    if (prefs == null) return [];
    final leagues = prefs['favoriteLeagues'];
    if (leagues is List) {
      return leagues.cast<String>();
    }
    return [];
  }

  /// Save favorite sports
  Future<void> saveFavoriteSports(List<String> sportTypes) async {
    final prefs = await getUserPreferences() ?? {};
    prefs['favoriteSports'] = sportTypes;
    await saveUserPreferences(prefs);
  }

  /// Get favorite sports
  Future<List<String>> getFavoriteSports() async {
    final prefs = await getUserPreferences();
    if (prefs == null) return [];
    final sports = prefs['favoriteSports'];
    if (sports is List) {
      return sports.cast<String>();
    }
    return [];
  }

  /// Save user region
  Future<void> saveRegion(String region) async {
    final prefs = await getUserPreferences() ?? {};
    prefs['region'] = region;
    await saveUserPreferences(prefs);
  }

  /// Get user region
  Future<String?> getRegion() async {
    final prefs = await getUserPreferences();
    return prefs?['region'];
  }

  /// Clear all cache
  Future<void> clearCache() async {
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix) ||
          key.startsWith(_cacheTimestampPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Clear all bookmarks
  Future<void> clearBookmarks() async {
    await prefs.remove(_bookmarksKey);
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    await prefs.remove(_notificationsKey);
  }

  /// Clear all user data
  Future<void> clearAll() async {
    await clearCache();
    await clearBookmarks();
    await clearNotifications();
    await prefs.remove(_preferencesKey);
  }
}
