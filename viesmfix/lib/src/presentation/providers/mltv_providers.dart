import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/environment.dart';
import '../../services/mltv/mltv_api.dart';

final mltvSupabaseClientProvider = Provider<SupabaseClient?>((ref) {
  // Prefer dedicated MLTV Supabase if configured; otherwise fallback to primary
  final mltvUrl = Environment.supabaseMltvUrl.trim();
  final mltvKey = Environment.supabaseMltvAnonKey.trim();
  if (mltvUrl.isNotEmpty && mltvKey.isNotEmpty) {
    return SupabaseClient(mltvUrl, mltvKey);
  }
  try {
    return Supabase.instance.client;
  } catch (_) {
    // Supabase not initialized; return null so downstream can handle gracefully
    return null;
  }
});

final mltvApiProvider = Provider<MLTVApi?>((ref) {
  final client = ref.watch(mltvSupabaseClientProvider);
  if (client == null) return null;
  return MLTVApi(client);
});

// Example data providers to quickly use MLTV content in UI
final mltvMoviesFirstPageProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(mltvApiProvider);
  if (api == null) {
    // Graceful fallback when Supabase is not configured
    return const <Map<String, dynamic>>[];
  }
  // Prefer movies; if empty, fallback to series to avoid blank UI
  final movies = await api.getMoviesPaged(page: 1, limit: 30);
  if (movies.isNotEmpty) return movies;
  return api.getSeriesPaged(page: 1, limit: 30);
});

final mltvMovieGenresProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(mltvApiProvider);
  if (api == null) return const <String>[];
  return api.getMovieGenres();
});
