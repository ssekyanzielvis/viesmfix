import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Button for quick favoriting/bookmarking movies
class FavoriteButton extends ConsumerWidget {
  final int movieId;
  final double size;
  final Color? color;
  final Color? activeColor;

  const FavoriteButton({
    super.key,
    required this.movieId,
    this.size = 24,
    this.color,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        Icons.favorite_border,
        size: size,
        color: color ?? Theme.of(context).iconTheme.color,
      ),
      onPressed: () async {
        // TODO: Integrate with favorites provider
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      tooltip: 'Add to favorites',
    );
  }
}

/// Compact favorite badge for movie cards
class FavoriteBadge extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const FavoriteBadge({super.key, required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!isFavorite) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.favorite, size: 16, color: Colors.white),
      ),
    );
  }
}
