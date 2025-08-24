import '../../entities/workshop.dart';
import '../../repositories/workshop_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetWorkshopByIdUseCase {
  final WorkshopRepository _workshopRepository;

  const GetWorkshopByIdUseCase(this._workshopRepository);

  /// Gets a workshop by its ID
  /// 
  /// Returns [Result<Workshop>] with workshop data on success or exception on failure
  Future<Result<Workshop>> execute(String workshopId) async {
    try {
      // Validate workshop ID
      if (workshopId.isEmpty) {
        return Failure(ValidationException('워크샵 ID가 필요합니다'));
      }

      // Get workshop from repository
      final result = await _workshopRepository.getWorkshopById(workshopId);
      
      return result.fold(
        onSuccess: (workshop) => Success(workshop),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('워크샵 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}