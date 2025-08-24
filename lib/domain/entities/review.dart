import 'package:equatable/equatable.dart';

enum ReviewType {
  workshop,
  app,
}

class Review extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? workshopId;
  final String? workshopTitle;
  final ReviewType type;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.workshopId,
    this.workshopTitle,
    required this.type,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this Review with the given fields replaced with new values
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? workshopId,
    String? workshopTitle,
    ReviewType? type,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      workshopId: workshopId ?? this.workshopId,
      workshopTitle: workshopTitle ?? this.workshopTitle,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validates review data
  static String? validateRating(int? rating) {
    if (rating == null) {
      return '별점을 선택해주세요';
    }
    
    if (rating < 1 || rating > 5) {
      return '별점은 1~5점 사이여야 합니다';
    }
    
    return null;
  }

  static String? validateComment(String? comment) {
    if (comment == null || comment.isEmpty) {
      return '후기를 입력해주세요';
    }
    
    if (comment.length < 10) {
      return '후기는 10글자 이상 입력해주세요';
    }
    
    if (comment.length > 500) {
      return '후기는 500글자 이하로 입력해주세요';
    }
    
    return null;
  }

  /// Gets star display string
  String get starDisplay {
    return '★' * rating + '☆' * (5 - rating);
  }

  /// Checks if this is a workshop review
  bool get isWorkshopReview => type == ReviewType.workshop;

  /// Checks if this is an app feedback
  bool get isAppFeedback => type == ReviewType.app;

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        workshopId,
        workshopTitle,
        type,
        rating,
        comment,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, type: $type, rating: $rating, workshopId: $workshopId)';
  }
}

/// Filter class for review queries
class ReviewFilter extends Equatable {
  final String? workshopId;
  final ReviewType? type;
  final int? minRating;
  final int? maxRating;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReviewFilter({
    this.workshopId,
    this.type,
    this.minRating,
    this.maxRating,
    this.startDate,
    this.endDate,
  });

  /// Creates an empty filter
  factory ReviewFilter.empty() {
    return const ReviewFilter();
  }

  /// Creates a filter for workshop reviews
  factory ReviewFilter.forWorkshop(String workshopId) {
    return ReviewFilter(
      workshopId: workshopId,
      type: ReviewType.workshop,
    );
  }

  /// Creates a filter for app feedback
  factory ReviewFilter.forAppFeedback() {
    return const ReviewFilter(
      type: ReviewType.app,
    );
  }

  /// Creates a copy of this filter with the given fields replaced
  ReviewFilter copyWith({
    String? workshopId,
    ReviewType? type,
    int? minRating,
    int? maxRating,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReviewFilter(
      workshopId: workshopId ?? this.workshopId,
      type: type ?? this.type,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Checks if filter is empty
  bool get isEmpty {
    return workshopId == null &&
        type == null &&
        minRating == null &&
        maxRating == null &&
        startDate == null &&
        endDate == null;
  }

  @override
  List<Object?> get props => [
        workshopId,
        type,
        minRating,
        maxRating,
        startDate,
        endDate,
      ];
}