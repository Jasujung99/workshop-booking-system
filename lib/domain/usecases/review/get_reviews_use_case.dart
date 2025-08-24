import '../../entities/review.dart';
import '../../repositories/review_repository.dart';
import '../../../core/error/result.dart';

class GetReviewsUseCase {
  final ReviewRepository _repository;

  GetReviewsUseCase(this._repository);

  Future<Result<List<Review>>> execute({ReviewFilter? filter}) async {
    return await _repository.getReviews(filter: filter);
  }

  Future<Result<List<Review>>> getWorkshopReviews(String workshopId) async {
    return await _repository.getWorkshopReviews(workshopId);
  }

  Future<Result<List<Review>>> getAppFeedback() async {
    return await _repository.getAppFeedback();
  }

  Future<Result<ReviewStats>> getWorkshopStats(String workshopId) async {
    return await _repository.getWorkshopReviewStats(workshopId);
  }
}