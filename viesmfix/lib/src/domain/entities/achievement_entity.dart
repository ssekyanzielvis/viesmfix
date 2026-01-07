import 'package:equatable/equatable.dart';

/// Entity representing a user achievement/badge
class AchievementEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final String iconName;
  final int xpReward;
  final AchievementRarity rarity;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  const AchievementEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    required this.xpReward,
    required this.rarity,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progressPercentage => progress / target;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    iconName,
    xpReward,
    rarity,
    unlockedAt,
    progress,
    target,
  ];

  AchievementEntity copyWith({
    String? id,
    String? name,
    String? description,
    AchievementCategory? category,
    String? iconName,
    int? xpReward,
    AchievementRarity? rarity,
    DateTime? unlockedAt,
    int? progress,
    int? target,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      xpReward: xpReward ?? this.xpReward,
      rarity: rarity ?? this.rarity,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }
}

/// Category of achievement
enum AchievementCategory {
  watchStreak,
  movieCount,
  genreExplorer,
  socialButterffly,
  critic,
  earlyBird,
  nightOwl,
  bingeMaster,
  curator,
}

/// Rarity levels
enum AchievementRarity {
  common(1, '🥉'),
  rare(2, '🥈'),
  epic(3, '🥇'),
  legendary(4, '💎');

  final int level;
  final String emoji;
  const AchievementRarity(this.level, this.emoji);
}

/// User's gamification profile
class UserGamificationProfile extends Equatable {
  final String userId;
  final int totalXp;
  final int level;
  final int currentLevelXp;
  final int nextLevelXp;
  final List<AchievementEntity> achievements;
  final WatchStreak currentStreak;
  final WatchStreak longestStreak;
  final Map<String, int> stats;

  const UserGamificationProfile({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.achievements,
    required this.currentStreak,
    required this.longestStreak,
    required this.stats,
  });

  double get levelProgress => currentLevelXp / nextLevelXp;
  int get unlockedAchievements =>
      achievements.where((a) => a.isUnlocked).length;

  @override
  List<Object?> get props => [
    userId,
    totalXp,
    level,
    currentLevelXp,
    nextLevelXp,
    achievements,
    currentStreak,
    longestStreak,
    stats,
  ];
}

/// Watch streak data
class WatchStreak extends Equatable {
  final int days;
  final DateTime lastWatchDate;
  final DateTime streakStartDate;

  const WatchStreak({
    required this.days,
    required this.lastWatchDate,
    required this.streakStartDate,
  });

  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastWatchDate);
    return difference.inDays <= 1;
  }

  @override
  List<Object?> get props => [days, lastWatchDate, streakStartDate];
}

/// Predefined achievements
class Achievements {
  static const List<AchievementEntity> all = [
    AchievementEntity(
      id: 'first_watch',
      name: 'First Steps',
      description: 'Watch your first movie',
      category: AchievementCategory.movieCount,
      iconName: 'movie',
      xpReward: 50,
      rarity: AchievementRarity.common,
      target: 1,
    ),
    AchievementEntity(
      id: 'movie_buff',
      name: 'Movie Buff',
      description: 'Watch 50 movies',
      category: AchievementCategory.movieCount,
      iconName: 'local_movies',
      xpReward: 500,
      rarity: AchievementRarity.rare,
      target: 50,
    ),
    AchievementEntity(
      id: 'cinephile',
      name: 'Cinephile',
      description: 'Watch 100 movies',
      category: AchievementCategory.movieCount,
      iconName: 'theaters',
      xpReward: 1000,
      rarity: AchievementRarity.epic,
      target: 100,
    ),
    AchievementEntity(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: 'Maintain a 7-day watch streak',
      category: AchievementCategory.watchStreak,
      iconName: 'local_fire_department',
      xpReward: 300,
      rarity: AchievementRarity.rare,
      target: 7,
    ),
    AchievementEntity(
      id: 'month_master',
      name: 'Month Master',
      description: 'Maintain a 30-day watch streak',
      category: AchievementCategory.watchStreak,
      iconName: 'whatshot',
      xpReward: 1500,
      rarity: AchievementRarity.legendary,
      target: 30,
    ),
    AchievementEntity(
      id: 'genre_explorer',
      name: 'Genre Explorer',
      description: 'Watch movies from 10 different genres',
      category: AchievementCategory.genreExplorer,
      iconName: 'explore',
      xpReward: 400,
      rarity: AchievementRarity.rare,
      target: 10,
    ),
    AchievementEntity(
      id: 'social_butterfly',
      name: 'Social Butterfly',
      description: 'Make 10 friends',
      category: AchievementCategory.socialButterffly,
      iconName: 'people',
      xpReward: 250,
      rarity: AchievementRarity.common,
      target: 10,
    ),
    AchievementEntity(
      id: 'critic_corner',
      name: 'Critic\'s Corner',
      description: 'Write 25 reviews',
      category: AchievementCategory.critic,
      iconName: 'rate_review',
      xpReward: 600,
      rarity: AchievementRarity.epic,
      target: 25,
    ),
  ];
}
