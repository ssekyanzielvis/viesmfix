import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';

class HeroSection extends StatelessWidget {
  final dynamic movie; // MovieEntity
  final VoidCallback? onPlayPressed;
  final VoidCallback? onInfoPressed;

  const HeroSection({
    super.key,
    required this.movie,
    this.onPlayPressed,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          _buildBackgroundImage(context),

          // Gradient Overlay
          _buildGradientOverlay(context),

          // Content
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    return Image.network(
      'https://image.tmdb.org/t/p/original${movie.backdropPath ?? movie.posterPath}',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: context.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.movie,
            size: 100,
            color: context.colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
          stops: const [0.0, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              movie.title,
              style: context.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Metadata
            Row(
              children: [
                if (movie.releaseDate != null) ...[
                  Text(
                    movie.releaseDate.year.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                ],
                if (movie.voteAverage > 0) ...[
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Overview
            if (movie.overview.isNotEmpty)
              Text(
                movie.overview,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPlayPressed,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onInfoPressed,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('More Info'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
