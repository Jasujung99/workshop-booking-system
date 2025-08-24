import 'package:equatable/equatable.dart';

class Workshop extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final int capacity;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.capacity,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this Workshop with the given fields replaced with new values
  Workshop copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    int? capacity,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workshop(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validates workshop data
  static String? validateTitle(String? title) {
    if (title == null || title.isEmpty) {
      return '워크샵 제목을 입력해주세요';
    }
    
    if (title.length < 3) {
      return '제목은 3글자 이상이어야 합니다';
    }
    
    if (title.length > 100) {
      return '제목은 100글자 이하여야 합니다';
    }
    
    return null;
  }

  static String? validateDescription(String? description) {
    if (description == null || description.isEmpty) {
      return '워크샵 설명을 입력해주세요';
    }
    
    if (description.length < 10) {
      return '설명은 10글자 이상이어야 합니다';
    }
    
    if (description.length > 1000) {
      return '설명은 1000글자 이하여야 합니다';
    }
    
    return null;
  }

  static String? validatePrice(double? price) {
    if (price == null) {
      return '가격을 입력해주세요';
    }
    
    if (price < 0) {
      return '가격은 0원 이상이어야 합니다';
    }
    
    if (price > 1000000) {
      return '가격은 1,000,000원 이하여야 합니다';
    }
    
    return null;
  }

  static String? validateCapacity(int? capacity) {
    if (capacity == null) {
      return '정원을 입력해주세요';
    }
    
    if (capacity < 1) {
      return '정원은 1명 이상이어야 합니다';
    }
    
    if (capacity > 100) {
      return '정원은 100명 이하여야 합니다';
    }
    
    return null;
  }

  /// Formats price as Korean Won
  String get formattedPrice {
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Checks if workshop has available capacity
  bool hasAvailableCapacity(int currentBookings) {
    return currentBookings < capacity;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        capacity,
        imageUrl,
        tags,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Workshop(id: $id, title: $title, price: $price, capacity: $capacity)';
  }
}
/// 
Filter class for workshop queries
class WorkshopFilter extends Equatable {
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;

  const WorkshopFilter({
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.tags,
    this.startDate,
    this.endDate,
  });

  /// Creates an empty filter
  factory WorkshopFilter.empty() {
    return const WorkshopFilter();
  }

  /// Creates a copy of this filter with the given fields replaced
  WorkshopFilter copyWith({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return WorkshopFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      tags: tags ?? this.tags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Checks if filter is empty
  bool get isEmpty {
    return searchQuery == null &&
        minPrice == null &&
        maxPrice == null &&
        (tags == null || tags!.isEmpty) &&
        startDate == null &&
        endDate == null;
  }

  /// Checks if filter has any criteria
  bool get hasFilters => !isEmpty;

  @override
  List<Object?> get props => [
        searchQuery,
        minPrice,
        maxPrice,
        tags,
        startDate,
        endDate,
      ];

  @override
  String toString() {
    return 'WorkshopFilter(searchQuery: $searchQuery, minPrice: $minPrice, maxPrice: $maxPrice, tags: $tags)';
  }
}