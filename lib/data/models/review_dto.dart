import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

class ReviewDto {
  final String userId;
  final String userName;
  final String? workshopId;
  final String? workshopTitle;
  final String type;
  final int rating;
  final String comment;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const ReviewDto({
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

  /// Creates ReviewDto from Firestore document
  factory ReviewDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewDto(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      workshopId: data['workshopId'],
      workshopTitle: data['workshopTitle'],
      type: data['type'] ?? 'workshop',
      rating: data['rating'] ?? 1,
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
    );
  }

  /// Creates ReviewDto from domain entity
  factory ReviewDto.fromDomain(Review review) {
    return ReviewDto(
      userId: review.userId,
      userName: review.userName,
      workshopId: review.workshopId,
      workshopTitle: review.workshopTitle,
      type: review.type.name,
      rating: review.rating,
      comment: review.comment,
      createdAt: Timestamp.fromDate(review.createdAt),
      updatedAt: review.updatedAt != null 
          ? Timestamp.fromDate(review.updatedAt!) 
          : null,
    );
  }

  /// Converts to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'workshopId': workshopId,
      'workshopTitle': workshopTitle,
      'type': type,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Converts to domain entity
  Review toDomain(String id) {
    return Review(
      id: id,
      userId: userId,
      userName: userName,
      workshopId: workshopId,
      workshopTitle: workshopTitle,
      type: ReviewType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ReviewType.workshop,
      ),
      rating: rating,
      comment: comment,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }
}