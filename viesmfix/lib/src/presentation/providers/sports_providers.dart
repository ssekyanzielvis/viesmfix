import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../../domain/repositories/sports_repository.dart';
import '../../domain/usecases/sports_usecases.dart';
import '../../data/datasources/sports_remote_datasource.dart';
import '../../data/datasources/sports_local_datasource.dart';
import '../../data/repositories/sports_repository_impl.dart';

// Shared Dio provider
final dioProvider = Provider<Dio>((ref) => Dio());

// Data sources
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sportsRemoteDataSourceProvider = Provider<SportsRemoteDataSource>((ref) {
  return SportsRemoteDataSource(
    dio: ref.watch(dioProvider),
    supabase: ref.watch(supabaseClientProvider),
  );
});

final sportsLocalDataSourceProvider = Provider<SportsLocalDataSource>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized first');
});

// Repository
final sportsRepositoryProvider = Provider<SportsRepository>((ref) {
  return SportsRepositoryImpl(
    remoteDataSource: ref.watch(sportsRemoteDataSourceProvider),
    localDataSource: ref.watch(sportsLocalDataSourceProvider),
  );
});

// Use cases
final sportsUseCasesProvider = Provider<SportsUseCases>((ref) {
  return SportsUseCases(ref.watch(sportsRepositoryProvider));
});

// Available leagues provider
final availableLeaguesProvider = FutureProvider<List<League>>((ref) async {
  final result = await ref.watch(sportsUseCasesProvider).getLeagues();
  return result.fold((_) => <League>[], (leagues) => leagues);
});

// State providers for live matches
class LiveMatchesNotifier
    extends StateNotifier<AsyncValue<List<SportEventEntity>>> {
  final SportsUseCases useCases;

  LiveMatchesNotifier(this.useCases) : super(const AsyncValue.loading()) {
    fetchLiveMatches();
  }

  Future<void> fetchLiveMatches({
    SportType? sportType,
    League? league,
    String? region,
  }) async {
    state = const AsyncValue.loading();
    final result = await useCases.getLiveMatches(
      sportType: sportType,
      league: league,
      region: region,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (matches) => state = AsyncValue.data(matches),
    );
  }

  void refresh() {
    fetchLiveMatches();
  }
}

final liveMatchesProvider =
    StateNotifierProvider<
      LiveMatchesNotifier,
      AsyncValue<List<SportEventEntity>>
    >((ref) {
      return LiveMatchesNotifier(ref.watch(sportsUseCasesProvider));
    });

// State provider for upcoming matches
class UpcomingMatchesNotifier
    extends StateNotifier<AsyncValue<List<SportEventEntity>>> {
  final SportsUseCases useCases;
  SportType? currentSportType;
  League? currentLeague;
  int currentPage = 1;

  UpcomingMatchesNotifier(this.useCases) : super(const AsyncValue.loading()) {
    fetchUpcomingMatches();
  }

  Future<void> fetchUpcomingMatches({
    SportType? sportType,
    League? league,
    String? region,
    DateTime? fromDate,
    DateTime? toDate,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      currentPage = 1;
      currentSportType = sportType;
      currentLeague = league;
      state = const AsyncValue.loading();
    }

    final result = await useCases.getUpcomingMatches(
      sportType: sportType ?? currentSportType,
      league: league ?? currentLeague,
      region: region,
      fromDate: fromDate,
      toDate: toDate,
      page: currentPage,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (matches) {
        if (loadMore) {
          state.whenData((currentMatches) {
            state = AsyncValue.data([...currentMatches, ...matches]);
          });
          currentPage++;
        } else {
          state = AsyncValue.data(matches);
        }
      },
    );
  }

  void loadMore() {
    currentPage++;
    fetchUpcomingMatches(loadMore: true);
  }

  void refresh() {
    currentPage = 1;
    fetchUpcomingMatches();
  }
}

final upcomingMatchesProvider =
    StateNotifierProvider<
      UpcomingMatchesNotifier,
      AsyncValue<List<SportEventEntity>>
    >((ref) {
      return UpcomingMatchesNotifier(ref.watch(sportsUseCasesProvider));
    });

