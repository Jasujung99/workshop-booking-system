import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/workshop.dart';

class WorkshopDto {
  final String title;
  final String description;
  final double price;
  final int capacity;
  final String? imageUrl;
  final List<String> tags;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const WorkshopDto({
    required this.title,
    required this.description,
    required this.price,
    required this.capacity,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  factory WorkshopDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkshopDto(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      capacity: data['capacity'] ?? 0,
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Workshop toDomain(String id) {
    return Workshop(
      id: id,
      title: title,
      description: description,
      price: price,
      capacity: capacity,
      imageUrl: imageUrl,
      tags: tags,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  static WorkshopDto fromDomain(Workshop workshop) {
    return WorkshopDto(
      title: workshop.title,
      description: workshop.description,
      price: workshop.price,
      capacity: workshop.capacity,
      imageUrl: workshop.imageUrl,
      tags: workshop.tags,
      createdAt: Timestamp.fromDate(workshop.createdAt),
      updatedAt: workshop.updatedAt != null ? Timestamp.fromDate(workshop.updatedAt!) : null,
    );
  }
}