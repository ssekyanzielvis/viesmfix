import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../widgets/custom_button.dart';
import '../widgets/rating_widget.dart';

/// Screen for writing a movie review
class WriteReviewScreen extends ConsumerStatefulWidget {
  final MovieEntity movie;
  final bool isEditing;
  final String? existingReviewId;

  const WriteReviewScreen({
    super.key,
    required this.movie,
    this.isEditing = false,
    this.existingReviewId,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  double _rating = 0.0;
  bool _containsSpoilers = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0.0) {
      context.showErrorSnackBar('Please select a rating');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Call use case to create/update review
      // final review = await ref.read(createReviewProvider).execute(
      //   movieId: widget.movie.id,
      //   movieTitle: widget.movie.title,
      //   rating: _rating,
      //   title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      //   content: _contentController.text.trim(),
      //   containsSpoilers: _containsSpoilers,
      // );

      if (mounted) {
        context.showSuccessSnackBar(
          widget.isEditing ? 'Review updated!' : 'Review published!',
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to submit review: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Review' : 'Write Review'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Movie info
            Row(
              children: [
                if (widget.movie.posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.movie.posterPath!,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 90,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.movie.releaseDate != null)
                        Text(
                          widget.movie.releaseDate!.split('-')[0],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Rating
            Text('Your Rating', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            InteractiveRatingWidget(
              initialRating: _rating,
              onRatingChanged: (rating) {
                setState(() => _rating = rating);
              },
              size: 40,
            ),
            if (_rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_rating.toStringAsFixed(1)} out of 5.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Review title (optional)
            Text('Review Title (Optional)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Summarize your review in one line',
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Review content
            Text('Your Review', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts about this movie...',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              minLines: 5,
              maxLength: 5000,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write a review';
                }
                if (value.trim().length < 10) {
                  return 'Review must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Spoiler checkbox
            CheckboxListTile(
              value: _containsSpoilers,
              onChanged: (value) {
                setState(() => _containsSpoilers = value ?? false);
              },
              title: const Text('This review contains spoilers'),
              subtitle: const Text('Warn others about spoilers in your review'),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 32),

            // Submit button
            CustomButton(
              text: widget.isEditing ? 'Update Review' : 'Publish Review',
              onPressed: _isSubmitting ? null : _submitReview,
              isLoading: _isSubmitting,
            ),

            const SizedBox(height: 16),

            // Cancel button
            CustomButton(
              text: 'Cancel',
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
