import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../widgets/movie_card.dart';

class SimilarMovies extends StatelessWidget {
  final List<MovieEntity> movies;
  final Function(MovieEntity)? onMovieTap;

  const SimilarMovies({super.key, required this.movies, this.onMovieTap});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Similar Movies',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
                width: 140,
                height: 210,
              );
            },
          ),
        ),
      ],
    );
  }
}
