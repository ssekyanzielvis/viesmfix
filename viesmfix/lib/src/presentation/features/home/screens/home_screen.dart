import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/movie_providers.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/movie_card.dart';
import '../../../widgets/movie_section.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../movie/screens/movie_detail_screen.dart';
import '../../search/screens/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingMovies = ref.watch(trendingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);

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
                children: movies.take(10).map((movie) {
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

            // Popular Section
            popularMovies.when(
              data: (movies) => MovieSection(
                title: 'Popular',
                children: movies.take(10).map((movie) {
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
                children: movies.take(10).map((movie) {
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
          ],
        ),
      ),
    );
  }
}
