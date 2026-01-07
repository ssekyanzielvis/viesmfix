import '../entities/review_entity.dart';

/// Repository interface for movie reviews
abstract class ReviewRepository {
  /// Get reviews for a specific movie
  Future<List<ReviewEntity>> getMovieReviews(
    int movieId, {
    int page = 1,
    int limit = 20,
    String sortBy = 'latest', // latest, highest_rated, most_helpful
  });

  /// Get reviews by a specific user
  Future<List<ReviewEntity>> getUserReviews(
    String userId, {
    int page = 1,
    int limit = 20,
  });

  /// Get a single review by ID
  Future<ReviewEntity?> getReviewById(String reviewId);

  /// Create a new review
  Future<ReviewEntity> createReview({
    required int movieId,
    required String movieTitle,
    required double rating,
    String? title,
    required String content,
    bool containsSpoilers = false,
  });

  /// Update an existing review
  Future<ReviewEntity> updateReview({
    required String reviewId,
    required double rating,
    String? title,
    required String content,
    bool containsSpoilers = false,
  });

  /// Delete a review
  Future<void> deleteReview(String reviewId);

  /// Like/unlike a review
  Future<void> toggleReviewLike(String reviewId);

  /// Get current user's review for a movie (if exists)
  Future<ReviewEntity?> getMyReviewForMovie(int movieId);
}
