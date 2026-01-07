import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sport_event_entity.dart';
import '../providers/sports_providers.dart';

/// Sports Settings Screen for managing preferences
class SportsSettingsScreen extends ConsumerStatefulWidget {
  const SportsSettingsScreen({super.key});

  @override
  ConsumerState<SportsSettingsScreen> createState() =>
      _SportsSettingsScreenState();
}

class _SportsSettingsScreenState extends ConsumerState<SportsSettingsScreen> {
  Set<SportType> _selectedSports = {};
  Set<League> _selectedLeagues = {};
  String? _selectedRegion;
  bool _notificationsEnabled = true;
  bool _liveScoreUpdates = true;
  bool _matchReminders = true;
  bool _freeToAirAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final prefsAsync = ref.read(userSportsPreferencesProvider);
    prefsAsync.whenData((prefs) {
      if (mounted) {
        setState(() {
          _selectedSports = prefs.favoriteSports.toSet();
          _selectedLeagues = prefs.favoriteLeagues.toSet();
          _selectedRegion = prefs.region;
        });
      }
    });
  }

  Future<void> _savePreferences() async {
    final preferences = UserSportsPreferences(
      favoriteSports: _selectedSports.toList(),
      favoriteLeagues: _selectedLeagues.toList(),
      region: _selectedRegion,
    );

    await ref.read(sportsUseCasesProvider).updateUserPreferences(preferences);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableLeaguesAsync = ref.watch(availableLeaguesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Settings'),
        actions: [
          TextButton(onPressed: _savePreferences, child: const Text('SAVE')),
        ],
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Favorite Sports'),
          _buildSportsSection(),
          const Divider(),

          _SectionHeader(title: 'Favorite Leagues'),
          _buildLeaguesSection(availableLeaguesAsync),
          const Divider(),

          _SectionHeader(title: 'Region'),
          _buildRegionSection(),
          const Divider(),

          _SectionHeader(title: 'Notifications'),
          _buildNotificationsSection(),
          const Divider(),

          _SectionHeader(title: 'About'),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSportsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your favorite sports to personalize your feed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                avatar: Icon(_getSportIcon(sport), size: 18),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaguesSection(AsyncValue<List<League>> leagues) {
    return leagues.when(
      data: (leaguesList) {
        if (leaguesList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No leagues available'),
          );
        }

        // Group leagues by sport type
        final groupedLeagues = <SportType, List<League>>{};
        for (final league in leaguesList) {
          groupedLeagues.putIfAbsent(league.sportType, () => []).add(league);
        }

        return Column(
          children: groupedLeagues.entries.map((entry) {
            return ExpansionTile(
              title: Text(entry.key.displayName),
              leading: Icon(_getSportIcon(entry.key)),
              children: entry.value.map((league) {
                final isSelected = _selectedLeagues.contains(league);
                return CheckboxListTile(
                  title: Text(league.name),
                  subtitle: league.country != null
                      ? Text(league.country!)
                      : null,
                  secondary: league.logo != null
                      ? Image.network(
                          league.logo!,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.sports),
                        )
                      : const Icon(Icons.sports),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedLeagues.add(league);
                      } else {
                        _selectedLeagues.remove(league);
                      }
                    });
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error loading leagues: $error'),
      ),
    );
  }

  Widget _buildRegionSection() {
    final regions = [
      {'code': 'US', 'name': 'United States'},
      {'code': 'UK', 'name': 'United Kingdom'},
      {'code': 'CA', 'name': 'Canada'},
      {'code': 'AU', 'name': 'Australia'},
      {'code': 'NZ', 'name': 'New Zealand'},
      {'code': 'ZA', 'name': 'South Africa'},
      {'code': 'IE', 'name': 'Ireland'},
      {'code': 'IN', 'name': 'India'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your region to see available streaming services',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Region',
              prefixIcon: Icon(Icons.public),
            ),
            items: regions.map((region) {
              return DropdownMenuItem<String>(
                value: region['code'],
                child: Text(region['name']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRegion = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive notifications for matches and updates'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              if (!value) {
                _liveScoreUpdates = false;
                _matchReminders = false;
                _freeToAirAlerts = false;
              }
            });
          },
        ),
        if (_notificationsEnabled) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Live Score Updates'),
                  subtitle: const Text('Get notified when scores change'),
                  value: _liveScoreUpdates,
                  onChanged: (value) {
                    setState(() {
                      _liveScoreUpdates = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Match Reminders'),
                  subtitle: const Text('Remind me before matches start'),
                  value: _matchReminders,
                  onChanged: (value) {
                    setState(() {
                      _matchReminders = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Free-to-Air Alerts'),
                  subtitle: const Text(
                    'Notify when matches are available for free',
                  ),
                  value: _freeToAirAlerts,
                  onChanged: (value) {
                    setState(() {
                      _freeToAirAlerts = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About Sports Feature'),
          subtitle: const Text('v1.0.0'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Sports',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.sports_soccer, size: 48),
              children: [
                const Text(
                  'Aggregated sports streaming platform providing legal streaming '
                  'links from various providers. Never miss a match with live scores, '
                  'upcoming fixtures, and personalized recommendations.',
                ),
              ],
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support'),
          onTap: () {
            // TODO: Open help/support page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & Support coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () {
            // TODO: Open privacy policy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy coming soon')),
            );
          },
        ),
      ],
    );
  }

  IconData _getSportIcon(SportType sport) {
    switch (sport) {
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.tennis:
        return Icons.sports_tennis;
      case SportType.cricket:
        return Icons.sports_cricket;
      case SportType.rugby:
        return Icons.sports_rugby;
      case SportType.netball:
        return Icons.sports_volleyball; // Closest alternative
      case SportType.volleyball:
        return Icons.sports_volleyball;
      case SportType.racing:
        return Icons.sports_motorsports;
      case SportType.swimming:
        return Icons.pool;
      case SportType.hockey:
        return Icons.sports_hockey;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
