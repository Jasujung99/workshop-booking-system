import '../entities/review.dart';
import '../../core/error/result.dart';

abstract class ReviewRepository {
  /// Creates a new review
  Future<Result<Review>> createReview(Review review);

  /// Gets reviews by filter
  Future<Result<List<Review>>> getReviews({ReviewFilter? filter});

  /// Gets a specific review by ID
  Future<Result<Review>> getReviewById(String id);

  /// Updates an existing review
  Future<Result<Review>> updateReview(Review review);

  /// Deletes a review
  Future<Result<void>> deleteReview(String id);

  /// Gets reviews for a specific workshop
  Future<Result<List<Review>>> getWorkshopReviews(String workshopId);

  /// Gets app feedback reviews
  Future<Result<List<Review>>> getAppFeedback();

  /// Gets average rating for a workshop
  Future<Result<double>> getWorkshopAverageRating(String workshopId);

  /// Gets review statistics for a workshop
  Future<Result<ReviewStats>> getWorkshopReviewStats(String workshopId);
}

/// Statistics for workshop reviews
class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  /// Gets percentage for a specific rating
  double getRatingPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }
}