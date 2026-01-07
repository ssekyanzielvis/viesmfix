import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/mood_entity.dart';

/// Widget displaying mood analytics and history
class MoodAnalyticsWidget extends ConsumerWidget {
  const MoodAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Get from provider
    final moodHistory = _getMockMoodHistory();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your Mood Journey',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track how your movie preferences change with your emotions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Mood distribution chart
          _buildMoodDistributionCard(theme, moodHistory),
          const SizedBox(height: 24),

          // Recent mood timeline
          _buildMoodTimelineCard(theme, moodHistory),
          const SizedBox(height: 24),

          // Insights
          _buildInsightsCard(theme),
        ],
      ),
    );
  }

  Widget _buildMoodDistributionCard(
    ThemeData theme,
    Map<MoodType, int> moodHistory,
  ) {
    final total = moodHistory.values.fold<int>(0, (sum, count) => sum + count);
    final sortedEntries = moodHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...sortedEntries.take(5).map((entry) {
              final percentage = (entry.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.key.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key.label,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTimelineCard(
    ThemeData theme,
    Map<MoodType, int> moodHistory,
  ) {
    final recentMoods = [
      (MoodType.happy, DateTime.now().subtract(const Duration(days: 2))),
      (MoodType.romantic, DateTime.now().subtract(const Duration(days: 5))),
      (MoodType.adventurous, DateTime.now().subtract(const Duration(days: 7))),
      (MoodType.thoughtful, DateTime.now().subtract(const Duration(days: 10))),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Moods',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...recentMoods.map((entry) {
              final mood = entry.$1;
              final date = entry.$2;
              final daysAgo = DateTime.now().difference(date).inDays;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mood.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$daysAgo days ago',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '🎬 You tend to watch romantic movies on weekends',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '⚡ Your energy peaks on Friday evenings - perfect for action films',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '🌅 Sunday afternoons call for thoughtful, slower-paced movies',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<MoodType, int> _getMockMoodHistory() {
    return {
      MoodType.happy: 15,
      MoodType.romantic: 12,
      MoodType.adventurous: 10,
      MoodType.thoughtful: 8,
      MoodType.energetic: 6,
      MoodType.nostalgic: 5,
      MoodType.curious: 4,
      MoodType.anxious: 3,
      MoodType.sad: 2,
      MoodType.scared: 1,
    };
  }
}
