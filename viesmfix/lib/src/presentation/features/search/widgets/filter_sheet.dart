import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filter options for movie search
class MovieFilterSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const MovieFilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  ConsumerState<MovieFilterSheet> createState() => _MovieFilterSheetState();
}

class _MovieFilterSheetState extends ConsumerState<MovieFilterSheet> {
  late Map<String, dynamic> _filters;
  late RangeValues _yearRange;
  late RangeValues _ratingRange;
  final List<String> _selectedGenres = [];
  String? _sortBy;

  final List<Map<String, dynamic>> _genres = [
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 99, 'name': 'Documentary'},
    {'id': 18, 'name': 'Drama'},
    {'id': 10751, 'name': 'Family'},
    {'id': 14, 'name': 'Fantasy'},
    {'id': 36, 'name': 'History'},
    {'id': 27, 'name': 'Horror'},
    {'id': 10402, 'name': 'Music'},
    {'id': 9648, 'name': 'Mystery'},
    {'id': 10749, 'name': 'Romance'},
    {'id': 878, 'name': 'Science Fiction'},
    {'id': 10770, 'name': 'TV Movie'},
    {'id': 53, 'name': 'Thriller'},
    {'id': 10752, 'name': 'War'},
    {'id': 37, 'name': 'Western'},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'popularity.desc', 'label': 'Popularity (High to Low)'},
    {'value': 'popularity.asc', 'label': 'Popularity (Low to High)'},
    {'value': 'vote_average.desc', 'label': 'Rating (High to Low)'},
    {'value': 'vote_average.asc', 'label': 'Rating (Low to High)'},
    {'value': 'release_date.desc', 'label': 'Release Date (Newest)'},
    {'value': 'release_date.asc', 'label': 'Release Date (Oldest)'},
    {'value': 'title.asc', 'label': 'Title (A-Z)'},
    {'value': 'title.desc', 'label': 'Title (Z-A)'},
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);

    // Initialize year range (last 50 years)
    final currentYear = DateTime.now().year;
    _yearRange = RangeValues(
      (_filters['year_from'] ?? (currentYear - 50)).toDouble(),
      (_filters['year_to'] ?? currentYear).toDouble(),
    );

    // Initialize rating range
    _ratingRange = RangeValues(
      (_filters['rating_from'] ?? 0.0).toDouble(),
      (_filters['rating_to'] ?? 10.0).toDouble(),
    );

    // Initialize genres
    if (_filters['genres'] != null) {
      _selectedGenres.addAll(List<String>.from(_filters['genres']));
    }

    // Initialize sort by
    _sortBy = _filters['sort_by'] as String?;
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'year_from': _yearRange.start.round(),
      'year_to': _yearRange.end.round(),
      'rating_from': _ratingRange.start,
      'rating_to': _ratingRange.end,
      'genres': _selectedGenres,
      'sort_by': _sortBy,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      final currentYear = DateTime.now().year;
      _yearRange = RangeValues(
        (currentYear - 50).toDouble(),
        currentYear.toDouble(),
      );
      _ratingRange = const RangeValues(0.0, 10.0);
      _selectedGenres.clear();
      _sortBy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  Text(
                    'Sort By',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((option) {
                      final isSelected = _sortBy == option['value'];
                      return FilterChip(
                        label: Text(option['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _sortBy = selected ? option['value'] : null;
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Release Year
                  Text(
                    'Release Year',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _yearRange.start.round().toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        _yearRange.end.round().toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _yearRange,
                    min: DateTime.now().year - 100,
                    max: DateTime.now().year.toDouble(),
                    divisions: 100,
                    labels: RangeLabels(
                      _yearRange.start.round().toString(),
                      _yearRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _yearRange = values;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Rating
                  Text(
                    'Rating',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _ratingRange.start.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        _ratingRange.end.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _ratingRange,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    labels: RangeLabels(
                      _ratingRange.start.toStringAsFixed(1),
                      _ratingRange.end.toStringAsFixed(1),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _ratingRange = values;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Genres
                  Text(
                    'Genres',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _genres.map((genre) {
                      final genreId = genre['id'].toString();
                      final isSelected = _selectedGenres.contains(genreId);
                      return FilterChip(
                        label: Text(genre['name'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenres.add(genreId);
                            } else {
                              _selectedGenres.remove(genreId);
                            }
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _applyFilters,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Apply Filters'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
