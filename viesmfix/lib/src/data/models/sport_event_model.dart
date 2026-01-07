import '../../domain/entities/sport_event_entity.dart';

/// Sport event model for JSON serialization
class SportEventModel {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final LeagueModel league;
  final String sportType;
  final String startTime;
  final String status;
  final ScoreModel? score;
  final String? venue;
  final String? region;
  final List<StreamingOptionModel> streamingOptions;

  SportEventModel({
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
  });

  factory SportEventModel.fromJson(Map<String, dynamic> json) {
    return SportEventModel(
      id: json['id']?.toString() ?? '',
      homeTeam: json['home_team'] ?? json['homeTeam'] ?? '',
      awayTeam: json['away_team'] ?? json['awayTeam'] ?? '',
      homeTeamLogo: json['home_team_logo'] ?? json['homeTeamLogo'],
      awayTeamLogo: json['away_team_logo'] ?? json['awayTeamLogo'],
      league: LeagueModel.fromJson(json['league'] ?? {}),
      sportType: json['sport_type'] ?? json['sportType'] ?? 'football',
      startTime:
          json['start_time'] ??
          json['startTime'] ??
          DateTime.now().toIso8601String(),
      status: json['status'] ?? 'upcoming',
      score: json['score'] != null ? ScoreModel.fromJson(json['score']) : null,
      venue: json['venue'],
      region: json['region'],
      streamingOptions:
          (json['streaming_options'] ?? json['streamingOptions'] ?? [])
              .map<StreamingOptionModel>(
                (option) => StreamingOptionModel.fromJson(option),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'home_team_logo': homeTeamLogo,
      'away_team_logo': awayTeamLogo,
      'league': league.toJson(),
      'sport_type': sportType,
      'start_time': startTime,
      'status': status,
      'score': score?.toJson(),
      'venue': venue,
      'region': region,
      'streaming_options': streamingOptions.map((o) => o.toJson()).toList(),
    };
  }

  SportEventEntity toEntity({
    bool isBookmarked = false,
    bool hasNotification = false,
  }) {
    return SportEventEntity(
      id: id,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamLogo: homeTeamLogo,
      awayTeamLogo: awayTeamLogo,
      league: league.toEntity(),
      sportType: SportType.fromKey(sportType),
      startTime: DateTime.tryParse(startTime) ?? DateTime.now(),
      status: EventStatus.fromKey(status),
      score: score?.toEntity(),
      venue: venue,
      region: region,
      streamingOptions: streamingOptions.map((o) => o.toEntity()).toList(),
      isBookmarked: isBookmarked,
      hasNotification: hasNotification,
    );
  }

  factory SportEventModel.fromEntity(SportEventEntity entity) {
    return SportEventModel(
      id: entity.id,
      homeTeam: entity.homeTeam,
      awayTeam: entity.awayTeam,
      homeTeamLogo: entity.homeTeamLogo,
      awayTeamLogo: entity.awayTeamLogo,
      league: LeagueModel.fromEntity(entity.league),
      sportType: entity.sportType.key,
      startTime: entity.startTime.toIso8601String(),
      status: entity.status.key,
      score: entity.score != null ? ScoreModel.fromEntity(entity.score!) : null,
      venue: entity.venue,
      region: entity.region,
      streamingOptions: entity.streamingOptions
          .map((o) => StreamingOptionModel.fromEntity(o))
          .toList(),
    );
  }
}

/// League model
class LeagueModel {
  final String id;
  final String name;
  final String? logo;
  final String? country;
  final String sportType;

  LeagueModel({
    required this.id,
    required this.name,
    this.logo,
    this.country,
    required this.sportType,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      country: json['country'],
      sportType: json['sport_type'] ?? json['sportType'] ?? 'football',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'country': country,
      'sport_type': sportType,
    };
  }

  League toEntity() {
    return League(
      id: id,
      name: name,
      logo: logo,
      country: country,
      sportType: SportType.fromKey(sportType),
    );
  }

  factory LeagueModel.fromEntity(League entity) {
    return LeagueModel(
      id: entity.id,
      name: entity.name,
      logo: entity.logo,
      country: entity.country,
      sportType: entity.sportType.key,
    );
  }
}

/// Score model
class ScoreModel {
  final int homeScore;
  final int awayScore;
  final String? period;
  final String? time;

