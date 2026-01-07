import 'package:equatable/equatable.dart';

class MovieEntity extends Equatable {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final bool? adult;
  final String? originalLanguage;
  final double? popularity;

  const MovieEntity({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    this.genreIds = const [],
    this.adult,
    this.originalLanguage,
    this.popularity,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    voteCount,
    releaseDate,
    genreIds,
    adult,
    originalLanguage,
    popularity,
  ];
}

class MovieDetailEntity extends MovieEntity {
  final int? runtime;
  final List<Genre> genres;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? status;
  final List<Cast> cast;
  final List<Crew> crew;
  final List<MovieEntity> similar;
  final List<Video> videos;

  const MovieDetailEntity({
    required super.id,
    required super.title,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.voteAverage,
    super.voteCount,
    super.releaseDate,
    super.genreIds,
    super.adult,
    super.originalLanguage,
    super.popularity,
    this.runtime,
    this.genres = const [],
    this.tagline,
    this.budget,
    this.revenue,
    this.status,
    this.cast = const [],
    this.crew = const [],
    this.similar = const [],
    this.videos = const [],
  });

  @override
  List<Object?> get props => [
    ...super.props,
    runtime,
    genres,
    tagline,
    budget,
    revenue,
    status,
    cast,
    crew,
    similar,
    videos,
  ];
}

class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}

class Cast extends Equatable {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int? order;

  const Cast({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order,
  });

  @override
  List<Object?> get props => [id, name, character, profilePath, order];
}

class Crew extends Equatable {
  final int id;
  final String name;
  final String? job;
  final String? department;
  final String? profilePath;

  const Crew({
    required this.id,
    required this.name,
    this.job,
    this.department,
    this.profilePath,
  });

  @override
  List<Object?> get props => [id, name, job, department, profilePath];
}

class Video extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int size;

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.size,
  });

  @override
  List<Object> get props => [id, key, name, site, type, size];
}
