import 'package:dartz/dartz.dart';
import '../entities/news_article_entity.dart';
import '../repositories/news_repository.dart';
import '../../core/errors/failures.dart';

/// Use case for fetching top headlines
class GetTopHeadlines {
  final NewsRepository repository;

  GetTopHeadlines(this.repository);

  Future<Either<Failure, List<NewsArticleEntity>>> call({
    NewsCategory? category,
    String? country,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.getTopHeadlines(
      category: category,
      country: country,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for searching news
class SearchNews {
  final NewsRepository repository;

  SearchNews(this.repository);

  Future<Either<Failure, List<NewsArticleEntity>>> call({
    required String query,
    DateTime? from,
    DateTime? to,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (query.isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    return await repository.searchNews(
      query: query,
      from: from,
      to: to,
      sortBy: sortBy,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// Use case for bookmarking articles
class BookmarkArticle {
  final NewsRepository repository;

  BookmarkArticle(this.repository);

  Future<Either<Failure, void>> call(NewsArticleEntity article) async {
    return await repository.bookmarkArticle(article);
  }
}

/// Use case for removing bookmarks
class RemoveBookmark {
  final NewsRepository repository;

  RemoveBookmark(this.repository);

  Future<Either<Failure, void>> call(String articleId) async {
    return await repository.removeBookmark(articleId);
  }
}

/// Use case for getting bookmarked articles
class GetBookmarkedArticles {
  final NewsRepository repository;

  GetBookmarkedArticles(this.repository);

  Future<Either<Failure, List<BookmarkedArticleEntity>>> call() async {
    return await repository.getBookmarkedArticles();
  }
}
