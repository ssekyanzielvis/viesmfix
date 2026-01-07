import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../providers/sports_providers.dart';
import 'package:intl/intl.dart';
import '../utils/sports_navigation.dart';
import '../widgets/sports_countdown_widget.dart';

/// Main Sports Screen with Live and Upcoming tabs
class SportsScreen extends ConsumerStatefulWidget {
  const SportsScreen({super.key});

  @override
  ConsumerState<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends ConsumerState<SportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Live',
              icon: Icon(Icons.circle, color: Colors.red, size: 12),
            ),
            Tab(text: 'Upcoming'),
            Tab(text: 'My Sports'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/sports/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/sports/bookmarks');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/sports/settings');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveMatchesTab(),
          UpcomingMatchesTab(),
          MyMatchesTab(),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Sports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SportType.values.map((sport) {
            return ListTile(
              title: Text(sport.displayName),
              onTap: () {
                ref.read(selectedSportTypeProvider.notifier).state = sport;
                Navigator.pop(context);
                ref
                    .read(liveMatchesProvider.notifier)
                    .fetchLiveMatches(sportType: sport);
                ref
                    .read(upcomingMatchesProvider.notifier)
                    .fetchUpcomingMatches(sportType: sport);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Live Matches Tab
class LiveMatchesTab extends ConsumerWidget {
  const LiveMatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMatchesAsync = ref.watch(liveMatchesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(liveMatchesProvider.notifier).refresh();
      },
      child: liveMatchesAsync.when(
        data: (matches) {
          if (matches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No live matches at the moment'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchCard(match: matches[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () =>
                    ref.read(liveMatchesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upcoming Matches Tab
class UpcomingMatchesTab extends ConsumerWidget {
  const UpcomingMatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingMatchesAsync = ref.watch(upcomingMatchesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(upcomingMatchesProvider.notifier).refresh();
      },
      child: upcomingMatchesAsync.when(
        data: (matches) {
          if (matches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No upcoming matches'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchCard(match: matches[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () =>
                    ref.read(upcomingMatchesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// My Matches Tab
class MyMatchesTab extends ConsumerWidget {
  const MyMatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myMatchesAsync = ref.watch(myMatchesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(myMatchesProvider.notifier).refresh();
      },
      child: myMatchesAsync.when(
        data: (matches) {
          if (matches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No matches from your favorite leagues'),
                  SizedBox(height: 8),
                  Text(
                    'Add leagues to your favorites to see matches here',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchCard(match: matches[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Match Card Widget
class MatchCard extends ConsumerWidget {
  final SportEventEntity match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/sportsMatchDetail', arguments: match);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // League and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.league.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (match.isLive) const LiveIndicator(size: 12),
                ],
              ),
              const SizedBox(height: 12),

              // Teams and score
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        if (match.homeTeamLogo != null)
                          Image.network(
                            match.homeTeamLogo!,
                            height: 32,
                            width: 32,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.sports),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          match.homeTeam,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (match.score != null)
                          Text(
                            '${match.score!.homeScore} - ${match.score!.awayScore}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else if (match.status == EventStatus.upcoming)
                          CountdownTimer(
                            targetTime: match.startTime,
                            compact: true,
                          )
                        else
                          Text(
                            DateFormat('HH:mm').format(match.startTime),
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (match.score?.time != null)
                          Text(
                            match.score!.time!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        if (match.awayTeamLogo != null)
                          Image.network(
                            match.awayTeamLogo!,
                            height: 32,
                            width: 32,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.sports),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          match.awayTeam,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Streaming options
              if (match.streamingOptions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.tv, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      'Watch on: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: match.streamingOptions.take(3).map((option) {
                          return Chip(
                            label: Text(
                              option.provider.name,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      match.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () async {
                      final useCases = ref.read(sportsUseCasesProvider);
                      await useCases.toggleBookmark(match);
                      ref.invalidate(bookmarkedMatchesProvider);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      match.hasNotification
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                    ),
                    onPressed: () async {
                      final useCases = ref.read(sportsUseCasesProvider);
                      await useCases.toggleNotification(match);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Match Detail Screen
class MatchDetailScreen extends ConsumerWidget {
  final SportEventEntity match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamingOptionsAsync = ref.watch(streamingOptionsProvider(match.id));

    // Track analytics when match is viewed
    SportsAnalytics.logMatchViewed(match);

    return Scaffold(
      appBar: AppBar(
        title: Text('${match.homeTeam} vs ${match.awayTeam}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              SportsCalendarIntegration.addMatchToCalendar(context, match);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to calendar')),
              );
            },
          ),
          IconButton(
            icon: Icon(
              match.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () async {
              final useCases = ref.read(sportsUseCasesProvider);
              await useCases.toggleBookmark(match);
              SportsAnalytics.logMatchBookmarked(match);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match header
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    match.league.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          if (match.homeTeamLogo != null)
                            Image.network(
                              match.homeTeamLogo!,
                              height: 64,
                              width: 64,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            match.homeTeam,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          if (match.score != null)
                            Text(
                              '${match.score!.homeScore} - ${match.score!.awayScore}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            Text(
                              DateFormat(
                                'MMM d, HH:mm',
                              ).format(match.startTime),
                              style: const TextStyle(fontSize: 16),
                            ),
                          if (match.isLive)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          if (match.awayTeamLogo != null)
                            Image.network(
                              match.awayTeamLogo!,
                              height: 64,
                              width: 64,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            match.awayTeam,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (match.venue != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(match.venue!),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Streaming options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where to Watch',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  streamingOptionsAsync.when(
                    data: (options) {
                      if (options.isEmpty) {
                        return const Text('No streaming options available');
                      }
                      return Column(
                        children: options
                            .map(
                              (option) => StreamingOptionTile(
                                option: option,
                                match: match,
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Streaming Option Tile
class StreamingOptionTile extends StatelessWidget {
  final StreamingOption option;
  final SportEventEntity match;

  const StreamingOptionTile({
    super.key,
    required this.option,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: option.provider.logo != null
            ? Image.network(option.provider.logo!, width: 40)
            : const Icon(Icons.tv),
        title: Text(option.provider.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.provider.type.displayName),
            if (option.requiresSubscription && option.subscriptionPrice != null)
              Text('\$${option.subscriptionPrice}/month'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            StreamingDeepLinks.launchStreamingOption(option, context: context);
            SportsAnalytics.logStreamingLinkClicked(option, match);
          },
          child: const Text('Watch'),
        ),
      ),
    );
  }
}
