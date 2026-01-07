import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/news_article_entity.dart';
import '../providers/news_providers.dart';
import '../widgets/news_responsive_widgets.dart';

class NewsArticleDetailScreen extends ConsumerWidget {
  final NewsArticleEntity article;

  const NewsArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);
    final maxWidth = NewsResponsiveLayout.isDesktop(context)
        ? 900.0
        : double.infinity;
    final expandedHeight = article.urlToImage != null
        ? (isTablet ? 400.0 : 300.0)
        : 100.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 8,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                ),
                child: Text(
                  article.sourceName,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
              ),
              background: article.urlToImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          article.urlToImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.broken_image,
                                size: isTablet ? 120 : 80,
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () => _toggleBookmark(ref),
              ),
              IconButton(
                icon: Icon(Icons.share, size: isTablet ? 28 : 24),
                onPressed: () => _shareArticle(),
              ),
              if (isTablet) const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.all(
                  NewsResponsiveLayout.getSpacing(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    Row(
                      children: [
                        if (article.author != null) ...[
                          Icon(
                            Icons.person,
                            size: isTablet ? 18 : 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Expanded(
                            child: Text(
                              article.author!,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 20 : 16),
                        ],
                        Icon(
                          Icons.access_time,
                          size: isTablet ? 18 : 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    if (article.description != null) ...[
                      Text(
                        article.description!,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isTablet ? 32 : 24),
                    ],
                    if (article.content != null) ...[
                      Text(
                        article.content!,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.grey.shade900,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: isTablet ? 32 : 24),
                    ],
                    const Divider(),
                    SizedBox(height: isTablet ? 20 : 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openInBrowser(article.url),
                        icon: Icon(
                          Icons.open_in_browser,
                          size: isTablet ? 24 : 20,
                        ),
                        label: Text(
                          'Read Full Article',
                          style: TextStyle(fontSize: isTablet ? 18 : 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    Card(
                      color: theme.colorScheme.surfaceVariant,
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  'Article Info',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            _buildInfoRow(
                              'Source',
                              article.sourceName,
                              isTablet,
                            ),
                            if (article.author != null)
                              _buildInfoRow(
                                'Author',
                                article.author!,
                                isTablet,
                              ),
                            _buildInfoRow(
                              'Published',
                              '${article.publishedAt.toString().split(' ')[0]} ${article.publishedAt.toString().split(' ')[1].split('.')[0]}',
                              isTablet,
                            ),
                            if (article.category != null)
                              _buildInfoRow(
                                'Category',
                                article.category!.displayName,
                                isTablet,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 6 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 100 : 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: isTablet ? 16 : 14)),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(WidgetRef ref) {
    if (article.isBookmarked) {
      ref.read(removeBookmarkUseCaseProvider).call(article.id);
    } else {
      ref.read(bookmarkArticleUseCaseProvider).call(article);
    }
    // Refresh bookmarks list
    ref.invalidate(bookmarkedArticlesProvider);
  }

  Future<void> _shareArticle() async {
    final text = '${article.title}\n\n${article.url}';
    await Share.share(text, subject: article.title);
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
