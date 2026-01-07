// =====================================================
// News Feature Integration Example
// =====================================================
// This file shows how to integrate the news feature
// into your main app
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import news feature components
import 'src/presentation/screens/news_screen.dart';
import 'src/presentation/screens/news_search_screen.dart';
import 'src/presentation/screens/news_bookmarks_screen.dart';
import 'src/presentation/screens/news_article_detail_screen.dart';
import 'src/presentation/providers/news_providers.dart';
import 'src/data/datasources/news_local_datasource.dart';
import 'src/domain/entities/news_article_entity.dart';

// =====================================================
// 1. Main App Setup
// =====================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for news caching and bookmarks
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override news local data source with initialized SharedPreferences
        newsLocalDataSourceProvider.overrideWithValue(
          NewsLocalDataSource(prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// =====================================================
// 2. Router Setup (using named routes)
// =====================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viesmfix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/news': (context) => const NewsScreen(),
        '/news/search': (context) => const NewsSearchScreen(),
        '/news/bookmarks': (context) => const NewsBookmarksScreen(),
        '/news/article': (context) {
          final article =
              ModalRoute.of(context)!.settings.arguments as NewsArticleEntity;
          return NewsArticleDetailScreen(article: article);
        },
      },
      initialRoute: '/',
    );
  }
}

// =====================================================
// 3. Router Setup (using go_router) - Alternative
// =====================================================

/*
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/news',
      builder: (context, state) => const NewsScreen(),
      routes: [
        GoRoute(
          path: 'search',
          builder: (context, state) => const NewsSearchScreen(),
        ),
        GoRoute(
          path: 'bookmarks',
          builder: (context, state) => const NewsBookmarksScreen(),
        ),
        GoRoute(
          path: 'article',
          builder: (context, state) {
            final article = state.extra as NewsArticleEntity;
            return NewsArticleDetailScreen(article: article);
          },
        ),
      ],
    ),
  ],
);

// Then in MyApp:
MaterialApp.router(
  routerConfig: router,
  // ... other config
)
*/

// =====================================================
// 4. Bottom Navigation Integration
// =====================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Include news screen in your navigation pages
  final List<Widget> _pages = [
    const MoviesHomePage(),
    const NewsScreen(), // Add news screen here
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News', // Add news destination
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 5. Drawer Navigation Integration - Alternative
// =====================================================

class HomeScreenWithDrawer extends StatelessWidget {
  const HomeScreenWithDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viesmfix')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Viesmfix',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Movies & News',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Movies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/movies');
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News'), // Add news menu item
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/news');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bookmarks),
              title: const Text('News Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/news/bookmarks');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Home')),
    );
  }
}

// =====================================================
// 6. Tab Bar Integration - Alternative
// =====================================================

class HomeScreenWithTabs extends StatelessWidget {
  const HomeScreenWithTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Viesmfix'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.movie), text: 'Movies'),
              Tab(icon: Icon(Icons.newspaper), text: 'News'), // Add news tab
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MoviesHomePage(),
            NewsScreen(), // Add news screen
            SearchPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 7. Programmatic Navigation Examples
// =====================================================

class NavigationExamples {
  // Navigate to news screen
  static void goToNews(BuildContext context) {
    Navigator.pushNamed(context, '/news');
  }

  // Navigate to specific category
  static void goToNewsByCategory(BuildContext context, NewsCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewsScreen(),
        settings: RouteSettings(arguments: {'category': category}),
      ),
    );
  }

  // Open specific article
  static void openArticle(BuildContext context, NewsArticleEntity article) {
    Navigator.pushNamed(context, '/news/article', arguments: article);
  }

  // Go to bookmarks
  static void goToBookmarks(BuildContext context) {
    Navigator.pushNamed(context, '/news/bookmarks');
  }

  // Open search
  static void openSearch(BuildContext context) {
    Navigator.pushNamed(context, '/news/search');
  }
}

// =====================================================
// 8. Deep Link Integration Example
// =====================================================

/*
// Using go_router for deep linking

final router = GoRouter(
  routes: [
    // ... other routes
    GoRoute(
      path: '/news/:category',
      builder: (context, state) {
        final category = state.pathParameters['category'];
        // Parse category and navigate accordingly
        return const NewsScreen();
      },
    ),
    GoRoute(
      path: '/news/article/:articleId',
      builder: (context, state) {
        final articleId = state.pathParameters['articleId'];
        // Fetch article by ID and display
        return const NewsArticleDetailScreen(article: article);
      },
    ),
  ],
);

// Example deep links:
// myapp://news/technology
// myapp://news/article/12345
// https://viesmfix.com/news/sports
*/

// =====================================================
// 9. Widget Examples - Quick Access Buttons
// =====================================================

class QuickNewsAccessWidget extends StatelessWidget {
  const QuickNewsAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.newspaper,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Latest News',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/news'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildCategoryChip(
                  context,
                  'Technology',
                  NewsCategory.technology,
                ),
                _buildCategoryChip(context, 'Sports', NewsCategory.sports),
                _buildCategoryChip(context, 'Business', NewsCategory.business),
                _buildCategoryChip(
                  context,
                  'Entertainment',
                  NewsCategory.entertainment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    NewsCategory category,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Navigate to news with specific category
        NavigationExamples.goToNewsByCategory(context, category);
      },
    );
  }
}

// =====================================================
// 10. Settings Integration
// =====================================================

class NewsSettingsSection extends StatelessWidget {
  const NewsSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'News',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.bookmarks),
          title: const Text('Bookmarked Articles'),
          subtitle: const Text('View saved articles'),
          onTap: () => Navigator.pushNamed(context, '/news/bookmarks'),
        ),
        ListTile(
          leading: const Icon(Icons.clear),
          title: const Text('Clear News Cache'),
          subtitle: const Text('Free up storage space'),
          onTap: () async {
            // Clear cache logic
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear Cache'),
                content: const Text(
                  'This will clear all cached news articles.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              // Clear cache via repository
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            }
          },
        ),
      ],
    );
  }
}

// =====================================================
// Placeholder screens (replace with your actual screens)
// =====================================================

class MoviesHomePage extends StatelessWidget {
  const MoviesHomePage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Movies'));
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Search'));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile'));
}
