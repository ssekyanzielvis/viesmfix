import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/sport_event_model.dart';
import '../../core/constants/environment.dart';

/// Remote data source for sports using Supabase Edge Functions
class SportsRemoteDataSource {
  final Dio dio;
  final SupabaseClient supabase;

  // Supabase Edge Function name
  final List<String> functionNames;

  SportsRemoteDataSource({
    required this.dio,
    required this.supabase,
    String? edgeFunctionUrl,
  }) : functionNames = [
         Environment.sportsFunctionName,
         'sports',
         'sports_api',
         'sports-api',
       ];

  Future<Map<String, dynamic>> _invoke(
    String subpath,
    Map<String, dynamic> body,
  ) async {
    dynamic raw;
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

  /// Fetch live matches
  Future<List<SportEventModel>> getLiveMatches({
    String? sportType,
    String? leagueId,
    String? region,
  }) async {
    try {
      final data = await _invoke('live', {
        'sport_type': sportType,
        'league_id': leagueId,
        'region': region,
      });

      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawEvents = (root['events'] ?? root['matches']) as List?;
      if (status == 'success' || status == 'ok' || rawEvents != null) {
        final list = rawEvents ?? const [];
        final events = list
            .map((json) => SportEventModel.fromJson(json))
            .toList();
        return events;
      }
      throw Exception(data['message'] ?? 'Failed to fetch live matches');
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
      final data = await _invoke('upcoming', {
        'sport_type': sportType,
        'league_id': leagueId,
        'region': region,
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
      });

      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawEvents = (root['events'] ?? root['matches']) as List?;
      if (status == 'success' || status == 'ok' || rawEvents != null) {
        final list = rawEvents ?? const [];
        final events = list
            .map((json) => SportEventModel.fromJson(json))
            .toList();
        return events;
      }
      throw Exception(data['message'] ?? 'Failed to fetch upcoming matches');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch upcoming matches: $e');
    }
  }

  /// Get match details
  Future<SportEventModel> getMatchDetails(String matchId) async {
    try {
      final data = await _invoke('match/$matchId', {});
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final ev = (root['event'] ?? root['match']) as Map<String, dynamic>?;
      if (status == 'success' || status == 'ok' || ev != null) {
        return SportEventModel.fromJson(ev ?? root);
      }
      throw Exception(data['message'] ?? 'Failed to fetch match details');
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
      final data = await _invoke('search', {
        'query': query,
        'sport_type': sportType,
        'status': status,
        'from_date': fromDate,
        'to_date': toDate,
      });
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final respStatus = (root['status'] ?? data['status'])?.toString();
      final rawEvents = (root['events'] ?? root['matches']) as List?;
      if (respStatus == 'success' || respStatus == 'ok' || rawEvents != null) {
        final list = rawEvents ?? const [];
        final events = list
            .map((json) => SportEventModel.fromJson(json))
            .toList();
        return events;
      }
      throw Exception(data['message'] ?? 'Failed to search matches');
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
      final data = await _invoke('leagues', {
        'sport_type': sportType,
        'country': country,
      });
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawLeagues = (root['leagues'] ?? root['competitions']) as List?;
      if (status == 'success' || status == 'ok' || rawLeagues != null) {
        final list = rawLeagues ?? const [];
        final leagues = list.map((json) => LeagueModel.fromJson(json)).toList();
        return leagues;
      }
      throw Exception(data['message'] ?? 'Failed to fetch leagues');
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
      final data = await _invoke('providers', {'region': region});
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawProviders = (root['providers'] ?? root['platforms']) as List?;
      if (status == 'success' || status == 'ok' || rawProviders != null) {
        final list = rawProviders ?? const [];
        final providers = list
            .map((json) => StreamingProviderModel.fromJson(json))
            .toList();
        return providers;
      }
      throw Exception(data['message'] ?? 'Failed to fetch streaming providers');
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
      final data = await _invoke('streaming/$matchId', {'region': region});
      final root = data['data'] is Map<String, dynamic> ? data['data'] : data;
      final status = (root['status'] ?? data['status'])?.toString();
      final rawOptions = (root['options'] ?? root['streams']) as List?;
      if (status == 'success' || status == 'ok' || rawOptions != null) {
        final list = rawOptions ?? const [];
        final options = list
            .map((json) => StreamingOptionModel.fromJson(json))
            .toList();
        return options;
      }
      throw Exception(data['message'] ?? 'Failed to fetch streaming options');
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
