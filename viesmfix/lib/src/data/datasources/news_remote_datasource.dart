import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/news_article_model.dart';
import '../../core/constants/environment.dart';

/// Remote data source for news using Supabase Edge Functions
class NewsRemoteDataSource {
  final Dio dio;
  final SupabaseClient supabase;

  // Supabase Edge Function name
  final List<String> functionNames;

  NewsRemoteDataSource({
    required this.dio,
    required this.supabase,
    String? edgeFunctionUrl,
  }) : functionNames = [
         Environment.newsFunctionName,
         'news',
         'news_api',
         'news-proxy',
         'newsproxy',
       ];

  Future<Map<String, dynamic>> _invoke(
    String subpath,
    Map<String, dynamic> body,
  ) async {
    dynamic raw;
    // Try name/subpath, then name with {path: subpath}
    for (final name in functionNames) {
      try {
        final response = await supabase.functions.invoke(
          '$name/$subpath',
          body: body,
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        );
        raw = response.data;
        break;
      } catch (_) {
        try {
          final response = await supabase.functions.invoke(
            name,
            body: {'path': subpath, ...body},
            headers: {
              'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
              'Content-Type': 'application/json',
            },
          );
          raw = response.data;
          break;
        } catch (_) {
          // try next name
        }
      }
    }

    if (raw == null) throw Exception('Empty response from function');
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    throw Exception('Unexpected function result format');
  }

  /// Fetch top headlines
  Future<List<NewsArticleModel>> getTopHeadlines({
    String? category,
    String? country,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _invoke('top-headlines', {
        'category': category,
        'country': country ?? 'us',
        'page': page,
        'pageSize': pageSize,
      });
      // Normalize response shape
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawArticles = (root['articles'] ?? root['results']) as List?;
      if (status == 'ok' || status == 'success' || rawArticles != null) {
        final list = rawArticles ?? const [];
        final articles = list
            .map((json) => NewsArticleModel.fromJson(json))
            .toList();
        return articles;
      }
      throw Exception(data['message'] ?? 'Failed to fetch news');
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
      final data = await _invoke('search', {
        'q': query,
        'from': from,
        'to': to,
        'sortBy': sortBy ?? 'publishedAt',
        'page': page,
        'pageSize': pageSize,
      });
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawArticles = (root['articles'] ?? root['results']) as List?;
      if (status == 'ok' || status == 'success' || rawArticles != null) {
        final list = rawArticles ?? const [];
        final articles = list
            .map((json) => NewsArticleModel.fromJson(json))
            .toList();
        return articles;
      }
      throw Exception(data['message'] ?? 'Failed to search news');
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
      final data = await _invoke('sources', {
        'category': category,
        'language': language,
        'country': country,
      });
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawSources = (root['sources'] ?? root['results']) as List?;
      if (status == 'ok' || status == 'success' || rawSources != null) {
        final list = rawSources ?? const [];
        final sources = list
            .map((json) => NewsSourceModel.fromJson(json))
            .toList();
        return sources;
      }
      throw Exception(data['message'] ?? 'Failed to fetch sources');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch sources: $e');
    }
  }
}
