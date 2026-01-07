import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../providers/sports_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Sports Bookmarks Screen showing all bookmarked matches
class SportsBookmarksScreen extends ConsumerWidget {
  const SportsBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Matches')),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withAlpha(128),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No bookmarked matches',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bookmark matches to watch them later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/sports');
                    },
                    icon: const Icon(Icons.sports_soccer),
                    label: const Text('Browse Matches'),
                  ),
                ],
              ),
            );
          }

          // Group bookmarks by date
          final groupedBookmarks = _groupBookmarksByDate(bookmarks);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bookmarkedMatchesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedBookmarks.length,
              itemBuilder: (context, index) {
                final group = groupedBookmarks[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        group.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...group.matches.map((match) {
                      return _BookmarkCard(match: match);
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading bookmarks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(bookmarkedMatchesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_DateGroup> _groupBookmarksByDate(List<SportEventEntity> bookmarks) {
    final Map<String, List<SportEventEntity>> grouped = {};
    final now = DateTime.now();

    for (final match in bookmarks) {
      final matchDate = match.startTime;
      String groupKey;

      if (_isSameDay(matchDate, now)) {
        groupKey = 'Today';
      } else if (_isSameDay(matchDate, now.add(const Duration(days: 1)))) {
        groupKey = 'Tomorrow';
      } else if (_isSameDay(matchDate, now.subtract(const Duration(days: 1)))) {
        groupKey = 'Yesterday';
      } else if (matchDate.isAfter(now)) {
        groupKey = 'Upcoming - ${DateFormat('MMM d').format(matchDate)}';
      } else {
        groupKey = 'Past - ${DateFormat('MMM d').format(matchDate)}';
      }

      grouped.putIfAbsent(groupKey, () => []).add(match);
    }

    // Sort groups
    final groups = grouped.entries.map((e) {
      return _DateGroup(title: e.key, matches: e.value);
    }).toList();

    groups.sort((a, b) {
      // Priority: Today > Tomorrow > Upcoming > Yesterday > Past
      final order = ['Today', 'Tomorrow', 'Upcoming', 'Yesterday', 'Past'];
      final aPrefix = order.firstWhere(
        (p) => a.title.startsWith(p),
        orElse: () => 'Other',
      );
      final bPrefix = order.firstWhere(
        (p) => b.title.startsWith(p),
        orElse: () => 'Other',
      );
      return order.indexOf(aPrefix).compareTo(order.indexOf(bPrefix));
    });

    return groups;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateGroup {
  final String title;
  final List<SportEventEntity> matches;

  _DateGroup({required this.title, required this.matches});
}

/// Bookmark Card with swipe to delete
class _BookmarkCard extends ConsumerWidget {
  final SportEventEntity match;

  const _BookmarkCard({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(match.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove bookmark'),
            content: const Text(
              'Are you sure you want to remove this bookmark?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (direction) {
        ref.read(sportsUseCasesProvider).toggleBookmark(match);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bookmark removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(sportsUseCasesProvider).toggleBookmark(match);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            context.push('/sports/match', extra: match);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // League, Sport Type, and Status
                Row(
                  children: [
                    Chip(
                      label: Text(
                        match.league.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        match.sportType.displayName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const Spacer(),
                    _StatusBadge(status: match.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Teams
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (match.homeTeamLogo != null)
                            Image.network(
                              match.homeTeamLogo!,
                              height: 40,
                              width: 40,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.shield, size: 40),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            match.homeTeam,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (match.score != null)
                            Text(
                              match.score!.homeScore.toString(),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (match.awayTeamLogo != null)
                            Image.network(
                              match.awayTeamLogo!,
                              height: 40,
                              width: 40,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.shield, size: 40),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            match.awayTeam,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.right,
                          ),
                          if (match.score != null)
                            Text(
                              match.score!.awayScore.toString(),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Time and Venue
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, h:mm a').format(match.startTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    if (match.venue != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.stadium,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(153),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.venue!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(153),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                // Streaming Options
                if (match.streamingOptions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: match.streamingOptions.take(3).map((option) {
                      return Chip(
                        avatar: option.provider.logo != null
                            ? Image.network(option.provider.logo!)
                            : const Icon(Icons.tv, size: 16),
                        label: Text(
                          option.provider.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],

                // Remove Bookmark Button
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(sportsUseCasesProvider).toggleBookmark(match);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bookmark removed')),
                      );
                    },
                    icon: const Icon(Icons.bookmark_remove, size: 16),
                    label: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final EventStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case EventStatus.live:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case EventStatus.upcoming:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        break;
      case EventStatus.finished:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        break;
      case EventStatus.postponed:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case EventStatus.cancelled:
        backgroundColor = Colors.red.shade900;
        textColor = Colors.white;
        break;
      case EventStatus.halftime:
        backgroundColor = Colors.amber;
        textColor = Colors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
