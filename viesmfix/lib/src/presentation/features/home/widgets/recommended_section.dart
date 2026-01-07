import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../widgets/movie_card.dart';
import '../../../widgets/loading_shimmer.dart';

/// Widget for displaying personalized movie recommendations
class RecommendedSection extends ConsumerWidget {
  final Future<List<MovieEntity>>? recommendationsFuture;
  final void Function(int movieId)? onMovieTap;

  const RecommendedSection({
    super.key,
    this.recommendationsFuture,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommended For You',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (recommendationsFuture == null)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Rate some movies to get personalized recommendations!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          FutureBuilder<List<MovieEntity>>(
            future: recommendationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 5,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.all(4),
                      child: MovieCardShimmer(),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Failed to load recommendations',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }

              final movies = snapshot.data ?? [];

              if (movies.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No recommendations available yet.'),
                );
              }

              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      movie: movie,
                      width: 120,
                      height: 180,
                      onTap: () => onMovieTap?.call(movie.id),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
