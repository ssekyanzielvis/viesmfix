import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../app_providers.dart';

/// Search query state provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search filter state providers
final searchGenreFilterProvider = StateProvider<List<int>>((ref) => []);
final searchYearFilterProvider = StateProvider<int?>((ref) => null);
final searchRatingFilterProvider = StateProvider<double?>((ref) => null);
final searchSortByProvider = StateProvider<String>((ref) => 'popularity.desc');

/// Search results provider
final searchResultsProvider = FutureProvider.autoDispose<List<MovieEntity>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty || query.length < 2) {
    return [];
  }

  final useCase = ref.watch(searchMoviesProvider);
  return await useCase(query);
});

/// Search suggestions provider
final searchSuggestionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  // TODO: Implement search suggestions from local cache or backend
  // For now, return empty list
  return [];
});

/// Recent searches provider
final recentSearchesProvider = StateProvider<List<String>>((ref) {
  // TODO: Load from shared preferences
  return [];
});

/// Add to recent searches action
void addToRecentSearches(WidgetRef ref, String query) {
  if (query.isEmpty) return;

  final recent = ref.read(recentSearchesProvider);
  final updated = [query, ...recent.where((s) => s != query).take(9)].toList();

  ref.read(recentSearchesProvider.notifier).state = updated;
  // TODO: Save to shared preferences
}

/// Clear recent searches action
void clearRecentSearches(WidgetRef ref) {
  ref.read(recentSearchesProvider.notifier).state = [];
  // TODO: Clear from shared preferences
}
