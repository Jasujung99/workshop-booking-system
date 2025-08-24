import '../../domain/entities/workshop.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../../core/error/result.dart';
import '../services/firestore_service.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final FirestoreService _firestoreService;

  WorkshopRepositoryImpl({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  @override
  Future<Result<List<Workshop>>> getWorkshops({
    WorkshopFilter? filter,
    int? limit,
    String? lastDocumentId,
  }) async {
    return await _firestoreService.getWorkshops(
      searchQuery: filter?.searchQuery,
      tags: filter?.tags,
      minPrice: filter?.minPrice,
      maxPrice: filter?.maxPrice,
      limit: limit,
    );
  }

  @override
  Future<Result<Workshop>> getWorkshopById(String id) async {
    return await _firestoreService.getWorkshopById(id);
  }

  @override
  Future<Result<Workshop>> createWorkshop(Workshop workshop) async {
    return await _firestoreService.createWorkshop(workshop);
  }

  @override
  Future<Result<Workshop>> updateWorkshop(Workshop workshop) async {
    return await _firestoreService.updateWorkshop(workshop);
  }

  @override
  Future<Result<void>> deleteWorkshop(String id) async {
    return await _firestoreService.deleteWorkshop(id);
  }

  @override
  Future<Result<List<Workshop>>> getWorkshopsByInstructor(String instructorId) async {
    // For now, we'll use a simple approach. In a real implementation,
    // you might want to add an instructorId field to the Workshop entity
    // and filter by it in Firestore
    final result = await _firestoreService.getWorkshops();
    
    return result.when(
      success: (workshops) {
        // This is a placeholder implementation
        // In a real app, you'd filter by instructorId field
        final filteredWorkshops = workshops.where((workshop) {
          // Placeholder logic - in reality you'd have an instructorId field
          return true; // Return all workshops for now
        }).toList();
        
        return Success(filteredWorkshops);
      },
      failure: (exception) => Failure(exception),
    );
  }

  @override
  Future<Result<List<Workshop>>> searchWorkshops(String query) async {
    return await _firestoreService.getWorkshops(searchQuery: query);
  }
}