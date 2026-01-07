import 'package:dartz/dartz.dart';
import '../entities/sport_event_entity.dart';
import '../repositories/sports_repository.dart';
import '../../core/errors/failures.dart';

/// Use cases for sports feature
class SportsUseCases {
  final SportsRepository repository;

  SportsUseCases(this.repository);

  /// Get live matches use case
  Future<Either<Failure, List<SportEventEntity>>> getLiveMatches({
    SportType? sportType,
    League? league,
    String? region,
  }) {
    return repository.getLiveMatches(
      sportType: sportType,
      league: league,
      region: region,
    );
  }

  /// Get upcoming matches use case
  Future<Either<Failure, List<SportEventEntity>>> getUpcomingMatches({
    SportType? sportType,
    League? league,
    String? region,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getUpcomingMatches(
      sportType: sportType,
      league: league,
      region: region,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get match details use case
  Future<Either<Failure, SportEventEntity>> getMatchDetails(String matchId) {
    return repository.getMatchDetails(matchId);
  }

  /// Search matches use case
  Future<Either<Failure, List<SportEventEntity>>> searchMatches({
    required String query,
    SportType? sportType,
    EventStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return repository.searchMatches(
      query: query,
      sportType: sportType,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Get matches by league use case
  Future<Either<Failure, List<SportEventEntity>>> getMatchesByLeague({
    required String leagueId,
    EventStatus? status,
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getMatchesByLeague(
      leagueId: leagueId,
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get leagues use case
  Future<Either<Failure, List<League>>> getLeagues({
    SportType? sportType,
    String? country,
  }) {
    return repository.getLeagues(sportType: sportType, country: country);
  }

  /// Get streaming providers use case
  Future<Either<Failure, List<StreamingProvider>>> getStreamingProviders({
    String? region,
  }) {
    return repository.getStreamingProviders(region: region);
  }

  /// Get streaming options use case
  Future<Either<Failure, List<StreamingOption>>> getStreamingOptions({
    required String matchId,
    String? region,
  }) {
    return repository.getStreamingOptions(matchId: matchId, region: region);
  }

  /// Bookmark match use case
  Future<Either<Failure, void>> bookmarkMatch(SportEventEntity match) {
    return repository.bookmarkMatch(match);
  }

  /// Remove bookmark use case
  Future<Either<Failure, void>> removeBookmark(String matchId) {
    return repository.removeBookmark(matchId);
  }

  /// Get bookmarked matches use case
  Future<Either<Failure, List<SportEventEntity>>> getBookmarkedMatches() {
    return repository.getBookmarkedMatches();
  }

  /// Toggle bookmark use case
  Future<Either<Failure, void>> toggleBookmark(SportEventEntity match) async {
    final isBookmarked = await repository.isMatchBookmarked(match.id);
    return isBookmarked.fold((failure) => Left(failure), (bookmarked) {
      if (bookmarked) {
        return repository.removeBookmark(match.id);
      } else {
        return repository.bookmarkMatch(match);
      }
    });
  }

  /// Enable notification use case
  Future<Either<Failure, void>> enableNotification(String matchId) {
    return repository.enableNotification(matchId);
  }

  /// Disable notification use case
  Future<Either<Failure, void>> disableNotification(String matchId) {
    return repository.disableNotification(matchId);
  }

  /// Toggle notification use case
  Future<Either<Failure, void>> toggleNotification(
    SportEventEntity match,
  ) async {
    if (match.hasNotification) {
      return repository.disableNotification(match.id);
    } else {
      return repository.enableNotification(match.id);
    }
  }

  /// Get user preferences use case
  Future<Either<Failure, UserSportsPreferences>> getUserPreferences() {
    return repository.getUserPreferences();
  }

  /// Update user preferences use case
  Future<Either<Failure, void>> updateUserPreferences(
    UserSportsPreferences preferences,
  ) {
    return repository.updateUserPreferences(preferences);
  }

  /// Add favorite league use case
  Future<Either<Failure, void>> addFavoriteLeague(League league) async {
    final prefsResult = await repository.getUserPreferences();
    return prefsResult.fold((failure) => Left(failure), (prefs) {
      final updatedLeagues = List<League>.from(prefs.favoriteLeagues);
      if (!updatedLeagues.any((l) => l.id == league.id)) {
        updatedLeagues.add(league);
        return repository.updateUserPreferences(
          prefs.copyWith(favoriteLeagues: updatedLeagues),
        );
      }
      return const Right(null);
    });
  }

  /// Remove favorite league use case
  Future<Either<Failure, void>> removeFavoriteLeague(String leagueId) async {
    final prefsResult = await repository.getUserPreferences();
    return prefsResult.fold((failure) => Left(failure), (prefs) {
      final updatedLeagues = prefs.favoriteLeagues
          .where((l) => l.id != leagueId)
          .toList();
      return repository.updateUserPreferences(
        prefs.copyWith(favoriteLeagues: updatedLeagues),
      );
    });
  }

  /// Add favorite sport use case
  Future<Either<Failure, void>> addFavoriteSport(SportType sport) async {
    final prefsResult = await repository.getUserPreferences();
    return prefsResult.fold((failure) => Left(failure), (prefs) {
      final updatedSports = List<SportType>.from(prefs.favoriteSports);
      if (!updatedSports.contains(sport)) {
        updatedSports.add(sport);
        return repository.updateUserPreferences(
          prefs.copyWith(favoriteSports: updatedSports),
        );
      }
      return const Right(null);
    });
  }

  /// Remove favorite sport use case
  Future<Either<Failure, void>> removeFavoriteSport(SportType sport) async {
    final prefsResult = await repository.getUserPreferences();
    return prefsResult.fold((failure) => Left(failure), (prefs) {
      final updatedSports = prefs.favoriteSports
          .where((s) => s != sport)
          .toList();
      return repository.updateUserPreferences(
        prefs.copyWith(favoriteSports: updatedSports),
      );
    });
  }

  /// Subscribe to match updates use case
  Stream<SportEventEntity> subscribeToMatchUpdates(String matchId) {
    return repository.subscribeToMatchUpdates(matchId);
  }

  /// Subscribe to live matches use case
  Stream<List<SportEventEntity>> subscribeToLiveMatches({
    SportType? sportType,
    League? league,
  }) {
    return repository.subscribeToLiveMatches(
      sportType: sportType,
      league: league,
    );
  }

  /// Get my matches (based on user preferences) use case
  Future<Either<Failure, List<SportEventEntity>>> getMyMatches({
    EventStatus? status,
  }) async {
    final prefsResult = await repository.getUserPreferences();
    return prefsResult.fold((failure) => Left(failure), (prefs) async {
      // Get matches from favorite leagues
      final List<SportEventEntity> allMatches = [];

      for (final league in prefs.favoriteLeagues) {
        final matchesResult = await repository.getMatchesByLeague(
          leagueId: league.id,
          status: status,
        );
        matchesResult.fold(
          (failure) => null,
          (matches) => allMatches.addAll(matches),
        );
      }

      // Remove duplicates
      final uniqueMatches = <String, SportEventEntity>{};
      for (final match in allMatches) {
        uniqueMatches[match.id] = match;
      }

      return Right(uniqueMatches.values.toList());
    });
  }

  /// Clear cache use case
  Future<Either<Failure, void>> clearCache() {
    return repository.clearCache();
  }
}
