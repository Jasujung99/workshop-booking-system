import '../../entities/time_slot.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class CreateTimeSlotUseCase {
  final BookingRepository _bookingRepository;

  const CreateTimeSlotUseCase(this._bookingRepository);

  /// Creates a new time slot
  /// 
  /// Validates time slot data and creates it in the repository
  /// Returns [Result<TimeSlot>] with created time slot on success or exception on failure
  Future<Result<TimeSlot>> execute(TimeSlot timeSlot) async {
    try {
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

      // Create time slot
      final result = await _bookingRepository.createTimeSlot(timeSlot);
      
      return result.fold(
        onSuccess: (createdTimeSlot) => Success(createdTimeSlot),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('시간대 생성 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}