// State provider for my matches (personalized)
class MyMatchesNotifier
    extends StateNotifier<AsyncValue<List<SportEventEntity>>> {
  final SportsUseCases useCases;

  MyMatchesNotifier(this.useCases) : super(const AsyncValue.loading()) {
    fetchMyMatches();
  }

  Future<void> fetchMyMatches({EventStatus? status}) async {
    state = const AsyncValue.loading();
    final result = await useCases.getMyMatches(status: status);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (matches) => state = AsyncValue.data(matches),
    );
  }

  void refresh() {
    fetchMyMatches();
  }
}

final myMatchesProvider =
    StateNotifierProvider<
      MyMatchesNotifier,
      AsyncValue<List<SportEventEntity>>
    >((ref) {
      return MyMatchesNotifier(ref.watch(sportsUseCasesProvider));
    });

// State provider for match details
final matchDetailsProvider = FutureProvider.family<SportEventEntity, String>((
  ref,
  matchId,
) async {
  final useCases = ref.watch(sportsUseCasesProvider);
  final result = await useCases.getMatchDetails(matchId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (match) => match,
  );
});

// State provider for search
class MatchSearchNotifier
    extends StateNotifier<AsyncValue<List<SportEventEntity>>> {
  final SportsUseCases useCases;

  MatchSearchNotifier(this.useCases) : super(const AsyncValue.data([]));

  Future<void> search({
    required String query,
    SportType? sportType,
    EventStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    final result = await useCases.searchMatches(
      query: query,
      sportType: sportType,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (matches) => state = AsyncValue.data(matches),
    );
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final matchSearchProvider =
    StateNotifierProvider<
      MatchSearchNotifier,
      AsyncValue<List<SportEventEntity>>
    >((ref) {
      return MatchSearchNotifier(ref.watch(sportsUseCasesProvider));
    });

// Provider for leagues
final leaguesProvider = FutureProvider.family<List<League>, SportType?>((
  ref,
  sportType,
) async {
  final useCases = ref.watch(sportsUseCasesProvider);
  final result = await useCases.getLeagues(sportType: sportType);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (leagues) => leagues,
  );
});

// Provider for streaming providers
final streamingProvidersProvider = FutureProvider<List<StreamingProvider>>((
  ref,
) async {
  final useCases = ref.watch(sportsUseCasesProvider);
  final result = await useCases.getStreamingProviders();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (providers) => providers,
  );
});

// Provider for streaming options for a match
final streamingOptionsProvider =
    FutureProvider.family<List<StreamingOption>, String>((ref, matchId) async {
      final useCases = ref.watch(sportsUseCasesProvider);
      final result = await useCases.getStreamingOptions(matchId: matchId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (options) => options,
      );
    });

// Provider for bookmarked matches
final bookmarkedMatchesProvider = FutureProvider<List<SportEventEntity>>((
  ref,
) async {
  final useCases = ref.watch(sportsUseCasesProvider);
  final result = await useCases.getBookmarkedMatches();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (matches) => matches,
  );
});

// Provider for user preferences
final userSportsPreferencesProvider = FutureProvider<UserSportsPreferences>((
  ref,
) async {
  final useCases = ref.watch(sportsUseCasesProvider);
  final result = await useCases.getUserPreferences();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (prefs) => prefs,
  );
});

// Real-time providers
final matchUpdatesStreamProvider =
    StreamProvider.family<SportEventEntity, String>((ref, matchId) {
      final useCases = ref.watch(sportsUseCasesProvider);
      return useCases.subscribeToMatchUpdates(matchId);
    });

final liveMatchesStreamProvider =
    StreamProvider.autoDispose<List<SportEventEntity>>((ref) {
      return ref.watch(sportsUseCasesProvider).subscribeToLiveMatches();
    });

// Helper provider to check if match is bookmarked
final isMatchBookmarkedProvider = FutureProvider.family<bool, String>((
  ref,
  matchId,
) async {
  final bookmarkedMatches = await ref.watch(bookmarkedMatchesProvider.future);
  return bookmarkedMatches.any((match) => match.id == matchId);
});

// Selected sport type filter provider
final selectedSportTypeProvider = StateProvider<SportType?>((ref) => null);

// Selected league filter provider
final selectedLeagueProvider = StateProvider<League?>((ref) => null);

// User region provider
final userRegionProvider = StateProvider<String?>((ref) => 'US');
