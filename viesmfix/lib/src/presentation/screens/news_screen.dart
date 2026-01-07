import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/news_article_entity.dart';
import '../providers/news_providers.dart';
import '../widgets/news_responsive_widgets.dart';
import '../widgets/enhanced_news_card.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NewsCategory _selectedCategory = NewsCategory.general;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: NewsCategory.values.length,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = NewsCategory.values[_tabController.index];
          _currentPage = 1;
        });
        _loadNews();
      }
    });

    _scrollController.addListener(_onScroll);
    _loadNews();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadNews() {
    ref
        .read(newsProvider.notifier)
        .fetchTopHeadlines(category: _selectedCategory, page: _currentPage);
  }

  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    _loadNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.newspaper, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('News'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/news/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              Navigator.pushNamed(context, '/news/bookmarks');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: NewsCategory.values.map((category) {
            return Tab(text: category.displayName);
          }).toList(),
        ),
      ),
      body: newsState.when(
        data: (articles) {
          if (articles.isEmpty) {
            return NewsEmptyState(
              icon: Icons.newspaper,
              title: 'No News Available',
              message: 'Pull to refresh or try a different category',
              onRetry: () {
                setState(() => _currentPage = 1);
                _loadNews();
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _currentPage = 1);
              _loadNews();
            },
            child: ResponsiveNewsBuilder(
              controller: _scrollController,
              children: [
                ...articles.map(
                  (article) => EnhancedNewsArticleCard(
                    article: article,
                    onTap: () => _openArticle(article),
                    onBookmark: () => _toggleBookmark(article),
                  ),
                ),
                if (_isLoadingMore) const NewsPaginationLoader(),
              ],
            ),
          );
        },
        loading: () => NewsGridShimmer(),
        error: (error, stack) =>
            NewsErrorState(error: error.toString(), onRetry: _loadNews),
      ),
    );
  }

  void _openArticle(NewsArticleEntity article) {
    Navigator.pushNamed(context, '/news/article', arguments: article);
  }

  void _toggleBookmark(NewsArticleEntity article) {
    if (article.isBookmarked) {
      ref.read(removeBookmarkUseCaseProvider).call(article.id);
    } else {
      ref.read(bookmarkArticleUseCaseProvider).call(article);
    }
  }
}
