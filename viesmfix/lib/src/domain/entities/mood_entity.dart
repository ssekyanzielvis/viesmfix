import 'package:equatable/equatable.dart';

/// Represents user's current mood for movie recommendations
enum MoodType {
  happy('Happy', '😊', 'Uplifting, fun, feel-good movies'),
  sad('Sad', '😢', 'Emotional, deep, thought-provoking films'),
  anxious('Anxious', '😰', 'Calming, soothing, light-hearted content'),
  romantic(
    'Romantic',
    '💕',
    'Love stories, romantic comedies, heartwarming films',
  ),
  adventurous(
    'Adventurous',
    '🗺️',
    'Action-packed, thrilling, exciting adventures',
  ),
  thoughtful(
    'Thoughtful',
    '🤔',
    'Intellectual, philosophical, mind-bending films',
  ),
  energetic(
    'Energetic',
    '⚡',
    'Fast-paced, high-energy, adrenaline-pumping movies',
  ),
  nostalgic(
    'Nostalgic',
    '🌅',
    'Classic films, retro vibes, comforting favorites',
  ),
  curious('Curious', '🔍', 'Mysteries, documentaries, eye-opening stories'),
  scared('Scared', '👻', 'Horror, thriller, suspenseful content');

  final String label;
  final String emoji;
  final String description;

  const MoodType(this.label, this.emoji, this.description);
}

/// Entity representing a mood entry with timestamp
class MoodEntity extends Equatable {
  final String id;
  final String userId;
  final MoodType mood;
  final DateTime timestamp;
  final List<int>? recommendedMovieIds;
  final String? notes;

  const MoodEntity({
    required this.id,
    required this.userId,
    required this.mood,
    required this.timestamp,
    this.recommendedMovieIds,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    mood,
    timestamp,
    recommendedMovieIds,
    notes,
  ];

  MoodEntity copyWith({
    String? id,
    String? userId,
    MoodType? mood,
    DateTime? timestamp,
    List<int>? recommendedMovieIds,
    String? notes,
  }) {
    return MoodEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      recommendedMovieIds: recommendedMovieIds ?? this.recommendedMovieIds,
      notes: notes ?? this.notes,
    );
  }
}

/// Mood analytics data
class MoodAnalytics extends Equatable {
  final Map<MoodType, int> moodFrequency;
  final MoodType? dominantMood;
  final List<MoodEntity> recentMoods;
  final Map<MoodType, List<int>> favoriteMoviesByMood;

  const MoodAnalytics({
    required this.moodFrequency,
    this.dominantMood,
    required this.recentMoods,
    required this.favoriteMoviesByMood,
  });

  @override
  List<Object?> get props => [
    moodFrequency,
    dominantMood,
    recentMoods,
    favoriteMoviesByMood,
  ];
}
