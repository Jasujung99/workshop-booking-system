import '../../entities/workshop.dart';
import '../../repositories/workshop_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class SearchWorkshopsUseCase {
  final WorkshopRepository _workshopRepository;

  const SearchWorkshopsUseCase(this._workshopRepository);

  /// Searches workshops by query string
  /// 
  /// Validates search query and returns matching workshops
  /// Returns [Result<List<Workshop>>] with workshop list on success or exception on failure
  Future<Result<List<Workshop>>> execute(String query) async {
    try {
      // Validate search query
      if (query.isEmpty) {
        return Failure(ValidationException('검색어를 입력해주세요'));
      }

      if (query.length < 2) {
        return Failure(ValidationException('검색어는 2글자 이상이어야 합니다'));
      }

      if (query.length > 100) {
        return Failure(ValidationException('검색어는 100글자 이하여야 합니다'));
      }

      // Trim and normalize query
      final normalizedQuery = query.trim();

      // Search workshops
      final result = await _workshopRepository.searchWorkshops(normalizedQuery);
      
      return result.fold(
        onSuccess: (workshops) => Success(workshops),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('워크샵 검색 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}