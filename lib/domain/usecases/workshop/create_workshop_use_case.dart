import '../../entities/workshop.dart';
import '../../entities/user.dart';
import '../../repositories/workshop_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class CreateWorkshopUseCase {
  final WorkshopRepository _workshopRepository;
  final AuthRepository _authRepository;

  const CreateWorkshopUseCase(this._workshopRepository, this._authRepository);

  /// Creates a new workshop
  /// 
  /// Validates admin permissions and workshop data before creation
  /// Returns [Result<Workshop>] with created workshop on success or exception on failure
  Future<Result<Workshop>> execute(Workshop workshop) async {
    try {
      // Check admin permissions
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인이 필요합니다'));
      }

      if (!currentUser.isAdmin) {
        return Failure(AuthException('관리자 권한이 필요합니다'));
      }

      // Validate workshop data
      final validationError = _validateWorkshop(workshop);
      if (validationError != null) {
        return Failure(ValidationException(validationError));
      }

      // Create workshop with current timestamp
      final workshopToCreate = workshop.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create workshop in repository
      final result = await _workshopRepository.createWorkshop(workshopToCreate);
      
      return result.fold(
        onSuccess: (createdWorkshop) => Success(createdWorkshop),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('워크샵 생성 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  String? _validateWorkshop(Workshop workshop) {
    // Validate title
    final titleError = Workshop.validateTitle(workshop.title);
    if (titleError != null) return titleError;

    // Validate description
    final descriptionError = Workshop.validateDescription(workshop.description);
    if (descriptionError != null) return descriptionError;

    // Validate price
    final priceError = Workshop.validatePrice(workshop.price);
    if (priceError != null) return priceError;

    // Validate capacity
    final capacityError = Workshop.validateCapacity(workshop.capacity);
    if (capacityError != null) return capacityError;

    // Validate tags
    if (workshop.tags.isEmpty) {
      return '최소 1개의 태그를 입력해주세요';
    }

    if (workshop.tags.length > 10) {
      return '태그는 10개 이하여야 합니다';
    }

    for (final tag in workshop.tags) {
      if (tag.isEmpty || tag.length > 20) {
        return '태그는 1-20글자여야 합니다';
      }
    }

    return null;
  }
}