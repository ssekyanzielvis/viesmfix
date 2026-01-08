import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/environment.dart';
import '../../core/router/app_router.dart';

/// News Navigation Helper
///
/// Provides easy navigation to news features with proper feature flag checking
class NewsNavigation {
  NewsNavigation._();

  /// Navigate to news feed
  static void toNewsFeed(BuildContext context) {
    if (!Environment.enableNews) {
      _showFeatureDisabledSnackBar(context);
      return;
    }
    context.push(AppRoutes.news);
  }

  /// Navigate to news search
  static void toNewsSearch(BuildContext context) {
    if (!Environment.enableNews) {
      _showFeatureDisabledSnackBar(context);
      return;
    }
    context.push(AppRoutes.newsSearch);
  }

  /// Navigate to bookmarked articles
  static void toNewsBookmarks(BuildContext context) {
    if (!Environment.enableNews) {
      _showFeatureDisabledSnackBar(context);
      return;
    }
    context.push(AppRoutes.newsBookmarks);
  }

  /// Check if news feature is enabled
  static bool get isEnabled => Environment.enableNews;

  static void _showFeatureDisabledSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('News feature is currently disabled'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// News Feature Widget
///
/// A widget that conditionally shows news-related content based on feature flag
class NewsFeatureWidget extends ConsumerWidget {
  final Widget Function(BuildContext context) builder;
  final Widget? fallback;

  const NewsFeatureWidget({super.key, required this.builder, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Environment.enableNews) {
      return fallback ?? const SizedBox.shrink();
    }
    return builder(context);
  }
}

/// News Navigation Item
///
/// A navigation item for the news feature (can be used in bottom nav or drawer)
class NewsNavigationItem {
  static const BottomNavigationBarItem bottomNavItem = BottomNavigationBarItem(
    icon: Icon(Icons.newspaper),
    label: 'News',
    tooltip: 'Browse news articles',
  );

  static ListTile drawerItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.newspaper),
      title: const Text('News'),
      subtitle: const Text('Browse latest headlines'),
      onTap: () {
        Navigator.pop(context); // Close drawer
        NewsNavigation.toNewsFeed(context);
      },
    );
  }

  static Widget iconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.newspaper),
      tooltip: 'News',
      onPressed: () => NewsNavigation.toNewsFeed(context),
    );
  }
}
