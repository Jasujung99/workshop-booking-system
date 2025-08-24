import '../../entities/user.dart';
import '../../repositories/workshop_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class DeleteWorkshopUseCase {
  final WorkshopRepository _workshopRepository;
  final AuthRepository _authRepository;
  final BookingRepository _bookingRepository;

  const DeleteWorkshopUseCase(
    this._workshopRepository, 
    this._authRepository,
    this._bookingRepository,
  );

  /// Deletes a workshop
  /// 
  /// Validates admin permissions and checks for existing bookings before deletion
  /// Returns [Result<void>] indicating success or failure
  Future<Result<void>> execute(String workshopId) async {
    try {
      // Check admin permissions
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인이 필요합니다'));
      }

      if (!currentUser.isAdmin) {
        return Failure(AuthException('관리자 권한이 필요합니다'));
      }

      // Validate workshop ID
      if (workshopId.isEmpty) {
        return Failure(ValidationException('워크샵 ID가 필요합니다'));
      }

      // Check if workshop exists
      final existingWorkshopResult = await _workshopRepository.getWorkshopById(workshopId);
      if (existingWorkshopResult.isFailure) {
        return Failure(NotFoundException('워크샵을 찾을 수 없습니다'));
      }

      // Check for active bookings
      // Note: This is a simplified check. In a real implementation, you might want to
      // check for future bookings or handle cancellation of existing bookings
      final timeSlotsResult = await _bookingRepository.getAvailableTimeSlots(
        workshopId, 
        DateTime.now(), 
        DateTime.now().add(const Duration(days: 365))
      );

      if (timeSlotsResult.isSuccess) {
        final timeSlots = timeSlotsResult.data!;
        final hasActiveBookings = timeSlots.any((slot) => slot.currentBookings > 0);
        
        if (hasActiveBookings) {
          return Failure(BusinessLogicException(
            '예약이 있는 워크샵은 삭제할 수 없습니다. 먼저 모든 예약을 취소해주세요.'
          ));
        }
      }

      // Delete workshop
      final result = await _workshopRepository.deleteWorkshop(workshopId);
      
      return result.fold(
        onSuccess: (_) => const Success(null),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('워크샵 삭제 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}