  ScoreModel({
    required this.homeScore,
    required this.awayScore,
    this.period,
    this.time,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      homeScore: json['home_score'] ?? json['homeScore'] ?? 0,
      awayScore: json['away_score'] ?? json['awayScore'] ?? 0,
      period: json['period'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home_score': homeScore,
      'away_score': awayScore,
      'period': period,
      'time': time,
    };
  }

  Score toEntity() {
    return Score(
      homeScore: homeScore,
      awayScore: awayScore,
      period: period,
      time: time,
    );
  }

  factory ScoreModel.fromEntity(Score entity) {
    return ScoreModel(
      homeScore: entity.homeScore,
      awayScore: entity.awayScore,
      period: entity.period,
      time: entity.time,
    );
  }
}

/// Streaming option model
class StreamingOptionModel {
  final String id;
  final StreamingProviderModel provider;
  final String? deepLink;
  final String? webLink;
  final bool requiresSubscription;
  final double? subscriptionPrice;
  final List<String> availableRegions;
  final String type;

  StreamingOptionModel({
    required this.id,
    required this.provider,
    this.deepLink,
    this.webLink,
    this.requiresSubscription = true,
    this.subscriptionPrice,
    this.availableRegions = const [],
    this.type = 'live',
  });

  factory StreamingOptionModel.fromJson(Map<String, dynamic> json) {
    return StreamingOptionModel(
      id: json['id']?.toString() ?? '',
      provider: StreamingProviderModel.fromJson(json['provider'] ?? {}),
      deepLink: json['deep_link'] ?? json['deepLink'],
      webLink: json['web_link'] ?? json['webLink'],
      requiresSubscription:
          json['requires_subscription'] ?? json['requiresSubscription'] ?? true,
      subscriptionPrice:
          json['subscription_price'] ?? json['subscriptionPrice'],
      availableRegions: List<String>.from(
        json['available_regions'] ?? json['availableRegions'] ?? [],
      ),
      type: json['type'] ?? 'live',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider.toJson(),
      'deep_link': deepLink,
      'web_link': webLink,
      'requires_subscription': requiresSubscription,
      'subscription_price': subscriptionPrice,
      'available_regions': availableRegions,
      'type': type,
    };
  }

  StreamingOption toEntity() {
    return StreamingOption(
      id: id,
      provider: provider.toEntity(),
      deepLink: deepLink,
      webLink: webLink,
      requiresSubscription: requiresSubscription,
      subscriptionPrice: subscriptionPrice,
      availableRegions: availableRegions,
      type: StreamingType.fromKey(type),
    );
  }

  factory StreamingOptionModel.fromEntity(StreamingOption entity) {
    return StreamingOptionModel(
      id: entity.id,
      provider: StreamingProviderModel.fromEntity(entity.provider),
      deepLink: entity.deepLink,
      webLink: entity.webLink,
      requiresSubscription: entity.requiresSubscription,
      subscriptionPrice: entity.subscriptionPrice,
      availableRegions: entity.availableRegions,
      type: entity.type.key,
    );
  }
}

/// Streaming provider model
class StreamingProviderModel {
  final String id;
  final String name;
  final String? logo;
  final String? appStoreUrl;
  final String? playStoreUrl;
  final String? webUrl;
  final String type;

  StreamingProviderModel({
    required this.id,
    required this.name,
    this.logo,
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.type = 'subscription',
  });

  factory StreamingProviderModel.fromJson(Map<String, dynamic> json) {
    return StreamingProviderModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      appStoreUrl: json['app_store_url'] ?? json['appStoreUrl'],
      playStoreUrl: json['play_store_url'] ?? json['playStoreUrl'],
      webUrl: json['web_url'] ?? json['webUrl'],
      type: json['type'] ?? 'subscription',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'app_store_url': appStoreUrl,
      'play_store_url': playStoreUrl,
      'web_url': webUrl,
      'type': type,
    };
  }

  StreamingProvider toEntity() {
    return StreamingProvider(
      id: id,
      name: name,
      logo: logo,
      appStoreUrl: appStoreUrl,
      playStoreUrl: playStoreUrl,
      webUrl: webUrl,
      type: ProviderType.fromKey(type),
    );
  }

  factory StreamingProviderModel.fromEntity(StreamingProvider entity) {
    return StreamingProviderModel(
      id: entity.id,
      name: entity.name,
      logo: entity.logo,
      appStoreUrl: entity.appStoreUrl,
      playStoreUrl: entity.playStoreUrl,
      webUrl: entity.webUrl,
      type: entity.type.key,
    );
  }
}
