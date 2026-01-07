import 'package:equatable/equatable.dart';

/// Entity representing user's movie taste profile
class MovieDNAEntity extends Equatable {
  final String userId;
  final Map<String, double> genrePreferences; // genre -> preference score 0-1
  final Map<String, int> actorFrequency; // actor name -> count
  final Map<String, int> directorFrequency; // director name -> count
  final Map<int, int> decadePreferences; // decade -> count
  final Map<String, double> moodPreferences; // mood -> preference score
  final List<String> favoriteKeywords; // common themes/keywords
  final double averageRating;
  final double ratingVariance;
  final MoviePersonality personality;
  final DateTime lastUpdated;

  const MovieDNAEntity({
    required this.userId,
    required this.genrePreferences,
    required this.actorFrequency,
    required this.directorFrequency,
    required this.decadePreferences,
    required this.moodPreferences,
    required this.favoriteKeywords,
    required this.averageRating,
    required this.ratingVariance,
    required this.personality,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    userId,
    genrePreferences,
    actorFrequency,
    directorFrequency,
    decadePreferences,
    moodPreferences,
    favoriteKeywords,
    averageRating,
    ratingVariance,
    personality,
    lastUpdated,
  ];

  MovieDNAEntity copyWith({
    String? userId,
    Map<String, double>? genrePreferences,
    Map<String, int>? actorFrequency,
    Map<String, int>? directorFrequency,
    Map<int, int>? decadePreferences,
    Map<String, double>? moodPreferences,
    List<String>? favoriteKeywords,
    double? averageRating,
    double? ratingVariance,
    MoviePersonality? personality,
    DateTime? lastUpdated,
  }) {
    return MovieDNAEntity(
      userId: userId ?? this.userId,
      genrePreferences: genrePreferences ?? this.genrePreferences,
      actorFrequency: actorFrequency ?? this.actorFrequency,
      directorFrequency: directorFrequency ?? this.directorFrequency,
      decadePreferences: decadePreferences ?? this.decadePreferences,
      moodPreferences: moodPreferences ?? this.moodPreferences,
      favoriteKeywords: favoriteKeywords ?? this.favoriteKeywords,
      averageRating: averageRating ?? this.averageRating,
      ratingVariance: ratingVariance ?? this.ratingVariance,
      personality: personality ?? this.personality,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// User's movie personality type
enum MoviePersonality {
  theExplorer(
    'The Explorer',
    '🗺️',
    'You love discovering new genres and hidden gems',
    ['Adventurous', 'Open-minded', 'Curious'],
  ),
  theClassicist(
    'The Classicist',
    '🎭',
    'You appreciate timeless cinema and golden age films',
    ['Traditional', 'Refined', 'Nostalgic'],
  ),
  theBlockbusterFan(
    'The Blockbuster Fan',
    '💥',
    'You enjoy big-budget spectacles and popular hits',
    ['Mainstream', 'Entertaining', 'Social'],
  ),
  theCritic(
    'The Critic',
    '🎬',
    'You have discerning taste and appreciate artistry',
    ['Analytical', 'Selective', 'Thoughtful'],
  ),
  theEmotional(
    'The Emotional',
    '💖',
    'You connect deeply with character-driven stories',
    ['Empathetic', 'Feeling', 'Character-focused'],
  ),
  theThrillerSeeker(
    'The Thriller Seeker',
    '🎢',
    'You crave suspense, twists, and adrenaline',
    ['Bold', 'Intense', 'Edge-seeking'],
  ),
  theComedyLover(
    'The Comedy Lover',
    '😂',
    'You watch movies to laugh and feel good',
    ['Lighthearted', 'Fun-loving', 'Optimistic'],
  ),
  theIntellectual(
    'The Intellectual',
    '🧠',
    'You prefer thought-provoking and complex narratives',
    ['Deep-thinking', 'Philosophical', 'Challenging'],
  );

  final String title;
  final String emoji;
  final String description;
  final List<String> traits;

  const MoviePersonality(this.title, this.emoji, this.description, this.traits);
}

/// Taste comparison between two users
class TasteMatchEntity extends Equatable {
  final String userId;
  final String otherUserId;
  final String otherUsername;
  final String? otherAvatarUrl;
  final double matchPercentage;
  final Map<String, double> commonGenres;
  final List<int> sharedFavorites;
  final List<String> commonInterests;
  final TasteMatchLevel matchLevel;

  const TasteMatchEntity({
    required this.userId,
    required this.otherUserId,
    required this.otherUsername,
    this.otherAvatarUrl,
    required this.matchPercentage,
    required this.commonGenres,
    required this.sharedFavorites,
    required this.commonInterests,
    required this.matchLevel,
  });

  @override
  List<Object?> get props => [
    userId,
    otherUserId,
    otherUsername,
    otherAvatarUrl,
    matchPercentage,
    commonGenres,
    sharedFavorites,
    commonInterests,
    matchLevel,
  ];
}

/// Match level
enum TasteMatchLevel {
  soulmate(90, '💫', 'Movie Soulmates'),
  excellent(75, '⭐', 'Excellent Match'),
  good(60, '👍', 'Good Match'),
  moderate(40, '🤝', 'Some Common Ground'),
  low(0, '🔍', 'Different Tastes');

  final int threshold;
  final String emoji;
  final String label;

  const TasteMatchLevel(this.threshold, this.emoji, this.label);

  static TasteMatchLevel fromPercentage(double percentage) {
    if (percentage >= 90) return soulmate;
    if (percentage >= 75) return excellent;
    if (percentage >= 60) return good;
    if (percentage >= 40) return moderate;
    return low;
  }
}
