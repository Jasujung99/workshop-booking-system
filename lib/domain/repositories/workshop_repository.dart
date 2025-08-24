import '../entities/workshop.dart';
import '../../core/error/result.dart';

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