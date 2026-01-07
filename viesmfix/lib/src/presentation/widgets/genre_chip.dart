import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.name,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(name),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class GenreChipList extends StatelessWidget {
  final List<String> genres;
  final List<String>? selectedGenres;
  final ValueChanged<String>? onGenreSelected;

  const GenreChipList({
    super.key,
    required this.genres,
    this.selectedGenres,
    this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) {
        final isSelected = selectedGenres?.contains(genre) ?? false;
        return GenreChip(
          name: genre,
          isSelected: isSelected,
          onTap: () => onGenreSelected?.call(genre),
        );
      }).toList(),
    );
  }
}
