import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie_entity.dart';
import '../widgets/movie_grid.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/genre_chip.dart';
import '../../core/widgets/error_widget.dart';
import '../widgets/loading_shimmer.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedGenres = [];
  RangeValues _yearRange = RangeValues(1900, DateTime.now().year.toDouble());
  RangeValues _ratingRange = const RangeValues(0, 10);
  String _sortBy = 'popularity.desc';

  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'TV Movie',
    'Thriller',
    'War',
    'Western',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        genres: _availableGenres,
        selectedGenres: _selectedGenres,
        yearRange: _yearRange,
        ratingRange: _ratingRange,
        onApply: (genres, yearRange, ratingRange) {
          setState(() {
            _selectedGenres = genres;
            _yearRange = yearRange;
            _ratingRange = ratingRange;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Selected Genres
          if (_selectedGenres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GenreChipList(
                genres: _selectedGenres,
                selectedGenres: _selectedGenres,
                onGenreSelected: (genre) {
                  setState(() {
                    _selectedGenres.remove(genre);
                  });
                },
              ),
            ),

          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Sort by: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'popularity.desc',
                        child: Text('Popularity (High to Low)'),
                      ),
                      DropdownMenuItem(
                        value: 'popularity.asc',
                        child: Text('Popularity (Low to High)'),
                      ),
                      DropdownMenuItem(
                        value: 'vote_average.desc',
                        child: Text('Rating (High to Low)'),
                      ),
                      DropdownMenuItem(
                        value: 'vote_average.asc',
                        child: Text('Rating (Low to High)'),
                      ),
                      DropdownMenuItem(
                        value: 'release_date.desc',
                        child: Text('Release Date (Newest)'),
                      ),
                      DropdownMenuItem(
                        value: 'release_date.asc',
                        child: Text('Release Date (Oldest)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final query = _searchController.text.trim();

    if (query.isEmpty && _selectedGenres.isEmpty) {
      return const EmptyStateWidget(
        message: 'Start searching',
        subtitle: 'Enter a movie title or apply filters',
        icon: Icons.search,
      );
    }

    // Build search results - simplified without dynamic provider
    return FutureBuilder<List<MovieEntity>>(
      future: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: 6,
            itemBuilder: (context, index) =>
                const LoadingShimmer(width: double.infinity, height: 200),
          );
        }

        if (snapshot.hasError) {
          return ErrorDisplayWidget(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {}),
          );
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return const EmptyStateWidget(
            message: 'No results found',
            subtitle: 'Try different search terms or filters',
            icon: Icons.movie_outlined,
          );
        }

        // Apply additional filters
        var filteredMovies = movies.where((movie) {
          // Year filter
          if (movie.releaseDate != null) {
            final year = DateTime.tryParse(movie.releaseDate!)?.year;
            if (year != null) {
              if (year < _yearRange.start.toInt() ||
                  year > _yearRange.end.toInt()) {
                return false;
              }
            }
          }

          // Rating filter
          final voteAverage = movie.voteAverage ?? 0.0;
          if (voteAverage < _ratingRange.start ||
              voteAverage > _ratingRange.end) {
            return false;
          }

          return true;
        }).toList();

        if (filteredMovies.isEmpty) {
          return const EmptyStateWidget(
            message: 'No movies match your filters',
            subtitle: 'Try adjusting your filters',
            icon: Icons.filter_list_off,
          );
        }

        return MovieGridView(
          movies: filteredMovies,
          onMovieTap: (movie) {
            // Navigate to detail screen
            // TODO: Use router navigation
          },
        );
      },
    );
  }

  Future<List<MovieEntity>> _performSearch(String query) async {
    // This would use the search repository
    // For now, return empty list as placeholder
    return [];
  }
}
