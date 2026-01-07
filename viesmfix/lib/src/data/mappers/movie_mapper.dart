import '../../domain/entities/movie_entity.dart';
import '../models/remote/tmdb_movie_model.dart';

class MovieMapper {
  static MovieEntity fromTMDBModel(TMDBMovieModel model) {
    return MovieEntity(
      id: model.id,
      title: model.title,
      overview: model.overview,
      posterPath: model.posterPath,
      backdropPath: model.backdropPath,
      voteAverage: model.voteAverage,
      voteCount: model.voteCount,
      releaseDate: model.releaseDate,
      genreIds: model.genreIds ?? [],
      adult: model.adult,
      originalLanguage: model.originalLanguage,
      popularity: model.popularity,
    );
  }

  static MovieDetailEntity fromTMDBDetailModel(TMDBMovieDetailModel model) {
    return MovieDetailEntity(
      id: model.id,
      title: model.title,
      overview: model.overview,
      posterPath: model.posterPath,
      backdropPath: model.backdropPath,
      voteAverage: model.voteAverage,
      voteCount: model.voteCount,
      releaseDate: model.releaseDate,
      genreIds: model.genreIds ?? [],
      adult: model.adult,
      originalLanguage: model.originalLanguage,
      popularity: model.popularity,
      runtime: model.runtime,
      genres:
          model.genres?.map((g) => Genre(id: g.id, name: g.name)).toList() ??
          [],
      tagline: model.tagline,
      budget: model.budget,
      revenue: model.revenue,
      status: model.status,
      cast:
          model.credits?.cast
              ?.map(
                (c) => Cast(
                  id: c.id,
                  name: c.name,
                  character: c.character,
                  profilePath: c.profilePath,
                  order: c.order,
                ),
              )
              .toList() ??
          [],
      crew:
          model.credits?.crew
              ?.map(
                (c) => Crew(
                  id: c.id,
                  name: c.name,
                  job: c.job,
                  department: c.department,
                  profilePath: c.profilePath,
                ),
              )
              .toList() ??
          [],
      similar: model.similar?.results.map(fromTMDBModel).toList() ?? [],
      videos:
          model.videos?.results
              ?.map(
                (v) => Video(
                  id: v.id,
                  key: v.key,
                  name: v.name,
                  site: v.site,
                  type: v.type,
                  size: v.size,
                ),
              )
              .toList() ??
          [],
    );
  }

  static List<MovieEntity> fromTMDBModelList(List<TMDBMovieModel> models) {
    return models.map(fromTMDBModel).toList();
  }
}
