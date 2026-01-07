import 'package:flutter/material.dart';
import '../widgets/movie_card.dart';
import '../../domain/entities/movie_entity.dart';

class MovieGridView extends StatelessWidget {
  final List<MovieEntity> movies;
  final void Function(MovieEntity) onMovieTap;
  final EdgeInsets padding;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const MovieGridView({
    super.key,
    required this.movies,
    required this.onMovieTap,
    this.padding = const EdgeInsets.all(16),
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(movie: movie, onTap: () => onMovieTap(movie));
      },
    );
  }
}

class SliverMovieGrid extends StatelessWidget {
  final List<MovieEntity> movies;
  final void Function(MovieEntity) onMovieTap;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const SliverMovieGrid({
    super.key,
    required this.movies,
    required this.onMovieTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final movie = movies[index];
        return MovieCard(movie: movie, onTap: () => onMovieTap(movie));
      }, childCount: movies.length),
    );
  }
}
