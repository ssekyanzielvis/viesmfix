import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../../core/constants/environment.dart';
import '../../../../services/api/tmdb_service.dart';
import '../../../providers/movie_providers.dart';
import '../../../utils/responsive.dart';

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
                expandedHeight: Responsive.appBarExpandedHeight(context),
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
                                width: Responsive.posterWidth(context),
                                height: Responsive.posterHeight(context),
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: Responsive.posterWidth(context),
                              height: Responsive.posterHeight(context),
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
                            // Actions: Watch Now + Trailer
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final region =
                                        Environment.defaultLanguage.contains(
                                          '-',
                                        )
                                        ? Environment.defaultLanguage
                                              .split('-')
                                              .last
                                        : 'US';
                                    context.pushNamed(
                                      'where-to-watch',
                                      pathParameters: {
                                        'id': movie.id.toString(),
                                      },
                                      queryParameters: {'country': region},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                      Responsive.buttonMinWidth(context),
                                      Responsive.buttonHeight(context),
                                    ),
                                  ),
                                  icon: const Icon(Icons.tv),
                                  label: const Text('Where to Watch'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showWatchOptions(context, movie),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                      Responsive.buttonMinWidth(context),
                                      Responsive.buttonHeight(context),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_circle_fill),
                                  label: const Text('Watch Now'),
                                ),
                                if (_findYoutubeTrailerKey(movie) != null)
                                  ElevatedButton.icon(
                                    onPressed: () => _openTrailer(movie),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(
                                        Responsive.buttonMinWidth(context),
                                        Responsive.buttonHeight(context),
                                      ),
                                    ),
                                    icon: const Icon(Icons.ondemand_video),
                                    label: const Text('Watch Trailer'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: Responsive.castListHeight(context),
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
                              height: Responsive.similarListHeight(context),
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

String? _findYoutubeTrailerKey(MovieDetailEntity movie) {
  final results = movie.videos;
  for (final v in results) {
    final isYoutube = v.site.toLowerCase() == 'youtube';
    final isTrailerLike =
        v.type.toLowerCase() == 'trailer' || v.type.toLowerCase() == 'teaser';
    if (isYoutube && isTrailerLike && v.key.isNotEmpty) {
      return v.key;
    }
  }
  // Fallback: first YouTube video
  for (final v in results) {
    if (v.site.toLowerCase() == 'youtube' && v.key.isNotEmpty) {
      return v.key;
    }
  }
  return null;
}

Future<void> _openTrailer(MovieDetailEntity movie) async {
  final key = _findYoutubeTrailerKey(movie);
  if (key == null) return;
  final uri = Uri.parse('https://www.youtube.com/watch?v=$key');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> _showWatchOptions(
  BuildContext context,
  MovieDetailEntity movie,
) async {
  final title = movie.title;
  // Optional: include release year to refine search
  final year = (movie.releaseDate != null && movie.releaseDate!.length >= 4)
      ? movie.releaseDate!.substring(0, 4)
      : null;

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      final tmdb = TMDBService();
      final region = Environment.defaultLanguage.contains('-')
          ? Environment.defaultLanguage.split('-').last
          : 'US';
      return FutureBuilder<Map<String, dynamic>>(
        future: tmdb.getWatchProviders(movie.id),
        builder: (context, snapshot) {
          final results = snapshot.data != null
              ? (snapshot.data!['results'] as Map<String, dynamic>?)
              : null;
          final regionData = results != null
              ? (results[region] ??
                    results['US'] ??
                    (results.isNotEmpty ? results.values.first : null))
              : null;

          List<dynamic> collectProviders(dynamic rd) {
            if (rd is Map<String, dynamic>) {
              final lists = <List<dynamic>>[];
              for (final key in ['flatrate', 'ads', 'free', 'rent', 'buy']) {
                final v = rd[key];
                if (v is List<dynamic>) lists.add(v);
              }
              return lists.expand((e) => e).toList();
            }
            return const [];
          }

          final providers = collectProviders(regionData);
          final justWatchLink = (regionData is Map<String, dynamic>)
              ? (regionData['link'] as String?)
              : null;

          String buildSearchUrl(String providerName) {
            final query = year != null ? '$title $year' : title;
            return 'https://www.google.com/search?q=' +
                Uri.encodeComponent('watch $query on $providerName');
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Watch "$title"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (providers.isNotEmpty) ...[
                    Text(
                      'Available via:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: providers.map((p) {
                        final name = (p is Map<String, dynamic>)
                            ? (p['provider_name'] as String?) ?? 'Provider'
                            : 'Provider';
                        final url = justWatchLink ?? buildSearchUrl(name);
                        return OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: Text(name),
                        );
                      }).toList(),
                    ),
                    if (justWatchLink != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(justWatchLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.tv),
                        label: const Text('Open on JustWatch'),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'Couldn\'t find availability. Try searching:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            'Netflix',
                            'Prime Video',
                            'Disney+',
                            'Hulu',
                            'Max',
                            'Apple TV',
                            'JustWatch',
                            'Google',
                          ].map((name) {
                            final url = buildSearchUrl(name);
                            return OutlinedButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: Text(name),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
