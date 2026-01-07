import 'package:flutter/material.dart';
import '../../domain/entities/achievement_entity.dart';

/// Badge widget for displaying achievements
class AchievementBadge extends StatelessWidget {
  final AchievementEntity achievement;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getRarityColors(achievement.rarity),
                )
              : null,
          color: isUnlocked ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? _getRarityColors(achievement.rarity)[0]
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.white.withOpacity(0.2)
                        : theme.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(achievement.iconName),
                    size: 32,
                    color: isUnlocked
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
                if (!isUnlocked)
                  const Icon(Icons.lock, size: 24, color: Colors.white54),
              ],
            ),
            const SizedBox(height: 12),

            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.white.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                achievement.rarity.emoji,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),

            // Name
            Text(
              achievement.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUnlocked
                    ? Colors.white.withOpacity(0.9)
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (showProgress && !isUnlocked) ...[
              const SizedBox(height: 12),
              _buildProgressBar(theme),
            ],

            if (isUnlocked) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: achievement.progressPercentage,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievement.progress}/${achievement.target}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<Color> _getRarityColors(AchievementRarity rarity) {
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'movie':
        return Icons.movie;
      case 'local_movies':
        return Icons.local_movies;
      case 'theaters':
        return Icons.theaters;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'explore':
        return Icons.explore;
      case 'people':
        return Icons.people;
      case 'rate_review':
        return Icons.rate_review;
      default:
        return Icons.emoji_events;
    }
  }
}
