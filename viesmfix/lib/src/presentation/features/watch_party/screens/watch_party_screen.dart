import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/watch_party_entity.dart';

/// Screen for creating and joining watch parties
class WatchPartyScreen extends ConsumerStatefulWidget {
  final int? movieId;

  const WatchPartyScreen({super.key, this.movieId});

  @override
  ConsumerState<WatchPartyScreen> createState() => _WatchPartyScreenState();
}

class _WatchPartyScreenState extends ConsumerState<WatchPartyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Parties'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Parties', icon: Icon(Icons.groups)),
            Tab(text: 'Join Party', icon: Icon(Icons.add_circle_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyPartiesTab(theme), _buildJoinPartyTab(theme)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePartyDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create Party'),
      ),
    );
  }

  Widget _buildMyPartiesTab(ThemeData theme) {
    // TODO: Get from provider
    final activeParties = <WatchPartyEntity>[];

    if (activeParties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No active watch parties',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a party and invite friends!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeParties.length,
      itemBuilder: (context, index) {
        final party = activeParties[index];
        return _buildPartyCard(party, theme);
      },
    );
  }

  Widget _buildJoinPartyTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan QR Code',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan your friend\'s party QR code to join',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Open QR scanner
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Code'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('OR', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.link,
                    size: 64,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter Invite Code',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Have an invite code? Enter it below',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Invite Code',
                      hintText: 'XXXX-XXXX',
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Join party with code
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Join Party'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(WatchPartyEntity party, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openPartyRoom(party),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Movie poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: party.moviePosterPath != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w92${party.moviePosterPath}',
                            width: 60,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 90,
                            color: theme.colorScheme.surfaceContainer,
                            child: const Icon(Icons.movie),
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Party info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.movieTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hosted by ${party.hostUsername}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${party.members.length} watching',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  _buildStatusBadge(party.status, theme),
                ],
              ),

              // Member avatars
              if (party.members.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: Stack(
                    children: party.members
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          return Positioned(
                            left: entry.key * 24.0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                entry.value.username[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WatchPartyStatus status, ThemeData theme) {
    final statusInfo = switch (status) {
      WatchPartyStatus.scheduled => ('Scheduled', Colors.blue, Icons.schedule),
      WatchPartyStatus.active => ('Live', Colors.green, Icons.circle),
      WatchPartyStatus.paused => ('Paused', Colors.orange, Icons.pause_circle),
      WatchPartyStatus.ended => ('Ended', Colors.grey, Icons.check_circle),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.$2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.$2, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.$3, size: 14, color: statusInfo.$2),
          const SizedBox(width: 4),
          Text(
            statusInfo.$1,
            style: TextStyle(
              color: statusInfo.$2,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePartyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Watch Party'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Movie Name',
                prefixIcon: Icon(Icons.movie),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Start Time (Optional)',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Create party
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openPartyRoom(WatchPartyEntity party) {
    // TODO: Navigate to party room
    Navigator.pushNamed(context, '/watch-party-room', arguments: party.id);
  }
}
