import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../../core/constants/environment.dart';

/// Sports navigation utilities
class SportsNavigation {
  /// Navigate to sports main screen
  static Future<void> toSportsHome(BuildContext context) async {
    if (!Environment.enableSports) {
      _showFeatureDisabledMessage(context);
      return;
    }
    await Navigator.pushNamed(context, '/sports');
  }

  /// Navigate to match detail
  static Future<void> toMatchDetail(
    BuildContext context,
    SportEventEntity match,
  ) async {
    await Navigator.pushNamed(context, '/sportsMatchDetail', arguments: match);
  }

  /// Navigate to sports search
  static Future<void> toSportsSearch(BuildContext context) async {
    await Navigator.pushNamed(context, '/sportsSearch');
  }

  /// Navigate to my sports/favorites
  static Future<void> toMySports(BuildContext context) async {
    await Navigator.pushNamed(context, '/mySports');
  }

  /// Navigate to sports settings
  static Future<void> toSportsSettings(BuildContext context) async {
    await Navigator.pushNamed(context, '/sportsSettings');
  }

  static void _showFeatureDisabledMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sports feature is currently disabled'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Deep linking utilities for streaming apps
class StreamingDeepLinks {
  /// Launch streaming app or fallback to store/web
  static Future<void> launchStreamingOption(
    StreamingOption option, {
    required BuildContext context,
  }) async {
    // Try deep link first (if app is installed)
    if (option.deepLink != null) {
      final deepLinkUri = Uri.parse(option.deepLink!);
      if (await canLaunchUrl(deepLinkUri)) {
        await launchUrl(deepLinkUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Try web link
    if (option.webLink != null) {
      final webUri = Uri.parse(option.webLink!);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Fallback to app store if neither worked
    await _showInstallOptions(context, option.provider);
  }

  /// Show dialog to install streaming app
  static Future<void> _showInstallOptions(
    BuildContext context,
    StreamingProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Install ${provider.name}'),
        content: Text(
          'To watch on ${provider.name}, you need to install the app first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (provider.appStoreUrl != null)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(provider.appStoreUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('App Store'),
            ),
          if (provider.playStoreUrl != null)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(provider.playStoreUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Play Store'),
            ),
          if (provider.webUrl != null)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(provider.webUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Open Web'),
            ),
        ],
      ),
    );
  }

  /// Get deep link for common streaming providers
  static String? getDeepLink(String providerName, String eventId) {
    final schemes = {
      'ESPN+': 'espn://sports/live/',
      'Peacock': 'peacocktv://sports/live/',
      'Paramount+': 'paramount://live/',
      'DAZN': 'dazn://event/',
      'fuboTV': 'fubotv://watch/',
      'NBC Sports': 'nbcsports://live/',
    };

    final scheme = schemes[providerName];
    return scheme != null ? '$scheme$eventId' : null;
  }
}

/// Calendar integration utilities
class SportsCalendarIntegration {
  /// Add match to device calendar
  static Future<void> addMatchToCalendar(
    BuildContext context,
    SportEventEntity match,
  ) async {
    // This is a placeholder - actual implementation would use
    // add_2_calendar or device_calendar package
    final title = '${match.homeTeam} vs ${match.awayTeam}';

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add "$title" to calendar?'),
        action: SnackBarAction(
          label: 'Add',
          onPressed: () {
            // TODO: Implement actual calendar addition
            // Example using add_2_calendar package:
            // Add2Calendar.addEvent2Cal(Event(
            //   title: title,
            //   description: description,
            //   location: match.venue,
            //   startDate: startTime,
            //   endDate: endTime,
            // ));
          },
        ),
      ),
    );
  }
}

/// Sports feature widget for conditional rendering
class SportsFeatureWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const SportsFeatureWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    if (Environment.enableSports) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

/// Sports navigation item helpers
class SportsNavigationItem {
  /// Create bottom navigation bar item
  static BottomNavigationBarItem bottomNavItem = const BottomNavigationBarItem(
    icon: Icon(Icons.sports_soccer),
    activeIcon: Icon(Icons.sports_soccer),
    label: 'Sports',
  );

  /// Create drawer item
  static Widget drawerItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.sports_soccer),
      title: const Text('Sports'),
      onTap: () {
        Navigator.pop(context); // Close drawer
        SportsNavigation.toSportsHome(context);
      },
    );
  }

  /// Create icon button
  static Widget iconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sports_soccer),
      onPressed: () => SportsNavigation.toSportsHome(context),
      tooltip: 'Sports',
    );
  }

  /// Create floating action button
  static Widget fab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => SportsNavigation.toSportsHome(context),
      tooltip: 'View Sports',
      child: const Icon(Icons.sports_soccer),
    );
  }
}

/// Sports analytics helper (placeholder for analytics integration)
class SportsAnalytics {
  static void logMatchViewed(SportEventEntity match) {
    // TODO: Implement analytics
    // Example: FirebaseAnalytics.instance.logEvent(
    //   name: 'sports_match_viewed',
    //   parameters: {
    //     'match_id': match.id,
    //     'home_team': match.homeTeam,
    //     'away_team': match.awayTeam,
    //     'league': match.league.name,
    //     'sport_type': match.sportType.key,
    //     'status': match.status.key,
    //   },
    // );
  }

  static void logStreamingLinkClicked(
    StreamingOption option,
    SportEventEntity match,
  ) {
    // TODO: Implement analytics
  }

  static void logMatchBookmarked(SportEventEntity match) {
    // TODO: Implement analytics
  }

  static void logNotificationEnabled(SportEventEntity match) {
    // TODO: Implement analytics
  }
}
