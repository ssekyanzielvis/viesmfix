/// Supabase models for database entities

/// Profile model from Supabase
class SupabaseProfileModel {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseProfileModel({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.preferences,
    this.stats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseProfileModel.fromJson(Map<String, dynamic> json) {
    return SupabaseProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      stats: json['stats'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'preferences': preferences,
      'stats': stats,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Watchlist item model from Supabase
class SupabaseWatchlistItemModel {
  final String id;
  final String userId;
  final int movieId;
  final DateTime addedAt;
  final bool watched;
  final DateTime? watchedAt;
  final double? rating;
  final String? notes;
  final bool private;

  SupabaseWatchlistItemModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.addedAt,
    this.watched = false,
    this.watchedAt,
    this.rating,
    this.notes,
    this.private = false,
  });

  factory SupabaseWatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return SupabaseWatchlistItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as int,
      addedAt: DateTime.parse(json['added_at'] as String),
      watched: json['watched'] as bool? ?? false,
      watchedAt: json['watched_at'] != null
          ? DateTime.parse(json['watched_at'] as String)
          : null,
      rating: json['rating'] as double?,
      notes: json['notes'] as String?,
      private: json['private'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'added_at': addedAt.toIso8601String(),
      'watched': watched,
      'watched_at': watchedAt?.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'private': private,
    };
  }
}

/// Review model from Supabase
class SupabaseReviewModel {
  final String id;
  final String userId;
  final int movieId;
  final double rating;
  final String? title;
  final String content;
  final bool containsSpoilers;
  final int likesCount;
  final int commentsCount;
  final bool private;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseReviewModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    this.title,
    required this.content,
    this.containsSpoilers = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.private = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseReviewModel.fromJson(Map<String, dynamic> json) {
    return SupabaseReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as int,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String?,
      content: json['content'] as String,
      containsSpoilers: json['contains_spoilers'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      private: json['private'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'rating': rating,
      'title': title,
      'content': content,
      'contains_spoilers': containsSpoilers,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'private': private,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
