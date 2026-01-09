import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/constants/environment.dart';
import '../../../core/errors/exceptions.dart';

class TmdbApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  late final Dio _dio;

  TmdbApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30), // Increased timeout
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer ${Environment.tmdbApiKey}',
          'Content-Type': 'application/json;charset=utf-8',
        },
      ),
    );

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        logPrint: (object) => developer.log(object.toString(), name: 'TMDB'),
      ),
    );

    // Add error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Cache-Control'] = 'public, max-age=3600';
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: ServerException('Connection timeout'),
              ),
            );
          }

          if (error.response?.statusCode == 401) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: ServerException('Unauthorized API access'),
              ),
            );
          }

          if (error.response?.statusCode == 404) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: ServerException('Resource not found'),
              ),
            );
          }

          if (error.response?.statusCode == 429) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: ServerException('Rate limit exceeded'),
              ),
            );
          }

          return handler.reject(error);
        },
      ),
    );
  }

  /// Get image URL from path
  String getImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return '$_imageBaseUrl/$size$path';
  }

  /// Get trending movies
  Future<Map<String, dynamic>> getTrendingMovies({
    String timeWindow = 'week',
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/trending/movie/$timeWindow',
        queryParameters: {'page': page, 'language': language},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get movie details
  Future<Map<String, dynamic>> getMovieDetails(
    int movieId, {
    String language = 'en-US',
    String appendToResponse = 'credits,videos,similar,recommendations',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {
          'language': language,
          'append_to_response': appendToResponse,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Search movies
  Future<Map<String, dynamic>> searchMovies({
    required String query,
    int page = 1,
    String language = 'en-US',
    bool includeAdult = false,
  }) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'page': page,
          'language': language,
          'include_adult': includeAdult,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get popular movies
  Future<Map<String, dynamic>> getPopularMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page, 'language': language},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get now playing movies
  Future<Map<String, dynamic>> getNowPlayingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {'page': page, 'language': language},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get upcoming movies
  Future<Map<String, dynamic>> getUpcomingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'page': page, 'language': language},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get top rated movies
  Future<Map<String, dynamic>> getTopRatedMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {'page': page, 'language': language},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get movies by genre
  Future<Map<String, dynamic>> getMoviesByGenre({
    required int genreId,
    int page = 1,
    String language = 'en-US',
    String sortBy = 'popularity.desc',
  }) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genreId,
          'page': page,
          'language': language,
          'sort_by': sortBy,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get movie genres
  Future<List<Map<String, dynamic>>> getGenres({
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/genre/movie/list',
        queryParameters: {'language': language},
      );

      return List<Map<String, dynamic>>.from(response.data['genres']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.error is ServerException) {
      return error.error as ServerException;
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection');
    }

    if (error.type == DioExceptionType.unknown) {
      return NetworkException('Network error occurred');
    }

    return ServerException(
      error.message ?? 'Unknown server error',
      statusCode: error.response?.statusCode,
    );
  }
}
