import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/news_article_entity.dart';
import '../providers/news_providers.dart';
import '../widgets/news_responsive_widgets.dart';
import '../widgets/enhanced_news_card.dart';

class NewsSearchScreen extends ConsumerStatefulWidget {
  const NewsSearchScreen({super.key});

  @override
  ConsumerState<NewsSearchScreen> createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends ConsumerState<NewsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'publishedAt';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _performSearch();
    }
  }

  void _performSearch() {
    ref
        .read(newsProvider.notifier)
        .search(
          query: _searchController.text,
          from: _fromDate,
          to: _toDate,
          page: _currentPage,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          style: const TextStyle(fontSize: 18),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() => _currentPage = 1);
            _performSearch();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _currentPage = 1;
                });
                ref.invalidate(newsProvider);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_fromDate != null || _toDate != null || _sortBy != 'publishedAt')
            Container(
              padding: const EdgeInsets.all(8),
              color: theme.colorScheme.primaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterText(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                        _sortBy = 'publishedAt';
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch();
                      }
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: newsState.when(
              data: (articles) {
                if (_searchController.text.isEmpty) {
                  return NewsEmptyState(
                    icon: Icons.search,
                    title: 'Search for news',
                    message: 'Enter keywords to find articles',
                  );
                }

                if (articles.isEmpty) {
                  return NewsEmptyState(
                    icon: Icons.search_off,
                    title: 'No results found',
                    message: 'Try different keywords or adjust filters',
                    onRetry: _performSearch,
                  );
                }

                return ResponsiveNewsBuilder(
                  controller: _scrollController,
                  children: [
                    ...articles.map(
                      (article) => EnhancedNewsArticleCard(
                        article: article,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/news/article',
                          arguments: article,
                        ),
                        onBookmark: () => _toggleBookmark(article),
                      ),
                    ),
                    if (_isLoadingMore) const NewsPaginationLoader(),
                  ],
                );
              },
              loading: () => NewsGridShimmer(),
              error: (error, stack) => NewsErrorState(
                error: error.toString(),
                onRetry: _performSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(NewsArticleEntity article) {
    if (article.isBookmarked) {
      ref.read(removeBookmarkUseCaseProvider).call(article.id);
    } else {
      ref.read(bookmarkArticleUseCaseProvider).call(article);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('From Date'),
              subtitle: Text(_fromDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fromDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _fromDate = date);
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              title: const Text('To Date'),
              subtitle: Text(_toDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _toDate ?? DateTime.now(),
                  firstDate: _fromDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _toDate = date);
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              title: const Text('Sort By'),
              subtitle: Text(_sortBy),
              trailing: const Icon(Icons.sort),
              onTap: () {
                Navigator.pop(context);
                _showSortDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sort By'),
        children: ['publishedAt', 'relevancy', 'popularity'].map((sort) {
          return RadioListTile<String>(
            title: Text(sort),
            value: sort,
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value!);
              Navigator.pop(context);
              if (_searchController.text.isNotEmpty) {
                _performSearch();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _buildFilterText() {
    final filters = <String>[];
    if (_fromDate != null)
      filters.add('From: ${_fromDate!.toString().split(' ')[0]}');
    if (_toDate != null)
      filters.add('To: ${_toDate!.toString().split(' ')[0]}');
    if (_sortBy != 'publishedAt') filters.add('Sort: $_sortBy');
    return filters.join(' • ');
  }
}
