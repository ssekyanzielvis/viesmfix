import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/journal_entry_entity.dart';

/// Screen for creating/editing journal entries
class CreateJournalEntryScreen extends ConsumerStatefulWidget {
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final CinematicJournalEntry? existingEntry;

  const CreateJournalEntryScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    this.existingEntry,
  });

  @override
  ConsumerState<CreateJournalEntryScreen> createState() =>
      _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState
    extends ConsumerState<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _thoughtsController = TextEditingController();
  double _rating = 0.0;
  DateTime _watchedOn = DateTime.now();
  final List<String> _selectedEmotions = [];
  final List<String> _memorableQuotes = [];
  final _quoteController = TextEditingController();
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _loadExistingEntry();
    }
  }

  void _loadExistingEntry() {
    final entry = widget.existingEntry!;
    _thoughtsController.text = entry.thoughts ?? '';
    _rating = entry.rating ?? 0.0;
    _watchedOn = entry.watchedOn;
    _selectedEmotions.addAll(entry.emotions);
    _memorableQuotes.addAll(entry.memorableQuotes);
    _isPublic = entry.isPublic;
  }

  @override
  void dispose() {
    _thoughtsController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEntry != null ? 'Edit Entry' : 'New Journal Entry',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_camera_front),
            onPressed: _recordVideoReaction,
            tooltip: 'Record Video Reaction',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie header
              _buildMovieHeader(theme),
              const SizedBox(height: 24),

              // Watch date
              _buildWatchDatePicker(theme),
              const SizedBox(height: 24),

              // Rating
              _buildRatingSection(theme),
              const SizedBox(height: 24),

              // Emotions
              _buildEmotionsSection(theme),
              const SizedBox(height: 24),

              // Thoughts
              _buildThoughtsSection(theme),
              const SizedBox(height: 24),

              // Memorable quotes
              _buildQuotesSection(theme),
              const SizedBox(height: 24),

              // Privacy toggle
              _buildPrivacyToggle(theme),
              const SizedBox(height: 32),

              // Save button
              FilledButton(
                onPressed: _saveEntry,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Save to Journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.moviePosterPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w92${widget.moviePosterPath}',
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movieTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Watched on ${_formatDate(_watchedOn)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchDatePicker(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _watchedOn,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _watchedOn = date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'When did you watch this?',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(_formatDate(_watchedOn)),
      ),
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Rating',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                size: 40,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() => _rating = (index + 1).toDouble());
              },
            );
          }),
        ),
        if (_rating > 0)
          Center(
            child: Text(
              '${_rating.toInt()}/5',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmotionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did it make you feel?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: JournalEmotions.all.map((emotion) {
            final isSelected = _selectedEmotions.contains(emotion);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(JournalEmotions.emojis[emotion] ?? ''),
                  const SizedBox(width: 4),
                  Text(emotion),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEmotions.add(emotion);
                  } else {
                    _selectedEmotions.remove(emotion);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThoughtsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Thoughts',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _thoughtsController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'What did you think about this movie?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memorable Quotes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._memorableQuotes.map((quote) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.format_quote),
              title: Text(quote),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _memorableQuotes.remove(quote));
                },
              ),
            ),
          );
        }),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quoteController,
                decoration: const InputDecoration(
                  hintText: 'Add a memorable quote',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                if (_quoteController.text.isNotEmpty) {
                  setState(() {
                    _memorableQuotes.add(_quoteController.text);
                    _quoteController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle(ThemeData theme) {
    return SwitchListTile(
      title: const Text('Make this entry public'),
      subtitle: const Text('Share your thoughts with the community'),
      value: _isPublic,
      onChanged: (value) {
        setState(() => _isPublic = value);
      },
    );
  }

  void _recordVideoReaction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Video Reaction'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_camera_front, size: 64),
            SizedBox(height: 16),
            Text(
              'Record your immediate reaction or thoughts about the movie',
              textAlign: TextAlign.center,
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
              // TODO: Open camera for video recording
            },
            child: const Text('Start Recording'),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to database
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Journal entry saved!')));
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
