import '../../entities/review_entity.dart';
import '../../repositories/review_repository.dart';

/// Use case for creating a movie review
class CreateReview {
  final ReviewRepository _repository;

  CreateReview(this._repository);

  Future<ReviewEntity> execute({
    required int movieId,
    required String movieTitle,
    required double rating,
    String? title,
    required String content,
    bool containsSpoilers = false,
  }) async {
    // Validate rating
    if (rating < 0.0 || rating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }

    // Validate content
    if (content.trim().isEmpty) {
      throw ArgumentError('Review content cannot be empty');
    }

    if (content.trim().length < 10) {
      throw ArgumentError('Review content must be at least 10 characters');
    }

    return await _repository.createReview(
      movieId: movieId,
      movieTitle: movieTitle,
      rating: rating,
      title: title,
      content: content,
      containsSpoilers: containsSpoilers,
    );
  }
}
