import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/news_usecases.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../data/datasources/news_local_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import 'common_providers.dart';

// Data sources
final dioProvider = Provider<Dio>((ref) => Dio());

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    // Supabase not initialized; return null so consumers can handle gracefully
    return null;
  }
});

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return NewsRemoteDataSource(dio: ref.watch(dioProvider), supabase: client);
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NewsLocalDataSource(prefs);
});

// Repository
class _DisabledNewsRepository implements NewsRepository {
  Failure _err() => ServerFailure('News is disabled: Supabase not configured');
  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getTopHeadlines({
    NewsCategory? category,
    String? country,
    int page = 1,
    int pageSize = 20,
  }) async => Left(_err());
  @override
  Future<Either<Failure, List<NewsArticleEntity>>> searchNews({
    required String query,
    DateTime? from,
    DateTime? to,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async => Left(_err());
  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getNewsBySource({
    required String sourceId,
    int page = 1,
    int pageSize = 20,
  }) async => Left(_err());
  @override
  Future<Either<Failure, List<NewsSourceEntity>>> getNewsSources({
    NewsCategory? category,
    String? language,
    String? country,
  }) async => Left(_err());
  @override
  Future<Either<Failure, void>> bookmarkArticle(
    NewsArticleEntity article,
  ) async => Left(_err());
  @override
  Future<Either<Failure, void>> removeBookmark(String articleId) async =>
      Left(_err());
  @override
  Future<Either<Failure, List<BookmarkedArticleEntity>>>
  getBookmarkedArticles() async => Left(_err());
  @override
  Future<Either<Failure, bool>> isArticleBookmarked(String articleId) async =>
      Left(_err());
  @override
  Future<Either<Failure, void>> clearCache() async => Left(_err());
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final remote = ref.watch(newsRemoteDataSourceProvider);
  final local = ref.watch(newsLocalDataSourceProvider);
  if (remote == null) {
    return _DisabledNewsRepository();
  }
  return NewsRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

// Use cases
final getTopHeadlinesUseCaseProvider = Provider<GetTopHeadlines>((ref) {
  return GetTopHeadlines(ref.watch(newsRepositoryProvider));
});

final searchNewsUseCaseProvider = Provider<SearchNews>((ref) {
  return SearchNews(ref.watch(newsRepositoryProvider));
});

final bookmarkArticleUseCaseProvider = Provider<BookmarkArticle>((ref) {
  return BookmarkArticle(ref.watch(newsRepositoryProvider));
});

final removeBookmarkUseCaseProvider = Provider<RemoveBookmark>((ref) {
  return RemoveBookmark(ref.watch(newsRepositoryProvider));
});

final getBookmarkedArticlesUseCaseProvider = Provider<GetBookmarkedArticles>((
  ref,
) {
  return GetBookmarkedArticles(ref.watch(newsRepositoryProvider));
});

// State providers
class NewsNotifier extends StateNotifier<AsyncValue<List<NewsArticleEntity>>> {
  final GetTopHeadlines getTopHeadlines;
  final SearchNews searchNews;

  NewsNotifier({required this.getTopHeadlines, required this.searchNews})
    : super(const AsyncValue.loading());

  Future<void> fetchTopHeadlines({
    NewsCategory? category,
    String? country,
    int page = 1,
  }) async {
    state = const AsyncValue.loading();
    final result = await getTopHeadlines(
      category: category,
      country: country,
      page: page,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (articles) => state = AsyncValue.data(articles),
    );
  }

  Future<void> search({
    required String query,
    DateTime? from,
    DateTime? to,
    int page = 1,
  }) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    final result = await searchNews(
      query: query,
      from: from,
      to: to,
      page: page,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (articles) => state = AsyncValue.data(articles),
    );
  }

  void appendArticles(List<NewsArticleEntity> newArticles) {
    state.whenData((articles) {
      state = AsyncValue.data([...articles, ...newArticles]);
    });
  }
}

final newsProvider =
    StateNotifierProvider<NewsNotifier, AsyncValue<List<NewsArticleEntity>>>((
      ref,
    ) {
      return NewsNotifier(
        getTopHeadlines: ref.watch(getTopHeadlinesUseCaseProvider),
        searchNews: ref.watch(searchNewsUseCaseProvider),
      );
    });

final bookmarkedArticlesProvider =
    FutureProvider<List<BookmarkedArticleEntity>>((ref) async {
      final useCase = ref.watch(getBookmarkedArticlesUseCaseProvider);
      final result = await useCase();

      return result.fold(
        (failure) => throw Exception(failure.message),
        (articles) => articles,
      );
    });
