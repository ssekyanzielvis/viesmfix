import 'package:equatable/equatable.dart';

/// Entity representing a journal entry about a movie
class CinematicJournalEntry extends Equatable {
  final String id;
  final String userId;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final DateTime watchedOn;
  final double? rating;
  final String? thoughts;
  final List<String> emotions; // happy, sad, inspired, shocked, etc.
  final List<String> memorableQuotes;
  final List<JournalMoment> moments;
  final String? videoReactionUrl;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CinematicJournalEntry({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.watchedOn,
    this.rating,
    this.thoughts,
    this.emotions = const [],
    this.memorableQuotes = const [],
    this.moments = const [],
    this.videoReactionUrl,
    this.tags = const [],
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    movieId,
    movieTitle,
    moviePosterPath,
    watchedOn,
    rating,
    thoughts,
    emotions,
    memorableQuotes,
    moments,
    videoReactionUrl,
    tags,
    isPublic,
    createdAt,
    updatedAt,
  ];

  CinematicJournalEntry copyWith({
    String? id,
    String? userId,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    DateTime? watchedOn,
    double? rating,
    String? thoughts,
    List<String>? emotions,
    List<String>? memorableQuotes,
    List<JournalMoment>? moments,
    String? videoReactionUrl,
    List<String>? tags,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CinematicJournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      watchedOn: watchedOn ?? this.watchedOn,
      rating: rating ?? this.rating,
      thoughts: thoughts ?? this.thoughts,
      emotions: emotions ?? this.emotions,
      memorableQuotes: memorableQuotes ?? this.memorableQuotes,
      moments: moments ?? this.moments,
      videoReactionUrl: videoReactionUrl ?? this.videoReactionUrl,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// A specific moment/scene from the movie
class JournalMoment extends Equatable {
  final String id;
  final int timestampSeconds;
  final String description;
  final String emotion;
  final DateTime createdAt;

  const JournalMoment({
    required this.id,
    required this.timestampSeconds,
    required this.description,
    required this.emotion,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    timestampSeconds,
    description,
    emotion,
    createdAt,
  ];
}

/// Predefined emotions
class JournalEmotions {
  static const List<String> all = [
    'Happy',
    'Sad',
    'Excited',
    'Inspired',
    'Shocked',
    'Scared',
    'Angry',
    'Moved',
    'Thoughtful',
    'Nostalgic',
    'Amazed',
    'Confused',
  ];

  static const Map<String, String> emojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Excited': '🤩',
    'Inspired': '💡',
    'Shocked': '😱',
    'Scared': '😨',
    'Angry': '😠',
    'Moved': '🥺',
    'Thoughtful': '🤔',
    'Nostalgic': '🌅',
    'Amazed': '😮',
    'Confused': '😕',
  };
}
