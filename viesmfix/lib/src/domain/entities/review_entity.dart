import 'package:equatable/equatable.dart';

/// Entity representing a movie review
class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final int movieId;
  final String movieTitle;
  final double rating;
  final String? title;
  final String content;
  final bool containsSpoilers;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isLikedByMe;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.movieId,
    required this.movieTitle,
    required this.rating,
    this.title,
    required this.content,
    this.containsSpoilers = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isLikedByMe = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    userAvatarUrl,
    movieId,
    movieTitle,
    rating,
    title,
    content,
    containsSpoilers,
    likesCount,
    commentsCount,
    createdAt,
    updatedAt,
    isLikedByMe,
  ];

  ReviewEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    int? movieId,
    String? movieTitle,
    double? rating,
    String? title,
    String? content,
    bool? containsSpoilers,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLikedByMe,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      containsSpoilers: containsSpoilers ?? this.containsSpoilers,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
