import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/movie_entity.dart';

/// Button widget for sharing movies
class ShareButton extends StatelessWidget {
  final MovieEntity movie;
  final VoidCallback? onShareComplete;

  const ShareButton({super.key, required this.movie, this.onShareComplete});

  Future<void> _shareMovie(BuildContext context) async {
    try {
      // Create share text
      final shareText = _buildShareText();

      // Try using share_plus package if available
      // For now, copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: shareText));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movie link copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      onShareComplete?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('Check out this movie!');
    buffer.writeln();
    buffer.writeln('🎬 ${movie.title}');

    if (movie.releaseDate != null) {
      buffer.writeln('📅 ${movie.releaseDate!.split('-')[0]}');
    }

    if (movie.voteAverage != null && movie.voteAverage! > 0) {
      buffer.writeln('⭐ ${movie.voteAverage!.toStringAsFixed(1)}/10');
    }

    if (movie.overview != null && movie.overview!.isNotEmpty) {
      buffer.writeln();
      final overview = movie.overview!.length > 150
          ? '${movie.overview!.substring(0, 150)}...'
          : movie.overview!;
      buffer.writeln(overview);
    }

    buffer.writeln();
    buffer.writeln('Shared from ViesMFix Movie App');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _shareMovie(context),
      icon: const Icon(Icons.share),
      tooltip: 'Share movie',
    );
  }
}
