import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/news_article_model.dart';

/// Local data source for caching news and bookmarks
class NewsLocalDataSource {
  final SharedPreferences prefs;

  static const String _cachePrefix = 'news_cache_';
  static const String _bookmarksKey = 'news_bookmarks';
  static const String _cacheTimestampPrefix = 'news_cache_timestamp_';
  static const int _cacheDurationMinutes = 15;

  NewsLocalDataSource(this.prefs);

  /// Cache news articles
  Future<void> cacheArticles(
    String cacheKey,
    List<NewsArticleModel> articles,
  ) async {
    final jsonList = articles.map((article) => article.toJson()).toList();
    await prefs.setString('$_cachePrefix$cacheKey', jsonEncode(jsonList));
    await prefs.setInt(
      '$_cacheTimestampPrefix$cacheKey',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached articles
  Future<List<NewsArticleModel>?> getCachedArticles(String cacheKey) async {
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
      return jsonList.map((json) => NewsArticleModel.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Bookmark an article
  Future<void> bookmarkArticle(Map<String, dynamic> articleData) async {
    final bookmarks = await getBookmarks();
    final articleId = articleData['id'] as String;

    // Remove if already exists to avoid duplicates
    bookmarks.removeWhere((b) => b['articleId'] == articleId);

    // Add new bookmark
    bookmarks.add({
      ...articleData,
      'bookmarkedAt': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
  }

  /// Remove bookmark
  Future<void> removeBookmark(String articleId) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b['articleId'] == articleId);
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

  /// Check if article is bookmarked
  Future<bool> isArticleBookmarked(String articleId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b['articleId'] == articleId);
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
}
