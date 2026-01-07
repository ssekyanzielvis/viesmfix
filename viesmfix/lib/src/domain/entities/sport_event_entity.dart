import 'package:equatable/equatable.dart';

/// Sport event entity representing a live or upcoming sports event
class SportEventEntity extends Equatable {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final League league;
  final SportType sportType;
  final DateTime startTime;
  final EventStatus status;
  final Score? score;
  final String? venue;
  final String? region;
  final List<StreamingOption> streamingOptions;
  final bool isBookmarked;
  final bool hasNotification;

  const SportEventEntity({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    required this.league,
    required this.sportType,
    required this.startTime,
    required this.status,
    this.score,
    this.venue,
    this.region,
    this.streamingOptions = const [],
    this.isBookmarked = false,
    this.hasNotification = false,
  });

  bool get isLive => status == EventStatus.live;
  bool get isUpcoming => status == EventStatus.upcoming;
  bool get isFinished => status == EventStatus.finished;

  Duration get timeUntilStart => startTime.difference(DateTime.now());
  bool get startsToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  SportEventEntity copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    String? homeTeamLogo,
    String? awayTeamLogo,
    League? league,
    SportType? sportType,
    DateTime? startTime,
    EventStatus? status,
    Score? score,
    String? venue,
    String? region,
    List<StreamingOption>? streamingOptions,
    bool? isBookmarked,
    bool? hasNotification,
  }) {
    return SportEventEntity(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      league: league ?? this.league,
      sportType: sportType ?? this.sportType,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      score: score ?? this.score,
      venue: venue ?? this.venue,
      region: region ?? this.region,
      streamingOptions: streamingOptions ?? this.streamingOptions,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNotification: hasNotification ?? this.hasNotification,
    );
  }

  @override
  List<Object?> get props => [
    id,
    homeTeam,
    awayTeam,
    homeTeamLogo,
    awayTeamLogo,
    league,
    sportType,
    startTime,
    status,
    score,
    venue,
    region,
    streamingOptions,
    isBookmarked,
    hasNotification,
  ];
}

/// League entity
class League extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String? country;
  final SportType sportType;

  const League({
    required this.id,
    required this.name,
    this.logo,
    this.country,
    required this.sportType,
  });

  @override
  List<Object?> get props => [id, name, logo, country, sportType];
}

/// Sport type enum
enum SportType {
  football('football', 'Football'),
  netball('netball', 'Netball'),
  volleyball('volleyball', 'Volleyball'),
  racing('racing', 'Racing'),
  swimming('swimming', 'Swimming'),
  basketball('basketball', 'Basketball'),
  tennis('tennis', 'Tennis'),
  cricket('cricket', 'Cricket'),
  rugby('rugby', 'Rugby'),
  hockey('hockey', 'Hockey');

  final String key;
  final String displayName;

  const SportType(this.key, this.displayName);

  static SportType fromKey(String key) {
    return SportType.values.firstWhere(
      (type) => type.key.toLowerCase() == key.toLowerCase(),
      orElse: () => SportType.football,
    );
  }
}

/// Event status enum
enum EventStatus {
  upcoming('upcoming', 'Upcoming'),
  live('live', 'Live'),
  halftime('halftime', 'Half Time'),
  finished('finished', 'Finished'),
  postponed('postponed', 'Postponed'),
  cancelled('cancelled', 'Cancelled');

  final String key;
  final String displayName;

  const EventStatus(this.key, this.displayName);

  static EventStatus fromKey(String key) {
    return EventStatus.values.firstWhere(
      (status) => status.key.toLowerCase() == key.toLowerCase(),
      orElse: () => EventStatus.upcoming,
    );
  }
}

/// Score entity
class Score extends Equatable {
  final int homeScore;
  final int awayScore;
  final String? period; // e.g., "1st Half", "3rd Quarter"
  final String? time; // e.g., "45:00", "Q3 10:23"

