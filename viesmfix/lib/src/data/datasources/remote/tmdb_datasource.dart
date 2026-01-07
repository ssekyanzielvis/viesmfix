import 'package:dio/dio.dart';
import '../../../core/constants/environment.dart';
import '../../models/remote/tmdb_movie_model.dart';

/// Remote data source for TMDB API
abstract class TMDBDataSource {
  Future<List<TMDBMovieModel>> getTrendingMovies({
    String timeWindow = 'week',
    int page = 1,
  });

  Future<TMDBMovieModel> getMovieDetails(int movieId);

  Future<List<TMDBMovieModel>> searchMovies({
    required String query,
    int page = 1,
  });

  Future<List<TMDBMovieModel>> discoverMovies({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    int? year,
  });

  Future<List<TMDBMovieModel>> getNowPlaying({int page = 1});
  Future<List<TMDBMovieModel>> getPopular({int page = 1});
  Future<List<TMDBMovieModel>> getTopRated({int page = 1});
  Future<List<TMDBMovieModel>> getUpcoming({int page = 1});
  Future<List<TMDBMovieModel>> getSimilarMovies(int movieId, {int page = 1});
}

/// Implementation of TMDB data source
class TMDBDataSourceImpl implements TMDBDataSource {
  final Dio _dio;

  TMDBDataSourceImpl(this._dio);

  static const String _baseUrl = 'https://api.themoviedb.org/3';

  @override
  Future<List<TMDBMovieModel>> getTrendingMovies({
    String timeWindow = 'week',
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/trending/movie/$timeWindow',
        queryParameters: {
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch trending movies: $e');
    }
  }

  @override
  Future<TMDBMovieModel> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId',
        queryParameters: {
          'language': Environment.defaultLanguage,
          'append_to_response': 'credits,videos,similar,recommendations',
        },
      );

      return TMDBMovieModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: {
          'query': query,
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> discoverMovies({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    int? year,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'language': Environment.defaultLanguage,
      };

      if (sortBy != null) params['sort_by'] = sortBy;
      if (withGenres != null && withGenres.isNotEmpty) {
        params['with_genres'] = withGenres.join(',');
      }
      if (year != null) params['year'] = year;

      final response = await _dio.get(
        '$_baseUrl/discover/movie',
        queryParameters: params,
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to discover movies: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> getNowPlaying({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/now_playing',
        queryParameters: {
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch now playing movies: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> getPopular({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/popular',
        queryParameters: {
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular movies: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> getTopRated({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/top_rated',
        queryParameters: {
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch top rated movies: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> getUpcoming({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/upcoming',
        queryParameters: {
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming movies: $e');
    }
  }

  @override
  Future<List<TMDBMovieModel>> getSimilarMovies(
    int movieId, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId/similar',
        queryParameters: {
          'page': page,
          'language': Environment.defaultLanguage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((json) => TMDBMovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch similar movies: $e');
    }
  }
}
