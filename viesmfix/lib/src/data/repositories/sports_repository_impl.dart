import 'package:dartz/dartz.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../../domain/repositories/sports_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/sports_remote_datasource.dart';
import '../datasources/sports_local_datasource.dart';
import '../models/sport_event_model.dart';

class SportsRepositoryImpl implements SportsRepository {
  final SportsRemoteDataSource remoteDataSource;
  final SportsLocalDataSource localDataSource;

  SportsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SportEventEntity>>> getLiveMatches({
    SportType? sportType,
    League? league,
    String? region,
  }) async {
    try {
      // Generate cache key
      final cacheKey =
          'live_${sportType?.key ?? 'all'}_${league?.id ?? 'all'}_${region ?? 'all'}';

      // Try to get from cache first (short cache for live events)
      final cachedEvents = await localDataSource.getCachedEvents(cacheKey);
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        final entities = await _modelsToEntities(cachedEvents);
        return Right(entities);
      }

      // Fetch from remote
      final events = await remoteDataSource.getLiveMatches(
        sportType: sportType?.key,
        leagueId: league?.id,
        region: region,
      );

      // Cache the results
      await localDataSource.cacheEvents(cacheKey, events);

      // Convert to entities
      final entities = await _modelsToEntities(events);
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportEventEntity>>> getUpcomingMatches({
    SportType? sportType,
    League? league,
    String? region,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Generate cache key
      final cacheKey =
          'upcoming_${sportType?.key ?? 'all'}_${league?.id ?? 'all'}_$page';

      // Try to get from cache first
      final cachedEvents = await localDataSource.getCachedEvents(cacheKey);
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        final entities = await _modelsToEntities(cachedEvents);
        return Right(entities);
      }

      // Fetch from remote
      final events = await remoteDataSource.getUpcomingMatches(
        sportType: sportType?.key,
        leagueId: league?.id,
        region: region,
        fromDate: fromDate?.toIso8601String(),
        toDate: toDate?.toIso8601String(),
        page: page,
        pageSize: pageSize,
      );

      // Cache the results
      await localDataSource.cacheEvents(cacheKey, events);

      // Convert to entities
      final entities = await _modelsToEntities(events);
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SportEventEntity>> getMatchDetails(
    String matchId,
  ) async {
    try {
      final event = await remoteDataSource.getMatchDetails(matchId);
      final isBookmarked = await localDataSource.isMatchBookmarked(matchId);
      final hasNotification = await localDataSource.hasNotification(matchId);

      return Right(
        event.toEntity(
          isBookmarked: isBookmarked,
          hasNotification: hasNotification,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportEventEntity>>> searchMatches({
    required String query,
    SportType? sportType,
    EventStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final events = await remoteDataSource.searchMatches(
        query: query,
        sportType: sportType?.key,
        status: status?.key,
        fromDate: fromDate?.toIso8601String(),
        toDate: toDate?.toIso8601String(),
      );

      final entities = await _modelsToEntities(events);
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportEventEntity>>> getMatchesByLeague({
    required String leagueId,
    EventStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // This would be implemented based on your API
      // For now, using upcoming matches with league filter
      final result = await getUpcomingMatches(
        league: League(id: leagueId, name: '', sportType: SportType.football),
        page: page,
        pageSize: pageSize,
      );

      return result.fold((failure) => Left(failure), (events) {
        if (status != null) {
          final filtered = events.where((e) => e.status == status).toList();
          return Right(filtered);
        }
        return Right(events);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<League>>> getLeagues({
    SportType? sportType,
    String? country,
  }) async {
    try {
      final leagues = await remoteDataSource.getLeagues(
        sportType: sportType?.key,
        country: country,
      );

      final entities = leagues.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StreamingProvider>>> getStreamingProviders({
    String? region,
  }) async {
    try {
      final providers = await remoteDataSource.getStreamingProviders(
        region: region,
      );

      final entities = providers.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StreamingOption>>> getStreamingOptions({
    required String matchId,
    String? region,
  }) async {
    try {
      final options = await remoteDataSource.getStreamingOptions(
        matchId: matchId,
        region: region,
      );

      final entities = options.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bookmarkMatch(SportEventEntity match) async {
    try {
      final model = SportEventModel.fromEntity(match);
      final matchData = {
        'id': match.id,
        'matchId': match.id,
        'homeTeam': match.homeTeam,
        'awayTeam': match.awayTeam,
        'homeTeamLogo': match.homeTeamLogo,
        'awayTeamLogo': match.awayTeamLogo,
        'league': model.league.toJson(),
        'sportType': match.sportType.key,
        'startTime': match.startTime.toIso8601String(),
        'status': match.status.key,
        'score': match.score != null
            ? ScoreModel.fromEntity(match.score!).toJson()
            : null,
        'venue': match.venue,
        'region': match.region,
      };

      await localDataSource.bookmarkMatch(matchData);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String matchId) async {
    try {
      await localDataSource.removeBookmark(matchId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportEventEntity>>> getBookmarkedMatches() async {
    try {
      final bookmarks = await localDataSource.getBookmarks();

      final entities = bookmarks.map((json) {
        final model = SportEventModel.fromJson(json);
        return model.toEntity(isBookmarked: true);
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isMatchBookmarked(String matchId) async {
    try {
      final isBookmarked = await localDataSource.isMatchBookmarked(matchId);
      return Right(isBookmarked);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enableNotification(String matchId) async {
    try {
      await localDataSource.enableNotification(matchId);
      // TODO: Schedule actual notification
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disableNotification(String matchId) async {
    try {
      await localDataSource.disableNotification(matchId);
      // TODO: Cancel scheduled notification
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSportsPreferences>> getUserPreferences() async {
    try {
      final prefs = await localDataSource.getUserPreferences();

      if (prefs == null) {
        return const Right(UserSportsPreferences());
      }

      // favoriteLeagueIds can be used to hydrate League objects if needed.
      // For now, we'll ignore them and rely on empty list.
      // final favoriteLeagueIds = prefs['favoriteLeagues'] as List?;
      final favoriteSportKeys = prefs['favoriteSports'] as List?;

      return Right(
        UserSportsPreferences(
          favoriteLeagues: [], // Would need to fetch league details
          favoriteSports:
              favoriteSportKeys
                  ?.map((key) => SportType.fromKey(key.toString()))
                  .toList() ??
              [],
          region: prefs['region'] as String?,
          notifyOnMatchStart: prefs['notifyOnMatchStart'] as bool? ?? true,
          notifyOnScoreUpdate: prefs['notifyOnScoreUpdate'] as bool? ?? false,
          notifyOnFreeStream: prefs['notifyOnFreeStream'] as bool? ?? true,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserPreferences(
    UserSportsPreferences preferences,
  ) async {
    try {
      final prefsData = {
        'favoriteLeagues': preferences.favoriteLeagues
            .map((l) => l.id)
            .toList(),
        'favoriteSports': preferences.favoriteSports.map((s) => s.key).toList(),
        'region': preferences.region,
        'notifyOnMatchStart': preferences.notifyOnMatchStart,
        'notifyOnScoreUpdate': preferences.notifyOnScoreUpdate,
        'notifyOnFreeStream': preferences.notifyOnFreeStream,
      };

      await localDataSource.saveUserPreferences(prefsData);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<SportEventEntity> subscribeToMatchUpdates(String matchId) {
    return remoteDataSource.subscribeToMatchUpdates(matchId).asyncMap((
      model,
    ) async {
      final isBookmarked = await localDataSource.isMatchBookmarked(matchId);
      final hasNotification = await localDataSource.hasNotification(matchId);
      return model.toEntity(
        isBookmarked: isBookmarked,
        hasNotification: hasNotification,
      );
    });
  }

  @override
  Stream<List<SportEventEntity>> subscribeToLiveMatches({
    SportType? sportType,
    League? league,
  }) {
    return remoteDataSource
        .subscribeToLiveMatches(sportType: sportType?.key, leagueId: league?.id)
        .asyncMap((models) async {
          return await _modelsToEntities(models);
        });
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Helper method to convert models to entities with bookmark and notification status
  Future<List<SportEventEntity>> _modelsToEntities(
    List<SportEventModel> models,
  ) async {
    final List<SportEventEntity> entities = [];

    for (final model in models) {
      final isBookmarked = await localDataSource.isMatchBookmarked(model.id);
      final hasNotification = await localDataSource.hasNotification(model.id);
      entities.add(
        model.toEntity(
          isBookmarked: isBookmarked,
          hasNotification: hasNotification,
        ),
      );
    }

    return entities;
  }
}
