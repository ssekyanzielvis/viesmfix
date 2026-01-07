import 'package:dio/dio.dart';
import '../models/news_article_model.dart';
import '../../core/constants/environment.dart';

/// Remote data source for news using Supabase Edge Functions
class NewsRemoteDataSource {
  final Dio dio;

  // Supabase Edge Function endpoint
  final String baseUrl;

  NewsRemoteDataSource({required this.dio, String? edgeFunctionUrl})
    : baseUrl =
          edgeFunctionUrl ??
          '${Environment.supabaseUrl}/functions/v1/news-proxy';

  /// Fetch top headlines
  Future<List<NewsArticleModel>> getTopHeadlines({
    String? category,
    String? country,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/top-headlines',
        data: {
          'category': category,
          'country': country ?? 'us',
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'ok') {
          final articles = (data['articles'] as List)
              .map((json) => NewsArticleModel.fromJson(json))
              .toList();
          return articles;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch news');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch top headlines: $e');
    }
  }

  /// Search news articles
  Future<List<NewsArticleModel>> searchNews({
    required String query,
    String? from,
    String? to,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/search',
        data: {
          'q': query,
          'from': from,
          'to': to,
          'sortBy': sortBy ?? 'publishedAt',
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'ok') {
          final articles = (data['articles'] as List)
              .map((json) => NewsArticleModel.fromJson(json))
              .toList();
          return articles;
        } else {
          throw Exception(data['message'] ?? 'Failed to search news');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }

  /// Get news sources
  Future<List<NewsSourceModel>> getNewsSources({
    String? category,
    String? language,
    String? country,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/sources',
        data: {'category': category, 'language': language, 'country': country},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'ok') {
          final sources = (data['sources'] as List)
              .map((json) => NewsSourceModel.fromJson(json))
              .toList();
          return sources;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch sources');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch sources: $e');
    }
  }
}
