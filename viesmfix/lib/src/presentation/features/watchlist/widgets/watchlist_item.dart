import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/watchlist_item_entity.dart';

class WatchlistItem extends StatelessWidget {
  final WatchlistItemEntity item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const WatchlistItem({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            SizedBox(
              width: 100,
              height: 150,
              child: Image.network(
                'https://image.tmdb.org/t/p/w342${item.moviePosterPath}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: context.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie,
                      size: 48,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.movieTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          item.userRating?.toStringAsFixed(1) ?? 'Not rated',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Added date
                    Text(
                      'Added ${_formatDate(item.addedAt)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Remove button
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.bookmark),
                color: context.colorScheme.primary,
                onPressed: onRemove,
                tooltip: 'Remove from watchlist',
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
