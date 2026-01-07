import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/mood_entity.dart';
import '../widgets/mood_selector_card.dart';
import '../widgets/mood_analytics_widget.dart';

/// Screen for mood-based movie recommendations
class MoodMatcherScreen extends ConsumerStatefulWidget {
  const MoodMatcherScreen({super.key});

  @override
  ConsumerState<MoodMatcherScreen> createState() => _MoodMatcherScreenState();
}

class _MoodMatcherScreenState extends ConsumerState<MoodMatcherScreen>
    with SingleTickerProviderStateMixin {
  MoodType? selectedMood;
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
        title: const Text('Movie Mood Matcher'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Find Movies', icon: Icon(Icons.movie_filter)),
            Tab(text: 'My Moods', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMoodSelectorTab(theme), const MoodAnalyticsWidget()],
      ),
    );
  }

  Widget _buildMoodSelectorTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'How are you feeling?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your current mood and we\'ll recommend perfect movies',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Mood Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: MoodType.values.length,
            itemBuilder: (context, index) {
              final mood = MoodType.values[index];
              return MoodSelectorCard(
                mood: mood,
                isSelected: selectedMood == mood,
                onTap: () => _handleMoodSelection(mood),
              );
            },
          ),

          const SizedBox(height: 32),

          // Recent mood suggestions
          if (selectedMood == null) ...[
            Text(
              'Recent Mood Matches',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentMoodsList(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentMoodsList(ThemeData theme) {
    // TODO: Get from provider
    final recentMoods = <MoodType>[
      MoodType.happy,
      MoodType.romantic,
      MoodType.thoughtful,
    ];

    return Column(
      children: recentMoods.map((mood) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
            ),
            title: Text(mood.label),
            subtitle: Text(mood.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _handleMoodSelection(mood),
          ),
        );
      }).toList(),
    );
  }

  void _handleMoodSelection(MoodType mood) {
    setState(() {
      selectedMood = mood;
    });

    // Navigate to mood recommendations
    // TODO: Implement navigation to mood-based recommendations
    Navigator.pushNamed(context, '/mood-recommendations', arguments: mood);
  }
}
