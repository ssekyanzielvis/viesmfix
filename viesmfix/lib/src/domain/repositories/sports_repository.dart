import 'package:dartz/dartz.dart';
import '../entities/sport_event_entity.dart';
import '../../core/errors/failures.dart';

/// Repository for sports operations
abstract class SportsRepository {
  /// Get live matches
  Future<Either<Failure, List<SportEventEntity>>> getLiveMatches({
    SportType? sportType,
    League? league,
    String? region,
  });

  /// Get upcoming matches
  Future<Either<Failure, List<SportEventEntity>>> getUpcomingMatches({
    SportType? sportType,
    League? league,
    String? region,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Get match details
  Future<Either<Failure, SportEventEntity>> getMatchDetails(String matchId);

  /// Search matches
  Future<Either<Failure, List<SportEventEntity>>> searchMatches({
    required String query,
    SportType? sportType,
    EventStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get matches by league
  Future<Either<Failure, List<SportEventEntity>>> getMatchesByLeague({
    required String leagueId,
    EventStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get all available leagues
  Future<Either<Failure, List<League>>> getLeagues({
    SportType? sportType,
    String? country,
  });

  /// Get streaming providers
  Future<Either<Failure, List<StreamingProvider>>> getStreamingProviders({
    String? region,
  });

  /// Get streaming options for a match
  Future<Either<Failure, List<StreamingOption>>> getStreamingOptions({
    required String matchId,
    String? region,
  });

  /// Bookmark a match
  Future<Either<Failure, void>> bookmarkMatch(SportEventEntity match);

  /// Remove bookmark
  Future<Either<Failure, void>> removeBookmark(String matchId);

  /// Get all bookmarked matches
  Future<Either<Failure, List<SportEventEntity>>> getBookmarkedMatches();

  /// Check if match is bookmarked
  Future<Either<Failure, bool>> isMatchBookmarked(String matchId);

  /// Enable notification for a match
  Future<Either<Failure, void>> enableNotification(String matchId);

  /// Disable notification for a match
  Future<Either<Failure, void>> disableNotification(String matchId);

  /// Get user preferences
  Future<Either<Failure, UserSportsPreferences>> getUserPreferences();

  /// Update user preferences
  Future<Either<Failure, void>> updateUserPreferences(
    UserSportsPreferences preferences,
  );

  /// Subscribe to real-time score updates
  Stream<SportEventEntity> subscribeToMatchUpdates(String matchId);

  /// Subscribe to live matches updates
  Stream<List<SportEventEntity>> subscribeToLiveMatches({
    SportType? sportType,
    League? league,
  });

  /// Clear cache
  Future<Either<Failure, void>> clearCache();
}
