import 'dart:convert';

/// Cached movie model for local database
class CachedMovieModel {
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final bool adult;
  final List<String>? genres;
  final int? runtime;
  final DateTime cachedAt;

  CachedMovieModel({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.adult = false,
    this.genres,
    this.runtime,
    required this.cachedAt,
  });

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'popularity': popularity,
      'adult': adult ? 1 : 0,
      'genres': genres != null ? jsonEncode(genres) : null,
      'runtime': runtime,
      'cached_at': cachedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory CachedMovieModel.fromMap(Map<String, dynamic> map) {
    return CachedMovieModel(
      id: map['id'] as int,
      title: map['title'] as String,
      originalTitle: map['original_title'] as String?,
      overview: map['overview'] as String?,
      posterPath: map['poster_path'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      releaseDate: map['release_date'] as String?,
      voteAverage: map['vote_average'] as double?,
      voteCount: map['vote_count'] as int?,
      popularity: map['popularity'] as double?,
      adult: (map['adult'] as int) == 1,
      genres: map['genres'] != null
          ? List<String>.from(jsonDecode(map['genres'] as String))
          : null,
      runtime: map['runtime'] as int?,
      cachedAt: DateTime.parse(map['cached_at'] as String),
    );
  }

  /// Copy with method
  CachedMovieModel copyWith({
    int? id,
    String? title,
    String? originalTitle,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    double? popularity,
    bool? adult,
    List<String>? genres,
    int? runtime,
    DateTime? cachedAt,
  }) {
    return CachedMovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      popularity: popularity ?? this.popularity,
      adult: adult ?? this.adult,
      genres: genres ?? this.genres,
      runtime: runtime ?? this.runtime,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}
