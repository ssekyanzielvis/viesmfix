import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MLTVCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const MLTVCard({
    super.key,
    required this.item,
    this.onTap,
    this.width = 120,
    this.height = 180,
  });

  String _pickPoster(Map<String, dynamic> m) {
    final candidates = [
      'poster',
      'poster_url',
      'posterPath',
      'image',
      'cover',
      'thumbnail',
    ];
    for (final k in candidates) {
      final v = m[k]?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final title = (item['title'] ?? item['name'] ?? '').toString();
    final posterUrl = _pickPoster(item);

    return GestureDetector(
      onTap: onTap,
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
