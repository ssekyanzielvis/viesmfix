import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/mltv/mltv_api.dart';

final mltvSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final mltvApiProvider = Provider<MLTVApi>((ref) {
  final client = ref.watch(mltvSupabaseClientProvider);
  return MLTVApi(client);
});

// Example data providers to quickly use MLTV content in UI
final mltvMoviesFirstPageProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(mltvApiProvider);
  // Prefer movies; if empty, fallback to series to avoid blank UI
  final movies = await api.getMoviesPaged(page: 1, limit: 30);
  if (movies.isNotEmpty) return movies;
  return api.getSeriesPaged(page: 1, limit: 30);
});

final mltvMovieGenresProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(mltvApiProvider);
  return api.getMovieGenres();
});
