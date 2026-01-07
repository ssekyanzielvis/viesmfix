import 'package:dartz/dartz.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/news_remote_datasource.dart';
import '../datasources/news_local_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getTopHeadlines({
    NewsCategory? category,
    String? country,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Generate cache key
      final cacheKey =
          'headlines_${category?.key ?? 'all'}_${country ?? 'us'}_$page';

      // Try to get from cache first
      final cachedArticles = await localDataSource.getCachedArticles(cacheKey);
      if (cachedArticles != null && cachedArticles.isNotEmpty) {
        final bookmarkedIds = await _getBookmarkedIds();
        final entities = cachedArticles
            .map(
              (model) => model.toEntity(
                category: category,
                isBookmarked: bookmarkedIds.contains(
                  model.url.hashCode.toString(),
                ),
              ),
            )
            .toList();
        return Right(entities);
      }

      // Fetch from remote
      final articles = await remoteDataSource.getTopHeadlines(
        category: category?.key,
        country: country,
        page: page,
        pageSize: pageSize,
      );

      // Cache the results
      await localDataSource.cacheArticles(cacheKey, articles);

      // Convert to entities with bookmark status
      final bookmarkedIds = await _getBookmarkedIds();
      final entities = articles
          .map(
            (model) => model.toEntity(
              category: category,
              isBookmarked: bookmarkedIds.contains(
                model.url.hashCode.toString(),
              ),
            ),
          )
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> searchNews({
    required String query,
    DateTime? from,
    DateTime? to,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final articles = await remoteDataSource.searchNews(
        query: query,
        from: from?.toIso8601String(),
        to: to?.toIso8601String(),
        sortBy: sortBy,
        page: page,
        pageSize: pageSize,
      );

      final bookmarkedIds = await _getBookmarkedIds();
      final entities = articles
          .map(
            (model) => model.toEntity(
              isBookmarked: bookmarkedIds.contains(
                model.url.hashCode.toString(),
              ),
            ),
          )
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getNewsBySource({
    required String sourceId,
    int page = 1,
    int pageSize = 20,
  }) async {
    // NewsAPI doesn't have a direct endpoint for this, we can use search with source filter
    return await searchNews(query: sourceId, page: page, pageSize: pageSize);
  }

  @override
  Future<Either<Failure, List<NewsSourceEntity>>> getNewsSources({
    NewsCategory? category,
    String? language,
    String? country,
  }) async {
    try {
      final sources = await remoteDataSource.getNewsSources(
        category: category?.key,
        language: language,
        country: country,
      );

      final entities = sources.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bookmarkArticle(
    NewsArticleEntity article,
  ) async {
    try {
      final articleData = {
        'id': article.id,
        'articleId': article.id,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'imageUrl': article.urlToImage,
        'sourceName': article.sourceName,
        'publishedAt': article.publishedAt.toIso8601String(),
      };

      await localDataSource.bookmarkArticle(articleData);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String articleId) async {
    try {
      await localDataSource.removeBookmark(articleId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookmarkedArticleEntity>>>
  getBookmarkedArticles() async {
    try {
      final bookmarks = await localDataSource.getBookmarks();

      final entities = bookmarks.map((json) {
        return BookmarkedArticleEntity(
          id: json['id'] ?? '',
          userId: '', // Will be set when user auth is implemented
          articleId: json['articleId'] ?? '',
          title: json['title'] ?? '',
          description: json['description'],
          url: json['url'] ?? '',
          imageUrl: json['imageUrl'],
          sourceName: json['sourceName'] ?? '',
          publishedAt:
              DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
          bookmarkedAt:
              DateTime.tryParse(json['bookmarkedAt'] ?? '') ?? DateTime.now(),
        );
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isArticleBookmarked(String articleId) async {
    try {
      final isBookmarked = await localDataSource.isArticleBookmarked(articleId);
      return Right(isBookmarked);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Set<String>> _getBookmarkedIds() async {
    final bookmarks = await localDataSource.getBookmarks();
    return bookmarks.map((b) => b['articleId'] as String).toSet();
  }
}
