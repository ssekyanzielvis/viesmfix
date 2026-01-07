import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../domain/entities/movie_dna_entity.dart';

/// Screen displaying user's movie DNA and taste profile
class MovieDNAScreen extends ConsumerWidget {
  const MovieDNAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Get from provider
    final movieDNA = _getMockMovieDNA();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Movie DNA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share DNA profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personality card
            _buildPersonalityCard(movieDNA.personality, theme),
            const SizedBox(height: 24),

            // Genre preferences chart
            _buildGenreChart(movieDNA.genrePreferences, theme),
            const SizedBox(height: 24),

            // Decade preferences
            _buildDecadeTimeline(movieDNA.decadePreferences, theme),
            const SizedBox(height: 24),

            // Favorite actors
            _buildFavoriteSection(
              'Favorite Actors',
              Icons.person,
              movieDNA.actorFrequency,
              theme,
            ),
            const SizedBox(height: 24),

            // Favorite directors
            _buildFavoriteSection(
              'Favorite Directors',
              Icons.movie_filter,
              movieDNA.directorFrequency,
              theme,
            ),
            const SizedBox(height: 24),

            // Rating insights
            _buildRatingInsights(movieDNA, theme),
            const SizedBox(height: 24),

            // Keywords cloud
            _buildKeywordsCloud(movieDNA.favoriteKeywords, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityCard(MoviePersonality personality, ThemeData theme) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(personality.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              personality.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              personality.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: personality.traits.map((trait) {
                return Chip(
                  label: Text(trait),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChart(
    Map<String, double> genrePreferences,
    ThemeData theme,
  ) {
    final sortedGenres = genrePreferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(6).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genre Preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= topGenres.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              topGenres[value.toInt()].key,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value * 100).toInt()}%',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: topGenres.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: theme.colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecadeTimeline(
    Map<int, int> decadePreferences,
    ThemeData theme,
  ) {
    final sortedDecades = decadePreferences.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxCount = sortedDecades
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favorite Decades',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...sortedDecades.map((entry) {
              final percentage = entry.value / maxCount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${entry.key}s',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${entry.value} movies',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 12,
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

  Widget _buildFavoriteSection(
    String title,
    IconData icon,
    Map<String, int> items,
    ThemeData theme,
  ) {
    final sortedItems = items.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topItems = sortedItems.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topItems.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final item = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(item.key),
                trailing: Text(
                  '${item.value} movies',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingInsights(MovieDNAEntity dna, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInsightStat(
                  'Avg Rating',
                  dna.averageRating.toStringAsFixed(1),
                  Icons.star,
                  theme,
                ),
                _buildInsightStat(
                  'Generosity',
                  dna.ratingVariance < 0.5 ? 'Consistent' : 'Varied',
                  Icons.analytics,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightStat(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordsCloud(List<String> keywords, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Movie Themes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  MovieDNAEntity _getMockMovieDNA() {
    return MovieDNAEntity(
      userId: 'user_123',
      genrePreferences: {
        'Action': 0.85,
        'Sci-Fi': 0.78,
        'Drama': 0.65,
        'Comedy': 0.55,
        'Thriller': 0.72,
        'Romance': 0.35,
      },
      actorFrequency: {
        'Tom Hanks': 12,
        'Leonardo DiCaprio': 10,
        'Scarlett Johansson': 8,
        'Denzel Washington': 7,
        'Meryl Streep': 6,
      },
      directorFrequency: {
        'Christopher Nolan': 8,
        'Steven Spielberg': 7,
        'Quentin Tarantino': 6,
        'Martin Scorsese': 5,
        'Denis Villeneuve': 4,
      },
      decadePreferences: {1990: 15, 2000: 25, 2010: 40, 2020: 20},
      moodPreferences: {
        'happy': 0.6,
        'thoughtful': 0.8,
        'adventurous': 0.9,
        'romantic': 0.3,
      },
      favoriteKeywords: [
        'Time Travel',
        'Mind-Bending',
        'Epic',
        'Space',
        'Heist',
        'Dystopian',
        'Revenge',
        'Technology',
      ],
      averageRating: 4.2,
      ratingVariance: 0.7,
      personality: MoviePersonality.theExplorer,
      lastUpdated: DateTime.now(),
    );
  }
}
