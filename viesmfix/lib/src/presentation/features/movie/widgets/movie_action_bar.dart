import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/movie_entity.dart';

class MovieActionBar extends StatelessWidget {
  final MovieEntity movie;
  final bool isInWatchlist;
  final VoidCallback onWatchlistToggle;
  final VoidCallback onShare;
  final VoidCallback? onRate;

  const MovieActionBar({
    super.key,
    required this.movie,
    required this.isInWatchlist,
    required this.onWatchlistToggle,
    required this.onShare,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Watchlist button
            Expanded(
              child: _ActionButton(
                icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_outline,
                label: isInWatchlist ? 'In Watchlist' : 'Add to Watchlist',
                onPressed: onWatchlistToggle,
                filled: isInWatchlist,
              ),
            ),
            const SizedBox(width: 12),

            // Rate button
            if (onRate != null)
              Expanded(
                child: _ActionButton(
                  icon: Icons.star_outline,
                  label: 'Rate',
                  onPressed: onRate!,
                ),
              ),
            if (onRate != null) const SizedBox(width: 12),

            // Share button
            _ActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onPressed: onShare,
              iconOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool iconOnly;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(icon: Icon(icon), onPressed: onPressed, tooltip: label);
    }

    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
