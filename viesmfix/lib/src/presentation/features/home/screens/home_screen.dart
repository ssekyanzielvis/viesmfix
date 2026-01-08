import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/movie_providers.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/movie_card.dart';
import '../../../widgets/movie_section.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../providers/mltv_providers.dart';
import '../../../widgets/mltv_card.dart';
import '../../movie/screens/movie_detail_screen.dart';
import '../../search/screens/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingMovies = ref.watch(trendingFeedProvider);
    final popularMovies = ref.watch(popularFeedProvider);
    final upcomingMovies = ref.watch(upcomingFeedProvider);
    final nowPlayingMovies = ref.watch(nowPlayingFeedProvider);
    final mltvMovies = ref.watch(mltvMoviesFirstPageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ViesMFix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'News',
            icon: const Icon(Icons.newspaper),
            onPressed: () {
              context.push('/news');
            },
          ),
          IconButton(
            tooltip: 'Sports',
            icon: const Icon(Icons.sports_soccer),
            onPressed: () {
              context.push('/sports');
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Trending Section
            trendingMovies.when(
              data: (movies) => MovieSection(
                title: 'Trending Now',
                children: movies.take(20).map((movie) {
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movieId: movie.id),
                        ),
                      );
                    },
                  );
                }).toList(),
                onSeeAll: () {
                  ref.read(trendingFeedProvider.notifier).loadMore();
                },
              ),
              loading: () => MovieSection(
                title: 'Trending Now',
                children: List.generate(5, (index) => const MovieCardShimmer()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading trending movies: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // MLTV Latest Section
            mltvMovies.when(
              data: (items) => items.isEmpty
                  ? const SizedBox.shrink()
                  : MovieSection(
                      title: 'From MLTV',
                      children: items.take(20).map((m) {
                        return MLTVCard(
                          item: m,
                          width: 120,
                          height: 180,
                          onTap: () {
                            // TODO: navigate to MLTV detail when wired
                          },
                        );
                      }).toList(),
                    ),
              loading: () => MovieSection(
                title: 'From MLTV',
                children: List.generate(
                  5,
                  (index) => const SizedBox(
                    width: 120,
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('MLTV error: $error'),
              ),
            ),

            // Popular Section
            popularMovies.when(
              data: (movies) => MovieSection(
                title: 'Popular',
                children: movies.take(20).map((movie) {
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movieId: movie.id),
                        ),
                      );
                    },
                  );
                }).toList(),
                onSeeAll: () {
                  ref.read(popularFeedProvider.notifier).loadMore();
                },
              ),
              loading: () => MovieSection(
                title: 'Popular',
                children: List.generate(5, (index) => const MovieCardShimmer()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading popular movies: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // Upcoming Section
            upcomingMovies.when(
              data: (movies) => MovieSection(
                title: 'Coming Soon',
                children: movies.take(20).map((movie) {
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movieId: movie.id),
                        ),
                      );
                    },
                  );
                }).toList(),
                onSeeAll: () {
                  ref.read(upcomingFeedProvider.notifier).loadMore();
                },
              ),
              loading: () => MovieSection(
                title: 'Coming Soon',
                children: List.generate(5, (index) => const MovieCardShimmer()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading upcoming movies: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // Now Playing Section
            nowPlayingMovies.when(
              data: (movies) => MovieSection(
                title: 'Now Playing',
                children: movies.take(20).map((movie) {
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movieId: movie.id),
                        ),
                      );
                    },
                  );
                }).toList(),
                onSeeAll: () {
                  ref.read(nowPlayingFeedProvider.notifier).loadMore();
                },
              ),
              loading: () => MovieSection(
                title: 'Now Playing',
                children: List.generate(5, (index) => const MovieCardShimmer()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading now playing movies: $error'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
