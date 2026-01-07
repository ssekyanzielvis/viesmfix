import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../providers/sports_providers.dart';
import 'package:go_router/go_router.dart';

/// Sports Search Screen with advanced filters
class SportsSearchScreen extends ConsumerStatefulWidget {
  const SportsSearchScreen({super.key});

  @override
  ConsumerState<SportsSearchScreen> createState() => _SportsSearchScreenState();
}

class _SportsSearchScreenState extends ConsumerState<SportsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<SportType> _selectedSports = {};
  EventStatus? _selectedStatus;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;

    ref
        .read(sportsUseCasesProvider)
        .searchMatches(
          query: _searchController.text.trim(),
          sportType: _selectedSports.isEmpty ? null : _selectedSports.first,
          status: _selectedStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(matchSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Matches'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search teams, leagues, or venues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // Filters Panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Sport Types',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: SportType.values.map((sport) {
                      final isSelected = _selectedSports.contains(sport);
                      return FilterChip(
                        label: Text(sport.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSports.add(sport);
                            } else {
                              _selectedSports.remove(sport);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Match Status',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedStatus == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = null;
                          });
                        },
                      ),
                      ...EventStatus.values.map((status) {
                        return ChoiceChip(
                          label: Text(status.displayName),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status : null;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedSports.clear();
                            _selectedStatus = null;
                          });
                        },
                        child: const Text('Clear Filters'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _performSearch,
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          // Search Results
          Expanded(child: _buildSearchResults(searchResults)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<SportEventEntity>> results) {
    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for matches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter teams, leagues, or venues to search',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      );
    }

    return results.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Theme.of(context).colorScheme.error.withAlpha(128),
                ),
                const SizedBox(height: 16),
                Text(
                  'No matches found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different keywords or filters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: matches.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final match = matches[index];
            return _SearchResultCard(match: match);
          },
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
              'Error loading results',
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
              onPressed: _performSearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search Result Card
class _SearchResultCard extends ConsumerWidget {
  final SportEventEntity match;

  const _SearchResultCard({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
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
              // League and Sport Type
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
                            height: 32,
                            width: 32,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shield, size: 32),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          match.homeTeam,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (match.score != null)
                          Text(
                            match.score!.homeScore.toString(),
                            style: Theme.of(context).textTheme.headlineSmall
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
                        fontSize: 16,
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
                            height: 32,
                            width: 32,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shield, size: 32),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          match.awayTeam,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.right,
                        ),
                        if (match.score != null)
                          Text(
                            match.score!.awayScore.toString(),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Venue and Time
              Row(
                children: [
                  Icon(
                    Icons.stadium,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                  const SizedBox(width: 4),
                  if (match.venue != null)
                    Expanded(
                      child: Text(
                        match.venue!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(match.startTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past event
      if (difference.inHours > -24) {
        return '${difference.inHours.abs()}h ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else {
      // Future event
      if (difference.inHours < 24) {
        return 'in ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'in ${difference.inDays}d';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    }
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
