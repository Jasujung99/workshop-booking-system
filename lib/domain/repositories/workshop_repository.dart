import '../entities/workshop.dart';
import '../../core/error/result.dart';

class WorkshopFilter {
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;

  const WorkshopFilter({
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.tags,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  WorkshopFilter.empty() : this();

  WorkshopFilter copyWith({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return WorkshopFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      tags: tags ?? this.tags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

abstract class WorkshopRepository {
  /// Get workshops with optional filtering and pagination
  Future<Result<List<Workshop>>> getWorkshops({
    WorkshopFilter? filter,
    int? limit,
    String? lastDocumentId,
  });
  
  /// Get workshop by ID
  Future<Result<Workshop>> getWorkshopById(String id);
  
  /// Create new workshop
  Future<Result<Workshop>> createWorkshop(Workshop workshop);
  
  /// Update existing workshop
  Future<Result<Workshop>> updateWorkshop(Workshop workshop);
  
  /// Delete workshop
  Future<Result<void>> deleteWorkshop(String id);
  
  /// Get workshops by instructor
  Future<Result<List<Workshop>>> getWorkshopsByInstructor(String instructorId);
  
  /// Search workshops
  Future<Result<List<Workshop>>> searchWorkshops(String query);
}