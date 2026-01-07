import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/news_article_entity.dart';
import '../providers/news_providers.dart';
import '../widgets/news_responsive_widgets.dart';
import '../widgets/enhanced_news_card.dart';

class NewsBookmarksScreen extends ConsumerWidget {
  const NewsBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bookmarks),
            const SizedBox(width: 8),
            const Text('Bookmarked Articles'),
          ],
        ),
      ),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return NewsEmptyState(
              icon: Icons.bookmarks_outlined,
              title: 'No bookmarks yet',
              message: 'Bookmark articles to read later',
            );
          }

          return ResponsiveNewsBuilder(
            children: bookmarks
                .map((bookmark) => _BookmarkCard(bookmark: bookmark))
                .toList(),
          );
        },
        loading: () => NewsGridShimmer(),
        error: (error, stack) => NewsErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(bookmarkedArticlesProvider),
        ),
      ),
    );
  }
}

class _BookmarkCard extends ConsumerWidget {
  final BookmarkedArticleEntity bookmark;

  const _BookmarkCard({required this.bookmark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Convert to NewsArticleEntity to use the enhanced card
    final article = NewsArticleEntity(
      id: bookmark.articleId,
      sourceName: bookmark.sourceName,
      title: bookmark.title,
      description: bookmark.description,
      url: bookmark.url,
      urlToImage: bookmark.imageUrl,
      publishedAt: bookmark.publishedAt,
      isBookmarked: true,
    );

    return EnhancedNewsArticleCard(
      article: article,
      onTap: () {
        Navigator.pushNamed(context, '/news/article', arguments: article);
      },
      onBookmark: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Bookmark'),
            content: const Text('Remove this article from bookmarks?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await ref
              .read(removeBookmarkUseCaseProvider)
              .call(bookmark.articleId);
          ref.invalidate(bookmarkedArticlesProvider);
        }
      },
    );
  }
}
