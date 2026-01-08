import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MLTVCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const MLTVCard({
    Key? key,
    required this.item,
    required this.width,
    required this.height,
    this.onTap,
  }) : super(key: key);

  String _pickPoster(Map<String, dynamic> item) {
    return item['poster_path']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final title = (item['title'] ?? item['name'] ?? '').toString();
    final posterUrl = _pickPoster(item);
    final videoUrl = item['video_url']?.toString();

    Future<void> _launchVideo() async {
      if (videoUrl == null || videoUrl.isEmpty) return;
      final uri = Uri.tryParse(videoUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return GestureDetector(
      onTap:
          onTap ??
          (videoUrl != null && videoUrl.isNotEmpty ? _launchVideo : null),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (posterUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.movie,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, size: 48, color: Colors.grey),
                ),
              if (videoUrl != null && videoUrl.isNotEmpty)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: _launchVideo,
                      tooltip: 'Play',
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
