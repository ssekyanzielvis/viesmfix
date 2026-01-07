import 'package:dartz/dartz.dart';
import '../entities/news_article_entity.dart';
import '../../core/errors/failures.dart';

/// Repository for news operations
abstract class NewsRepository {
  /// Fetch top headlines by category
  Future<Either<Failure, List<NewsArticleEntity>>> getTopHeadlines({
    NewsCategory? category,
    String? country,
    int page = 1,
    int pageSize = 20,
  });

  /// Search news articles
  Future<Either<Failure, List<NewsArticleEntity>>> searchNews({
    required String query,
    DateTime? from,
    DateTime? to,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  });

  /// Get news by source
  Future<Either<Failure, List<NewsArticleEntity>>> getNewsBySource({
    required String sourceId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get available news sources
  Future<Either<Failure, List<NewsSourceEntity>>> getNewsSources({
    NewsCategory? category,
    String? language,
    String? country,
  });

  /// Bookmark an article
  Future<Either<Failure, void>> bookmarkArticle(NewsArticleEntity article);

  /// Remove bookmark
  Future<Either<Failure, void>> removeBookmark(String articleId);

  /// Get all bookmarked articles
  Future<Either<Failure, List<BookmarkedArticleEntity>>>
  getBookmarkedArticles();

  /// Check if article is bookmarked
  Future<Either<Failure, bool>> isArticleBookmarked(String articleId);

  /// Clear cache
  Future<Either<Failure, void>> clearCache();
}
