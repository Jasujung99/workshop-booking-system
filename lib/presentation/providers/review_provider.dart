import 'package:flutter/foundation.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/review/create_review_use_case.dart';
import '../../domain/usecases/review/get_reviews_use_case.dart';
import '../../core/error/result.dart';


class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;
  final CreateReviewUseCase _createReviewUseCase;
  final GetReviewsUseCase _getReviewsUseCase;

  ReviewProvider(
    this._repository,
    this._createReviewUseCase,
    this._getReviewsUseCase,
  );

  // State
  List<Review> _reviews = [];
  List<Review> _workshopReviews = [];
  List<Review> _appFeedback = [];
  ReviewStats? _currentWorkshopStats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Review> get reviews => _reviews;
  List<Review> get workshopReviews => _workshopReviews;
  List<Review> get appFeedback => _appFeedback;
  ReviewStats? get currentWorkshopStats => _currentWorkshopStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Creates a new review
  Future<bool> createReview({
    required String userId,
    required String userName,
    String? workshopId,
    String? workshopTitle,
    required ReviewType type,
    required int rating,
    required String comment,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _createReviewUseCase.execute(
      userId: userId,
      userName: userName,
      workshopId: workshopId,
      workshopTitle: workshopTitle,
      type: type,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      onSuccess: (review) {
        _reviews.insert(0, review);
        
        // Update specific lists
        if (review.isWorkshopReview) {
          _workshopReviews.insert(0, review);
        } else {
          _appFeedback.insert(0, review);
        }
        
        _setLoading(false);
        return true;
      },
      onFailure: (exception) {
        _setError(exception.toString());
        _setLoading(false);
        return false;
      },
    );
  }

  /// Loads all reviews with optional filter
  Future<void> loadReviews({ReviewFilter? filter}) async {
    _setLoading(true);
    _clearError();

    final result = await _getReviewsUseCase.execute(filter: filter);

    result.fold(
      onSuccess: (reviews) {
        _reviews = reviews;
        _setLoading(false);
      },
      onFailure: (exception) {
        _setError(exception.toString());
        _setLoading(false);
      },
    );
  }

  /// Loads reviews for a specific workshop
  Future<void> loadWorkshopReviews(String workshopId) async {
    _setLoading(true);
    _clearError();

    final result = await _getReviewsUseCase.getWorkshopReviews(workshopId);

    result.fold(
      onSuccess: (reviews) {
        _workshopReviews = reviews;
        _setLoading(false);
      },
      onFailure: (exception) {
        _setError(exception.toString());
        _setLoading(false);
      },
    );
  }

  /// Loads app feedback
  Future<void> loadAppFeedback() async {
    _setLoading(true);
    _clearError();

    final result = await _getReviewsUseCase.getAppFeedback();

    result.fold(
      onSuccess: (feedback) {
        _appFeedback = feedback;
        _setLoading(false);
      },
      onFailure: (exception) {
        _setError(exception.toString());
        _setLoading(false);
      },
    );
  }

  /// Loads workshop review statistics
  Future<void> loadWorkshopStats(String workshopId) async {
    final result = await _getReviewsUseCase.getWorkshopStats(workshopId);

    result.fold(
      onSuccess: (stats) {
        _currentWorkshopStats = stats;
        notifyListeners();
      },
      onFailure: (exception) {
        _setError(exception.toString());
      },
    );
  }

  /// Gets reviews for a specific workshop (from current state)
  List<Review> getWorkshopReviewsFromState(String workshopId) {
    return _reviews.where((review) => review.workshopId == workshopId).toList();
  }

  /// Gets average rating for a workshop (from current state)
  double getWorkshopAverageRating(String workshopId) {
    final workshopReviews = getWorkshopReviewsFromState(workshopId);
    if (workshopReviews.isEmpty) return 0.0;
    
    final totalRating = workshopReviews.fold<int>(0, (sum, review) => sum + review.rating);
    return totalRating / workshopReviews.length;
  }

  /// Clears all data
  void clearData() {
    _reviews.clear();
    _workshopReviews.clear();
    _appFeedback.clear();
    _currentWorkshopStats = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}