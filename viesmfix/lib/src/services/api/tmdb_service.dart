import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../core/constants/environment.dart';
import '../../data/models/remote/tmdb_movie_model.dart';

class TMDBService {
  static const String _baseUrl = Environment.tmdbBaseUrl;
  static const String _imageBaseUrl = Environment.tmdbImageBaseUrl;

  late final Dio _dio;

  TMDBService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: Environment.apiConnectTimeout,
        receiveTimeout: Environment.apiReceiveTimeout,
        headers: {
          'Authorization': 'Bearer ${Environment.tmdbApiKey}',
          'Content-Type': 'application/json;charset=utf-8',
        },
      ),
    );

    // Add logging in debug mode
    if (Environment.isDebug) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: true,
          logPrint: (object) => developer.log(object.toString(), name: 'TMDB'),
        ),
      );
    }
  }

  // Get image URL helper
  String getImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) {
      return '';
    }
    return '$_imageBaseUrl/$size$path';
  }

  // Get trending movies
  Future<TMDBMovieListResponse> getTrendingMovies({
    String timeWindow = 'week',
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/trending/movie/$timeWindow',
        queryParameters: {'page': page, 'language': language},
      );

      return TMDBMovieListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch trending movies: $e');
    }
  }

  // Get popular movies
  Future<TMDBMovieListResponse> getPopularMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page, 'language': language},
      );

      return TMDBMovieListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch popular movies: $e');
    }
  }

  // Get upcoming movies
  Future<TMDBMovieListResponse> getUpcomingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'page': page, 'language': language},
      );

      return TMDBMovieListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch upcoming movies: $e');
    }
  }

  // Get now playing movies
  Future<TMDBMovieListResponse> getNowPlayingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {'page': page, 'language': language},
      );

      return TMDBMovieListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch now playing movies: $e');
    }
  }

  // Get movie details
  Future<TMDBMovieDetailModel> getMovieDetails(
    int movieId, {
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {
          'language': language,
          'append_to_response': 'credits,videos,similar',
        },
      );

      return TMDBMovieDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  // Search movies
  Future<TMDBMovieListResponse> searchMovies({
    required String query,
    int page = 1,
    bool includeAdult = false,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'page': page,
          'include_adult': includeAdult,
          'language': language,
        },
      );

      return TMDBMovieListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  // Discover movies with filters
  Future<TMDBMovieListResponse> discoverMovies({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    String language = 'en-US',
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'language': language};

      if (sortBy != null) params['sort_by'] = sortBy;
      if (withGenres != null && withGenres.isNotEmpty) {
        params['with_genres'] = withGenres.join(',');
      }

      final response = await _dio.get(
        '/discover/movie',
        queryParameters: params,
      );

      return TMDBMovieListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to discover movies: $e');
    }
  }

  // Get genre list
  Future<List<TMDBGenreModel>> getGenres({String language = 'en-US'}) async {
    try {
      final response = await _dio.get(
        '/genre/movie/list',
        queryParameters: {'language': language},
      );

      final genres = (response.data['genres'] as List)
          .map((json) => TMDBGenreModel.fromJson(json))
          .toList();
      return genres;
    } catch (e) {
      throw Exception('Failed to fetch genres: $e');
    }
  }
}
