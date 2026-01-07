import 'package:equatable/equatable.dart';

/// Entity representing a favorite movie (quick bookmark)
class FavoriteEntity extends Equatable {
  final String id;
  final String userId;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final DateTime addedAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    movieId,
    movieTitle,
    moviePosterPath,
    addedAt,
  ];

  FavoriteEntity copyWith({
    String? id,
    String? userId,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    DateTime? addedAt,
  }) {
    return FavoriteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
