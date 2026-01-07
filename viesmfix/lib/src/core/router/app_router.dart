import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/features/home/screens/home_screen.dart';
import '../../presentation/features/movie/screens/movie_detail_screen.dart';
import '../../presentation/features/search/screens/search_screen.dart';
import '../../presentation/screens/news_screen.dart';
import '../../presentation/screens/news_search_screen.dart';
import '../../presentation/screens/news_bookmarks_screen.dart';
import '../../presentation/screens/news_article_detail_screen.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../presentation/screens/sports_screens.dart';
import '../../presentation/screens/sports_search_screen.dart';
import '../../presentation/screens/sports_bookmarks_screen.dart';
import '../../presentation/screens/sports_settings_screen.dart';
import '../../domain/entities/sport_event_entity.dart';

// Route names
class AppRoutes {
  static const home = '/';
  static const movieDetail = '/movie/:id';
  static const search = '/search';
  static const watchlist = '/watchlist';
  static const profile = '/profile';
  static const settings = '/settings';
  static const login = '/login';
  static const signup = '/signup';

  // News routes
  static const news = '/news';
  static const newsSearch = '/news/search';
  static const newsBookmarks = '/news/bookmarks';
  static const newsArticle = '/news/article';

  // Sports routes
  static const sports = '/sports';
  static const sportsMatchDetail = '/sports/match';
  static const sportsSearch = '/sports/search';
  static const sportsBookmarks = '/sports/bookmarks';
  static const sportsSettings = '/sports/settings';
  static const mySports = '/my-sports';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        name: 'movie-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MovieDetailScreen(movieId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      // News routes
      GoRoute(
        path: AppRoutes.news,
        name: 'news',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsSearch,
        name: 'news-search',
        builder: (context, state) => const NewsSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsBookmarks,
        name: 'news-bookmarks',
        builder: (context, state) => const NewsBookmarksScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsArticle,
        name: 'news-article',
        builder: (context, state) {
          final article = state.extra as NewsArticleEntity;
          return NewsArticleDetailScreen(article: article);
        },
      ),
      // Sports routes
      GoRoute(
        path: AppRoutes.sports,
        name: 'sports',
        builder: (context, state) => const SportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.sportsMatchDetail,
        name: 'sports-match-detail',
        builder: (context, state) {
          final match = state.extra as SportEventEntity;
          return MatchDetailScreen(match: match);
        },
      ),
      GoRoute(
        path: AppRoutes.sportsSearch,
        name: 'sports-search',
        builder: (context, state) => const SportsSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.sportsBookmarks,
        name: 'sports-bookmarks',
        builder: (context, state) => const SportsBookmarksScreen(),
      ),
      GoRoute(
        path: AppRoutes.sportsSettings,
        name: 'sports-settings',
        builder: (context, state) => const SportsSettingsScreen(),
      ),
      // TODO: Add authentication routes
      // TODO: Add watchlist route
      // TODO: Add profile route
      // TODO: Add settings route
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
