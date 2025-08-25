import '../../entities/time_slot.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class UpdateTimeSlotUseCase {
  final BookingRepository _bookingRepository;

  const UpdateTimeSlotUseCase(this._bookingRepository);

  /// Updates an existing time slot
  /// 
  /// Validates time slot data and updates it in the repository
  /// Returns [Result<TimeSlot>] with updated time slot on success or exception on failure
  Future<Result<TimeSlot>> execute(TimeSlot timeSlot) async {
    try {
      // Validate time slot ID
      if (timeSlot.id.isEmpty) {
        return Failure(ValidationException('시간대 ID가 필요합니다'));
      }

      // Validate time slot data
      final dateError = TimeSlot.validateDate(timeSlot.date);
      if (dateError != null) {
        return Failure(ValidationException(dateError));
      }

      final timeError = TimeSlot.validateTimeRange(timeSlot.startTime, timeSlot.endTime);
      if (timeError != null) {
        return Failure(ValidationException(timeError));
      }

      final capacityError = TimeSlot.validateCapacity(timeSlot.maxCapacity);
      if (capacityError != null) {
        return Failure(ValidationException(capacityError));
      }

      // Validate item ID if provided
      if (timeSlot.itemId != null && timeSlot.itemId!.isEmpty) {
        return Failure(ValidationException('아이템 ID가 유효하지 않습니다'));
      }

      // Check if capacity reduction is valid (not below current bookings)
      if (timeSlot.currentBookings > timeSlot.maxCapacity) {
        return Failure(ValidationException(
          '최대 수용인원은 현재 예약 수(${timeSlot.currentBookings})보다 작을 수 없습니다'
        ));
      }

      // Update time slot
      final result = await _bookingRepository.updateTimeSlot(timeSlot);
      
      return result.fold(
        onSuccess: (updatedTimeSlot) => Success(updatedTimeSlot),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('시간대 수정 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}