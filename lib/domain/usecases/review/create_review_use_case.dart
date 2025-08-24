import '../../entities/review.dart';
import '../../repositories/review_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class CreateReviewUseCase {
  final ReviewRepository _repository;

  CreateReviewUseCase(this._repository);

  Future<Result<Review>> execute({
    required String userId,
    required String userName,
    String? workshopId,
    String? workshopTitle,
    required ReviewType type,
    required int rating,
    required String comment,
  }) async {
    // Validate input
    final ratingError = Review.validateRating(rating);
    if (ratingError != null) {
      return Failure(ValidationException(ratingError));
    }

    final commentError = Review.validateComment(comment);
    if (commentError != null) {
      return Failure(ValidationException(commentError));
    }

    // Validate workshop review requirements
    if (type == ReviewType.workshop) {
      if (workshopId == null || workshopId.isEmpty) {
        return const Failure(ValidationException('워크샵 ID가 필요합니다'));
      }
      if (workshopTitle == null || workshopTitle.isEmpty) {
        return const Failure(ValidationException('워크샵 제목이 필요합니다'));
      }
    }

    // Create review
    final review = Review(
      id: '', // Will be set by repository
      userId: userId,
      userName: userName,
      workshopId: workshopId,
      workshopTitle: workshopTitle,
      type: type,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    return await _repository.createReview(review);
  }
}