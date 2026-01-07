import 'package:equatable/equatable.dart';

/// Entity representing a movie trivia question
class TriviaQuestionEntity extends Equatable {
  final String id;
  final int movieId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final TriviaCategory category;
  final TriviaDifficulty difficulty;
  final String? explanation;
  final int pointsReward;

  const TriviaQuestionEntity({
    required this.id,
    required this.movieId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
    this.explanation,
    required this.pointsReward,
  });

  @override
  List<Object?> get props => [
    id,
    movieId,
    question,
    options,
    correctAnswerIndex,
    category,
    difficulty,
    explanation,
    pointsReward,
  ];
}

/// Category of trivia question
enum TriviaCategory {
  plot,
  cast,
  quotes,
  soundtrack,
  behindTheScenes,
  awards,
  locations,
  easterEggs,
}

/// Difficulty level
enum TriviaDifficulty {
  easy(10, '🟢'),
  medium(20, '🟡'),
  hard(30, '🔴'),
  expert(50, '💎');

  final int points;
  final String emoji;
  const TriviaDifficulty(this.points, this.emoji);
}

/// User's trivia attempt
class TriviaAttemptEntity extends Equatable {
  final String id;
  final String userId;
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final DateTime timestamp;
  final int timeSpentSeconds;

  const TriviaAttemptEntity({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.timestamp,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    questionId,
    selectedAnswerIndex,
    isCorrect,
    timestamp,
    timeSpentSeconds,
  ];
}

/// Trivia quiz session
class TriviaQuizEntity extends Equatable {
  final String id;
  final int movieId;
  final String movieTitle;
  final List<TriviaQuestionEntity> questions;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalScore;
  final int correctAnswers;

  const TriviaQuizEntity({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.questions,
    required this.startTime,
    this.endTime,
    this.totalScore = 0,
    this.correctAnswers = 0,
  });

  int get totalQuestions => questions.length;
  double get accuracyPercentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  Duration get timeTaken => endTime?.difference(startTime) ?? Duration.zero;

  @override
  List<Object?> get props => [
    id,
    movieId,
    movieTitle,
    questions,
    startTime,
    endTime,
    totalScore,
    correctAnswers,
  ];

  TriviaQuizEntity copyWith({
    String? id,
    int? movieId,
    String? movieTitle,
    List<TriviaQuestionEntity>? questions,
    DateTime? startTime,
    DateTime? endTime,
    int? totalScore,
    int? correctAnswers,
  }) {
    return TriviaQuizEntity(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      questions: questions ?? this.questions,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalScore: totalScore ?? this.totalScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
}

/// Trivia leaderboard entry
class TriviaLeaderboardEntry extends Equatable {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalScore;
  final int quizzesCompleted;
  final double averageAccuracy;
  final int rank;
  final int streak;

  const TriviaLeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.averageAccuracy,
    required this.rank,
    this.streak = 0,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    avatarUrl,
    totalScore,
    quizzesCompleted,
    averageAccuracy,
    rank,
    streak,
  ];
}
