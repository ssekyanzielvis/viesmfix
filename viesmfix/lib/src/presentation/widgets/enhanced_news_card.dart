import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/news_article_entity.dart';
import 'news_responsive_widgets.dart';

/// Enhanced News Article Card with responsive design
class EnhancedNewsArticleCard extends StatelessWidget {
  final NewsArticleEntity article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final NewsCardStyle? style;

  const EnhancedNewsArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onBookmark,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardStyle = style ?? NewsResponsiveLayout.getCardStyle(context);
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);

    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      clipBehavior: Clip.antiAlias,
      elevation: isTablet ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context, cardStyle),
            _buildContent(context, theme, cardStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, NewsCardStyle cardStyle) {
    final imageHeight = NewsResponsiveLayout.getImageHeight(context);
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);

    if (article.urlToImage == null) {
      return _buildImagePlaceholder(context, imageHeight);
    }

    return Stack(
      children: [
        Hero(
          tag: 'news-${article.id}',
          child: CachedNetworkImage(
            imageUrl: article.urlToImage!,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                _buildImagePlaceholder(context, imageHeight),
            errorWidget: (context, url, error) =>
                _buildImagePlaceholder(context, imageHeight),
          ),
        ),
        // Gradient overlay for better text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
        ),
        // Category badge
        if (article.category != null)
          Positioned(
            top: isTablet ? 16 : 12,
            left: isTablet ? 16 : 12,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 8,
                vertical: isTablet ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(article.category!),
                borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                article.category!.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Bookmark button
        Positioned(
          top: isTablet ? 12 : 8,
          right: isTablet ? 12 : 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBookmark,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    NewsCardStyle cardStyle,
  ) {
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);
    final padding = isTablet ? 20.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source and time
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.source,
                      size: isTablet ? 16 : 14,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Flexible(
                      child: Text(
                        article.sourceName,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: isTablet ? 14 : 12,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: isTablet ? 4 : 2),
                  Text(
                    _formatDate(article.publishedAt),
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          // Title
          Text(
            article.title,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: cardStyle == NewsCardStyle.compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          // Description (only for standard and detailed styles)
          if (cardStyle != NewsCardStyle.compact &&
              article.description != null) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              article.description!,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              maxLines: cardStyle == NewsCardStyle.detailed ? 4 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Author (only for detailed style)
          if (cardStyle == NewsCardStyle.detailed &&
              article.author != null) ...[
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: isTablet ? 16 : 14,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Expanded(
                  child: Text(
                    article.author!,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Action row (only for detailed style on tablets)
          if (cardStyle == NewsCardStyle.detailed && isTablet) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.read_more, size: 18),
                  label: const Text('Read More'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(NewsCategory category) {
    switch (category) {
      case NewsCategory.technology:
        return Colors.blue.shade700;
      case NewsCategory.sports:
        return Colors.green.shade700;
      case NewsCategory.business:
        return Colors.orange.shade700;
      case NewsCategory.entertainment:
        return Colors.purple.shade700;
      case NewsCategory.science:
        return Colors.teal.shade700;
      case NewsCategory.health:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
