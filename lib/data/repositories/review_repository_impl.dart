import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';
import '../models/review_dto.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'reviews';

  ReviewRepositoryImpl(this._firestore);

  @override
  Future<Result<Review>> createReview(Review review) async {
    try {
      final dto = ReviewDto.fromDomain(review);
      final docRef = await _firestore.collection(_collection).add(dto.toFirestore());
      
      final createdReview = review.copyWith(id: docRef.id);
      return Success(createdReview);
    } on FirebaseException catch (e) {
      return Failure(DatabaseException(e.message ?? 'Failed to create review'));
    } catch (e) {
      return Failure(UnknownException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Review>>> getReviews({ReviewFilter? filter}) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters
      if (filter != null) {
        if (filter.workshopId != null) {
          query = query.where('workshopId', isEqualTo: filter.workshopId);
        }
        if (filter.type != null) {
          query = query.where('type', isEqualTo: filter.type!.name);
        }
        if (filter.minRating != null) {
          query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
        }
        if (filter.maxRating != null) {
          query = query.where('rating', isLessThanOrEqualTo: filter.maxRating);
        }
        if (filter.startDate != null) {
          query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(filter.startDate!));
        }
        if (filter.endDate != null) {
          query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(filter.endDate!));
        }
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      final reviews = snapshot.docs
          .map((doc) => ReviewDto.fromFirestore(doc).toDomain(doc.id))
          .toList();

      return Success(reviews);
    } on FirebaseException catch (e) {
      return Failure(DatabaseException(e.message ?? 'Failed to get reviews'));
    } catch (e) {
      return Failure(UnknownException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Review>> getReviewById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        return const Failure(NotFoundException('Review not found'));
      }

      final review = ReviewDto.fromFirestore(doc).toDomain(doc.id);
      return Success(review);
    } on FirebaseException catch (e) {
      return Failure(DatabaseException(e.message ?? 'Failed to get review'));
    } catch (e) {
      return Failure(UnknownException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Review>> updateReview(Review review) async {
    try {
      final dto = ReviewDto.fromDomain(review.copyWith(updatedAt: DateTime.now()));
      await _firestore.collection(_collection).doc(review.id).update(dto.toFirestore());
      
      return Success(review.copyWith(updatedAt: DateTime.now()));
    } on FirebaseException catch (e) {
      return Failure(DatabaseException(e.message ?? 'Failed to update review'));
    } catch (e) {
      return Failure(UnknownException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteReview(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(DatabaseException(e.message ?? 'Failed to delete review'));
    } catch (e) {
      return Failure(UnknownException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Review>>> getWorkshopReviews(String workshopId) async {
    return await getReviews(filter: ReviewFilter.forWorkshop(workshopId));
  }

  @override
  Future<Result<List<Review>>> getAppFeedback() async {
    return await getReviews(filter: ReviewFilter.forAppFeedback());
  }

  @override
  Future<Result<double>> getWorkshopAverageRating(String workshopId) async {
    try {
      final reviewsResult = await getWorkshopReviews(workshopId);
      
      return reviewsResult.fold(
        onSuccess: (reviews) {
          if (reviews.isEmpty) return const Success(0.0);
          
          final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
          final average = totalRating / reviews.length;
          return Success(average);
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('Failed to calculate average rating: $e'));
    }
  }

  @override
  Future<Result<ReviewStats>> getWorkshopReviewStats(String workshopId) async {
    try {
      final reviewsResult = await getWorkshopReviews(workshopId);
      
      return reviewsResult.fold(
        onSuccess: (reviews) {
          if (reviews.isEmpty) {
            return const Success(ReviewStats(
              averageRating: 0.0,
              totalReviews: 0,
              ratingDistribution: {},
            ));
          }

          // Calculate average rating
          final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
          final average = totalRating / reviews.length;

          // Calculate rating distribution
          final distribution = <int, int>{};
          for (final review in reviews) {
            distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
          }

          return Success(ReviewStats(
            averageRating: average,
            totalReviews: reviews.length,
            ratingDistribution: distribution,
          ));
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('Failed to get review stats: $e'));
    }
  }
}