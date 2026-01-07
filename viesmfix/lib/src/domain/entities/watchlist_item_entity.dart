import 'package:equatable/equatable.dart';

class WatchlistItemEntity extends Equatable {
  final String id;
  final String userId;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final DateTime addedAt;
  final double? userRating;
  final bool? watched;

  const WatchlistItemEntity({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.addedAt,
    this.userRating,
    this.watched,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    movieId,
    movieTitle,
    moviePosterPath,
    addedAt,
    userRating,
    watched,
  ];
}
