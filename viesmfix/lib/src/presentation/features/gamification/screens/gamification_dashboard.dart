import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/achievement_entity.dart';
import '../../../../domain/entities/trivia_entity.dart';

/// Gamification dashboard with leaderboards
class GamificationDashboard extends ConsumerStatefulWidget {
  const GamificationDashboard({super.key});

  @override
  ConsumerState<GamificationDashboard> createState() =>
      _GamificationDashboardState();
}

class _GamificationDashboardState extends ConsumerState<GamificationDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Get from provider
    final userProfile = _getMockUserProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard)),
            Tab(text: 'Rewards', icon: Icon(Icons.card_giftcard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(userProfile, theme),
          _buildAchievementsTab(userProfile, theme),
          _buildLeaderboardTab(theme),
          _buildRewardsTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(UserGamificationProfile profile, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level card
          Card(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Text(
                            '${profile.level}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${profile.level}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${profile.currentLevelXp} / ${profile.nextLevelXp} XP',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: profile.levelProgress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Total XP',
                        '${profile.totalXp}',
                        Icons.stars,
                        Colors.white,
                      ),
                      _buildStatColumn(
                        'Achievements',
                        '${profile.unlockedAchievements}/${profile.achievements.length}',
                        Icons.emoji_events,
                        Colors.white,
                      ),
                      _buildStatColumn(
                        'Streak',
                        '${profile.currentStreak.days}',
                        Icons.local_fire_department,
                        Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent achievements
          Text(
            'Recent Unlocks',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...profile.achievements.where((a) => a.isUnlocked).take(3).map((
            achievement,
          ) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getAchievementGradient(achievement.rarity),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.white),
                ),
                title: Text(achievement.name),
                subtitle: Text(achievement.description),
                trailing: Text(
                  '+${achievement.xpReward} XP',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(
    UserGamificationProfile profile,
    ThemeData theme,
  ) {
    final locked = profile.achievements.where((a) => !a.isUnlocked).toList();
    final unlocked = profile.achievements.where((a) => a.isUnlocked).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Unlocked'),
              Tab(text: 'Locked'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAchievementGrid(unlocked, theme),
                _buildAchievementGrid(locked, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid(
    List<AchievementEntity> achievements,
    ThemeData theme,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: achievement.isUnlocked
                        ? LinearGradient(
                            colors: _getAchievementGradient(achievement.rarity),
                          )
                        : null,
                    color: achievement.isUnlocked
                        ? null
                        : theme.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 32,
                    color: achievement.isUnlocked
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  achievement.rarity.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    minHeight: 4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress}/${achievement.target}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab(ThemeData theme) {
    // TODO: Get from provider
    final leaderboard = _getMockLeaderboard();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        final isCurrentUser = index == 0; // Mock

        return Card(
          color: isCurrentUser ? theme.colorScheme.primaryContainer : null,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRankColor(entry.rank),
                  child: Text(
                    '#${entry.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (entry.rank <= 3)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      _getRankEmoji(entry.rank),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  entry.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('You'),
                    padding: EdgeInsets.zero,
                    labelStyle: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
            subtitle: Text(
              '${entry.quizzesCompleted} quizzes • ${entry.averageAccuracy.toStringAsFixed(0)}% accuracy',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalScore}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text('points', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.card_giftcard, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'Unlock Rewards',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Level up and complete achievements to unlock exclusive rewards',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._buildRewardsList(theme),
      ],
    );
  }

  List<Widget> _buildRewardsList(ThemeData theme) {
    final rewards = [
      ('Premium Dark Theme', 'Level 5', Icons.palette, false),
      ('Custom Profile Banner', 'Level 10', Icons.image, false),
      ('Ad-Free Experience', 'Level 15', Icons.block, false),
      ('Exclusive Badges', 'Level 20', Icons.verified, true),
    ];

    return rewards.map((reward) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: reward.$4
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainer,
            child: Icon(
              reward.$3,
              color: reward.$4 ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          title: Text(reward.$1),
          subtitle: Text(reward.$4 ? 'Unlocked!' : 'Requires ${reward.$2}'),
          trailing: reward.$4
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.lock_outline),
        ),
      );
    }).toList();
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  List<Color> _getAchievementGradient(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return [const Color(0xFF8B7355), const Color(0xFF6B5344)];
      case AchievementRarity.rare:
        return [const Color(0xFF4A90E2), const Color(0xFF357ABD)];
      case AchievementRarity.epic:
        return [const Color(0xFF9B59B6), const Color(0xFF7D3C98)];
      case AchievementRarity.legendary:
        return [const Color(0xFFFFD700), const Color(0xFFDAA520)];
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return Colors.grey;
  }

  String _getRankEmoji(int rank) {
    if (rank == 1) return '👑';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '';
  }

  UserGamificationProfile _getMockUserProfile() {
    return UserGamificationProfile(
      userId: 'user_123',
      totalXp: 3450,
      level: 8,
      currentLevelXp: 450,
      nextLevelXp: 1000,
      achievements: Achievements.all,
      currentStreak: WatchStreak(
        days: 12,
        lastWatchDate: DateTime(2026, 1, 7),
        streakStartDate: DateTime(2025, 12, 26),
      ),
      longestStreak: WatchStreak(
        days: 25,
        lastWatchDate: DateTime(2025, 11, 15),
        streakStartDate: DateTime(2025, 10, 21),
      ),
      stats: {'movies_watched': 47, 'reviews_written': 12, 'friends': 8},
    );
  }

  List<TriviaLeaderboardEntry> _getMockLeaderboard() {
    return [
      const TriviaLeaderboardEntry(
        userId: 'user_123',
        username: 'You',
        totalScore: 1850,
        quizzesCompleted: 23,
        averageAccuracy: 78.5,
        rank: 1,
        streak: 5,
      ),
      const TriviaLeaderboardEntry(
        userId: 'user_456',
        username: 'MovieBuff2024',
        totalScore: 1720,
        quizzesCompleted: 28,
        averageAccuracy: 75.2,
        rank: 2,
      ),
      const TriviaLeaderboardEntry(
        userId: 'user_789',
        username: 'CinemaExpert',
        totalScore: 1680,
        quizzesCompleted: 21,
        averageAccuracy: 82.1,
        rank: 3,
      ),
    ];
  }
}
