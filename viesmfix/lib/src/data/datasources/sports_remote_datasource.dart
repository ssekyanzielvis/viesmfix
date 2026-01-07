import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sport_event_model.dart';
import '../../core/constants/environment.dart';

/// Remote data source for sports using Supabase Edge Functions
class SportsRemoteDataSource {
  final Dio dio;
  final SupabaseClient supabase;

  // Supabase Edge Function endpoint
  final String baseUrl;

  SportsRemoteDataSource({
    required this.dio,
    required this.supabase,
    String? edgeFunctionUrl,
  }) : baseUrl =
           edgeFunctionUrl ??
           '${Environment.supabaseUrl}/functions/v1/sports-api';

  /// Fetch live matches
  Future<List<SportEventModel>> getLiveMatches({
    String? sportType,
    String? leagueId,
    String? region,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/live',
        data: {
          'sport_type': sportType,
          'league_id': leagueId,
          'region': region,
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
        if (data['status'] == 'success') {
          final events = (data['events'] as List)
              .map((json) => SportEventModel.fromJson(json))
              .toList();
          return events;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch live matches');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch live matches: $e');
    }
  }

  /// Fetch upcoming matches
  Future<List<SportEventModel>> getUpcomingMatches({
    String? sportType,
    String? leagueId,
    String? region,
    String? fromDate,
    String? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/upcoming',
        data: {
          'sport_type': sportType,
          'league_id': leagueId,
          'region': region,
          'from_date': fromDate,
          'to_date': toDate,
          'page': page,
          'page_size': pageSize,
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
        if (data['status'] == 'success') {
          final events = (data['events'] as List)
              .map((json) => SportEventModel.fromJson(json))
              .toList();
          return events;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to fetch upcoming matches',
          );
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch upcoming matches: $e');
    }
  }

  /// Get match details
  Future<SportEventModel> getMatchDetails(String matchId) async {
    try {
      final response = await dio.get(
        '$baseUrl/match/$matchId',
        options: Options(
          headers: {'Authorization': 'Bearer ${Environment.supabaseAnonKey}'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          return SportEventModel.fromJson(data['event']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch match details');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch match details: $e');
    }
  }

  /// Search matches
  Future<List<SportEventModel>> searchMatches({
    required String query,
    String? sportType,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/search',
        data: {
          'query': query,
          'sport_type': sportType,
          'status': status,
          'from_date': fromDate,
          'to_date': toDate,
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
        if (data['status'] == 'success') {
          final events = (data['events'] as List)
              .map((json) => SportEventModel.fromJson(json))
              .toList();
          return events;
        } else {
          throw Exception(data['message'] ?? 'Failed to search matches');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search matches: $e');
    }
  }

  /// Get leagues
  Future<List<LeagueModel>> getLeagues({
    String? sportType,
    String? country,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/leagues',
        data: {'sport_type': sportType, 'country': country},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          final leagues = (data['leagues'] as List)
              .map((json) => LeagueModel.fromJson(json))
              .toList();
          return leagues;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch leagues');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch leagues: $e');
    }
  }

  /// Get streaming providers
  Future<List<StreamingProviderModel>> getStreamingProviders({
    String? region,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/providers',
        data: {'region': region},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          final providers = (data['providers'] as List)
              .map((json) => StreamingProviderModel.fromJson(json))
              .toList();
          return providers;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to fetch streaming providers',
          );
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch streaming providers: $e');
    }
  }

  /// Get streaming options for a match
  Future<List<StreamingOptionModel>> getStreamingOptions({
    required String matchId,
    String? region,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/streaming/$matchId',
        data: {'region': region},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          final options = (data['options'] as List)
              .map((json) => StreamingOptionModel.fromJson(json))
              .toList();
          return options;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to fetch streaming options',
          );
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch streaming options: $e');
    }
  }

  /// Subscribe to real-time match updates
  Stream<SportEventModel> subscribeToMatchUpdates(String matchId) {
    final stream = supabase.from('sport_events').stream(primaryKey: ['id']);

    return stream.map((data) {
      final filtered = data.where((row) => row['id'] == matchId).toList();
      if (filtered.isEmpty) throw Exception('Match not found');
      return SportEventModel.fromJson(filtered.first);
    });
  }

  /// Subscribe to live matches
  Stream<List<SportEventModel>> subscribeToLiveMatches({
    String? sportType,
    String? leagueId,
  }) {
    final stream = supabase.from('sport_events').stream(primaryKey: ['id']);

    return stream.map((data) {
      Iterable<Map<String, dynamic>> rows = data;
      rows = rows.where((row) => row['status'] == 'live');
      if (sportType != null) {
        rows = rows.where((row) => row['sport_type'] == sportType);
      }
      if (leagueId != null) {
        rows = rows.where((row) => row['league_id'] == leagueId);
      }
      return rows.map((json) => SportEventModel.fromJson(json)).toList();
    });
  }
}
