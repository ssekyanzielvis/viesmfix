import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> genres;
  final List<String> selectedGenres;
  final RangeValues yearRange;
  final RangeValues ratingRange;
  final Function(List<String>, RangeValues, RangeValues) onApply;

  const FilterBottomSheet({
    super.key,
    required this.genres,
    required this.selectedGenres,
    required this.yearRange,
    required this.ratingRange,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedGenres;
  late RangeValues _yearRange;
  late RangeValues _ratingRange;

  @override
  void initState() {
    super.initState();
    _selectedGenres = List.from(widget.selectedGenres);
    _yearRange = widget.yearRange;
    _ratingRange = widget.ratingRange;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedGenres.clear();
                    _yearRange = RangeValues(1900, currentYear.toDouble());
                    _ratingRange = const RangeValues(0, 10);
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Genres
          Text('Genres', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.genres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              return FilterChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGenres.add(genre);
                    } else {
                      _selectedGenres.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Year Range
          Text(
            'Release Year: ${_yearRange.start.toInt()} - ${_yearRange.end.toInt()}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RangeSlider(
            values: _yearRange,
            min: 1900,
            max: currentYear.toDouble(),
            divisions: currentYear - 1900,
            labels: RangeLabels(
              _yearRange.start.toInt().toString(),
              _yearRange.end.toInt().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _yearRange = values;
              });
            },
          ),
          const SizedBox(height: 16),

          // Rating Range
          Text(
            'Rating: ${_ratingRange.start.toStringAsFixed(1)} - ${_ratingRange.end.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.titleMedium,
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

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedGenres, _yearRange, _ratingRange);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
