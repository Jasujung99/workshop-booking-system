import '../../entities/workshop.dart';
import '../../repositories/workshop_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetWorkshopsUseCase {
  final WorkshopRepository _workshopRepository;

  const GetWorkshopsUseCase(this._workshopRepository);

  /// Gets workshops with optional filtering and pagination
  /// 
  /// Applies filters and returns paginated results
  /// Returns [Result<List<Workshop>>] with workshop list on success or exception on failure
  Future<Result<List<Workshop>>> execute({
    WorkshopFilter? filter,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      // Validate limit if provided
      if (limit != null && limit <= 0) {
        return Failure(ValidationException('페이지 크기는 1 이상이어야 합니다'));
      }

      if (limit != null && limit > 100) {
        return Failure(ValidationException('페이지 크기는 100 이하여야 합니다'));
      }

      // Validate filter if provided
      if (filter != null) {
        final filterError = _validateFilter(filter);
        if (filterError != null) {
          return Failure(ValidationException(filterError));
        }
      }

      // Get workshops from repository
      final result = await _workshopRepository.getWorkshops(
        filter: filter,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      
      return result.fold(
        onSuccess: (workshops) => Success(workshops),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('워크샵 목록 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  String? _validateFilter(WorkshopFilter filter) {
    // Validate price range
    if (filter.minPrice != null && filter.minPrice! < 0) {
      return '최소 가격은 0원 이상이어야 합니다';
    }

    if (filter.maxPrice != null && filter.maxPrice! < 0) {
      return '최대 가격은 0원 이상이어야 합니다';
    }

    if (filter.minPrice != null && 
        filter.maxPrice != null && 
        filter.minPrice! > filter.maxPrice!) {
      return '최소 가격은 최대 가격보다 작거나 같아야 합니다';
    }

    // Validate date range
    if (filter.startDate != null && 
        filter.endDate != null && 
        filter.startDate!.isAfter(filter.endDate!)) {
      return '시작 날짜는 종료 날짜보다 이전이어야 합니다';
    }

    // Validate search query
    if (filter.searchQuery != null && filter.searchQuery!.length > 100) {
      return '검색어는 100글자 이하여야 합니다';
    }

    return null;
  }
}