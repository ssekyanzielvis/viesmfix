import 'package:json_annotation/json_annotation.dart';

part 'tmdb_movie_model.g.dart';

@JsonSerializable()
class TMDBMovieModel {
  final int id;
  final String title;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  final bool? adult;
  @JsonKey(name: 'original_language')
  final String? originalLanguage;
  final double? popularity;

  TMDBMovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    this.genreIds,
    this.adult,
    this.originalLanguage,
    this.popularity,
  });

  factory TMDBMovieModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBMovieModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBMovieModelToJson(this);
}

@JsonSerializable()
class TMDBMovieListResponse {
  final int page;
  final List<TMDBMovieModel> results;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;

  TMDBMovieListResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDBMovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$TMDBMovieListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBMovieListResponseToJson(this);
}

@JsonSerializable()
class TMDBMovieDetailModel extends TMDBMovieModel {
  final int? runtime;
  final List<TMDBGenreModel>? genres;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? status;
  final TMDBCreditsModel? credits;
  final TMDBVideosModel? videos;
  final TMDBMovieListResponse? similar;

  TMDBMovieDetailModel({
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
    this.genres,
    this.tagline,
    this.budget,
    this.revenue,
    this.status,
    this.credits,
    this.videos,
    this.similar,
  });

  factory TMDBMovieDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBMovieDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TMDBMovieDetailModelToJson(this);
}

@JsonSerializable()
class TMDBGenreModel {
  final int id;
  final String name;

  TMDBGenreModel({required this.id, required this.name});

  factory TMDBGenreModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBGenreModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBGenreModelToJson(this);
}

@JsonSerializable()
class TMDBCreditsModel {
  final List<TMDBCastModel>? cast;
  final List<TMDBCrewModel>? crew;

  TMDBCreditsModel({this.cast, this.crew});

  factory TMDBCreditsModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBCreditsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBCreditsModelToJson(this);
}

@JsonSerializable()
class TMDBCastModel {
  final int id;
  final String name;
  final String? character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final int? order;

  TMDBCastModel({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order,
  });

  factory TMDBCastModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBCastModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBCastModelToJson(this);
}

@JsonSerializable()
class TMDBCrewModel {
  final int id;
  final String name;
  final String? job;
  final String? department;
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  TMDBCrewModel({
    required this.id,
    required this.name,
    this.job,
    this.department,
    this.profilePath,
  });

  factory TMDBCrewModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBCrewModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBCrewModelToJson(this);
}

@JsonSerializable()
class TMDBVideosModel {
  final List<TMDBVideoModel>? results;

  TMDBVideosModel({this.results});

  factory TMDBVideosModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBVideosModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBVideosModelToJson(this);
}

@JsonSerializable()
class TMDBVideoModel {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int size;

  TMDBVideoModel({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.size,
  });

  factory TMDBVideoModel.fromJson(Map<String, dynamic> json) =>
      _$TMDBVideoModelFromJson(json);
  Map<String, dynamic> toJson() => _$TMDBVideoModelToJson(this);
}
