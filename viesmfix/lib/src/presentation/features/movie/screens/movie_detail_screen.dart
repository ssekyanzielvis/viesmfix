import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/environment.dart';
import '../../../../services/api/tmdb_service.dart';
import '../../../providers/movie_providers.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetail = ref.watch(movieDetailsProvider(movieId));
    final tmdbService = TMDBService();

    return Scaffold(
      body: movieDetail.when(
        data: (movie) {
          final backdropUrl = tmdbService.getImageUrl(
            movie.backdropPath,
            size: Environment.imageSizes['backdrop']!,
          );
          final posterUrl = tmdbService.getImageUrl(
            movie.posterPath,
            size: Environment.imageSizes['poster']!,
          );

          return CustomScrollView(
            slivers: [
              // App Bar with Backdrop
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backdropUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: Colors.grey[900]),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Movie Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Poster Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster
                          if (posterUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: posterUrl,
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 120,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.movie, size: 48),
                            ),

                          const SizedBox(width: 16),

                          // Title and Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),

                                // Rating
                                if (movie.voteAverage != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${movie.voteAverage!.toStringAsFixed(1)}/10',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${movie.voteCount ?? 0} votes)',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 8),

                                // Release Date & Runtime
                                if (movie.releaseDate != null ||
                                    movie.runtime != null)
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (movie.releaseDate != null)
                                        Chip(
                                          label: Text(movie.releaseDate!),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      if (movie.runtime != null)
                                        Chip(
                                          label: Text('${movie.runtime} min'),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Genres
                      if (movie.genres.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: movie.genres.map((genre) {
                            return Chip(
                              label: Text(genre.name),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 24),

                      // Tagline
                      if (movie.tagline != null && movie.tagline!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${movie.tagline}"',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Overview
                      if (movie.overview != null && movie.overview!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overview',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.overview!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Cast
                      if (movie.cast.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cast',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: movie.cast.take(10).length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final castMember = movie.cast[index];
                                  final profileUrl = tmdbService.getImageUrl(
                                    castMember.profilePath,
                                    size: Environment.imageSizes['profile']!,
                                  );

                                  return SizedBox(
                                    width: 80,
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: profileUrl.isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  profileUrl,
                                                )
                                              : null,
                                          child: profileUrl.isEmpty
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          castMember.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (castMember.character != null)
                                          Text(
                                            castMember.character!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Similar Movies
                      if (movie.similar.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Similar Movies',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: movie.similar.take(10).length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final similarMovie = movie.similar[index];
                                  final similarPosterUrl = tmdbService
                                      .getImageUrl(
                                        similarMovie.posterPath,
                                        size: Environment.imageSizes['poster']!,
                                      );

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MovieDetailScreen(
                                                movieId: similarMovie.id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: similarPosterUrl.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: similarPosterUrl,
                                                    width: 120,
                                                    height: 160,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 120,
                                                    height: 160,
                                                    color: Colors.grey[900],
                                                    child: const Icon(
                                                      Icons.movie,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            similarMovie.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading movie details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
