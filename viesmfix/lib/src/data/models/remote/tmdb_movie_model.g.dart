// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_movie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TMDBMovieModel _$TMDBMovieModelFromJson(Map<String, dynamic> json) =>
    TMDBMovieModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      adult: json['adult'] as bool?,
      originalLanguage: json['original_language'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TMDBMovieModelToJson(TMDBMovieModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'release_date': instance.releaseDate,
      'genre_ids': instance.genreIds,
      'adult': instance.adult,
      'original_language': instance.originalLanguage,
      'popularity': instance.popularity,
    };

TMDBMovieListResponse _$TMDBMovieListResponseFromJson(
  Map<String, dynamic> json,
) => TMDBMovieListResponse(
  page: (json['page'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => TMDBMovieModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalPages: (json['total_pages'] as num).toInt(),
  totalResults: (json['total_results'] as num).toInt(),
);

Map<String, dynamic> _$TMDBMovieListResponseToJson(
  TMDBMovieListResponse instance,
) => <String, dynamic>{
  'page': instance.page,
  'results': instance.results,
  'total_pages': instance.totalPages,
  'total_results': instance.totalResults,
};

TMDBMovieDetailModel _$TMDBMovieDetailModelFromJson(
  Map<String, dynamic> json,
) => TMDBMovieDetailModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  overview: json['overview'] as String?,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
  voteCount: (json['vote_count'] as num?)?.toInt(),
  releaseDate: json['release_date'] as String?,
  genreIds: (json['genre_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  adult: json['adult'] as bool?,
  originalLanguage: json['original_language'] as String?,
  popularity: (json['popularity'] as num?)?.toDouble(),
  runtime: (json['runtime'] as num?)?.toInt(),
  genres: (json['genres'] as List<dynamic>?)
      ?.map((e) => TMDBGenreModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  tagline: json['tagline'] as String?,
  budget: (json['budget'] as num?)?.toInt(),
  revenue: (json['revenue'] as num?)?.toInt(),
  status: json['status'] as String?,
  credits: json['credits'] == null
      ? null
      : TMDBCreditsModel.fromJson(json['credits'] as Map<String, dynamic>),
  videos: json['videos'] == null
      ? null
      : TMDBVideosModel.fromJson(json['videos'] as Map<String, dynamic>),
  similar: json['similar'] == null
      ? null
      : TMDBMovieListResponse.fromJson(json['similar'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TMDBMovieDetailModelToJson(
  TMDBMovieDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
  'vote_average': instance.voteAverage,
  'vote_count': instance.voteCount,
  'release_date': instance.releaseDate,
  'genre_ids': instance.genreIds,
  'adult': instance.adult,
  'original_language': instance.originalLanguage,
  'popularity': instance.popularity,
  'runtime': instance.runtime,
  'genres': instance.genres,
  'tagline': instance.tagline,
  'budget': instance.budget,
  'revenue': instance.revenue,
  'status': instance.status,
  'credits': instance.credits,
  'videos': instance.videos,
  'similar': instance.similar,
};

TMDBGenreModel _$TMDBGenreModelFromJson(Map<String, dynamic> json) =>
    TMDBGenreModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$TMDBGenreModelToJson(TMDBGenreModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

TMDBCreditsModel _$TMDBCreditsModelFromJson(Map<String, dynamic> json) =>
    TMDBCreditsModel(
      cast: (json['cast'] as List<dynamic>?)
          ?.map((e) => TMDBCastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      crew: (json['crew'] as List<dynamic>?)
          ?.map((e) => TMDBCrewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TMDBCreditsModelToJson(TMDBCreditsModel instance) =>
    <String, dynamic>{'cast': instance.cast, 'crew': instance.crew};

TMDBCastModel _$TMDBCastModelFromJson(Map<String, dynamic> json) =>
    TMDBCastModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
      order: (json['order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TMDBCastModelToJson(TMDBCastModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'character': instance.character,
      'profile_path': instance.profilePath,
      'order': instance.order,
    };

TMDBCrewModel _$TMDBCrewModelFromJson(Map<String, dynamic> json) =>
    TMDBCrewModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      job: json['job'] as String?,
      department: json['department'] as String?,
      profilePath: json['profile_path'] as String?,
    );

Map<String, dynamic> _$TMDBCrewModelToJson(TMDBCrewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'job': instance.job,
      'department': instance.department,
      'profile_path': instance.profilePath,
    };

TMDBVideosModel _$TMDBVideosModelFromJson(Map<String, dynamic> json) =>
    TMDBVideosModel(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => TMDBVideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TMDBVideosModelToJson(TMDBVideosModel instance) =>
    <String, dynamic>{'results': instance.results};

TMDBVideoModel _$TMDBVideoModelFromJson(Map<String, dynamic> json) =>
    TMDBVideoModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$TMDBVideoModelToJson(TMDBVideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'name': instance.name,
      'site': instance.site,
      'type': instance.type,
      'size': instance.size,
    };