  const Score({
    required this.homeScore,
    required this.awayScore,
    this.period,
    this.time,
  });

  @override
  List<Object?> get props => [homeScore, awayScore, period, time];
}

/// Streaming option entity
class StreamingOption extends Equatable {
  final String id;
  final StreamingProvider provider;
  final String? deepLink; // e.g., peacocktv://sports/live/12345
  final String? webLink;
  final bool requiresSubscription;
  final double? subscriptionPrice;
  final List<String> availableRegions;
  final StreamingType type;

  const StreamingOption({
    required this.id,
    required this.provider,
    this.deepLink,
    this.webLink,
    this.requiresSubscription = true,
    this.subscriptionPrice,
    this.availableRegions = const [],
    this.type = StreamingType.live,
  });

  bool isAvailableInRegion(String region) {
    return availableRegions.isEmpty || availableRegions.contains(region);
  }

  @override
  List<Object?> get props => [
    id,
    provider,
    deepLink,
    webLink,
    requiresSubscription,
    subscriptionPrice,
    availableRegions,
    type,
  ];
}

/// Streaming provider entity
class StreamingProvider extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String? appStoreUrl;
  final String? playStoreUrl;
  final String? webUrl;
  final ProviderType type;

  const StreamingProvider({
    required this.id,
    required this.name,
    this.logo,
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.type = ProviderType.subscription,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    logo,
    appStoreUrl,
    playStoreUrl,
    webUrl,
    type,
  ];
}

/// Provider type enum
enum ProviderType {
  subscription('subscription', 'Subscription'),
  freeToAir('free_to_air', 'Free to Air'),
  payPerView('pay_per_view', 'Pay Per View'),
  cable('cable', 'Cable TV');

  final String key;
  final String displayName;

  const ProviderType(this.key, this.displayName);

  static ProviderType fromKey(String key) {
    return ProviderType.values.firstWhere(
      (type) => type.key == key,
      orElse: () => ProviderType.subscription,
    );
  }
}

/// Streaming type enum
enum StreamingType {
  live('live', 'Live'),
  replay('replay', 'Replay'),
  highlights('highlights', 'Highlights');

  final String key;
  final String displayName;

  const StreamingType(this.key, this.displayName);

  static StreamingType fromKey(String key) {
    return StreamingType.values.firstWhere(
      (type) => type.key == key,
      orElse: () => StreamingType.live,
    );
  }
}

/// User preferences for sports
class UserSportsPreferences extends Equatable {
  final List<League> favoriteLeagues;
  final List<SportType> favoriteSports;
  final String? region;
  final bool notifyOnMatchStart;
  final bool notifyOnScoreUpdate;
  final bool notifyOnFreeStream;

  const UserSportsPreferences({
    this.favoriteLeagues = const [],
    this.favoriteSports = const [],
    this.region,
    this.notifyOnMatchStart = true,
    this.notifyOnScoreUpdate = false,
    this.notifyOnFreeStream = true,
  });

  UserSportsPreferences copyWith({
    List<League>? favoriteLeagues,
    List<SportType>? favoriteSports,
    String? region,
    bool? notifyOnMatchStart,
    bool? notifyOnScoreUpdate,
    bool? notifyOnFreeStream,
  }) {
    return UserSportsPreferences(
      favoriteLeagues: favoriteLeagues ?? this.favoriteLeagues,
      favoriteSports: favoriteSports ?? this.favoriteSports,
      region: region ?? this.region,
      notifyOnMatchStart: notifyOnMatchStart ?? this.notifyOnMatchStart,
      notifyOnScoreUpdate: notifyOnScoreUpdate ?? this.notifyOnScoreUpdate,
      notifyOnFreeStream: notifyOnFreeStream ?? this.notifyOnFreeStream,
    );
  }

  @override
  List<Object?> get props => [
    favoriteLeagues,
    favoriteSports,
    region,
    notifyOnMatchStart,
    notifyOnScoreUpdate,
    notifyOnFreeStream,
  ];
}
