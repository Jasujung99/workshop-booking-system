import '../../entities/time_slot.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetTimeSlotsUseCase {
  final BookingRepository _bookingRepository;

  const GetTimeSlotsUseCase(this._bookingRepository);

  /// Gets time slots for a specific item and date range
  /// 
  /// Returns all time slots (including unavailable ones) for admin management
  /// Returns [Result<List<TimeSlot>>] with time slot list on success or exception on failure
  Future<Result<List<TimeSlot>>> execute({
    String? itemId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validate date range
      if (startDate.isAfter(endDate)) {
        return Failure(ValidationException('시작 날짜는 종료 날짜보다 이전이어야 합니다'));
      }

      // Check if date range is not too large (max 6 months for admin)
      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 180) {
        return Failure(ValidationException('조회 기간은 최대 6개월까지 가능합니다'));
      }

      // Get time slots from repository
      // If itemId is null, get all time slots in the date range
      final result = itemId != null 
        ? await _bookingRepository.getAvailableTimeSlots(itemId, startDate, endDate)
        : await _getAllTimeSlots(startDate, endDate);
      
      return result.fold(
        onSuccess: (timeSlots) {
          // Sort by date and time
          timeSlots.sort((a, b) {
            final dateComparison = a.date.compareTo(b.date);
            if (dateComparison != 0) return dateComparison;
            
            final aStartMinutes = a.startTime.hour * 60 + a.startTime.minute;
            final bStartMinutes = b.startTime.hour * 60 + b.startTime.minute;
            return aStartMinutes.compareTo(bStartMinutes);
          });

          return Success(timeSlots);
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('시간대 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  /// Gets all time slots in date range (for admin)
  /// This is a placeholder - in real implementation, this would be a separate repository method
  Future<Result<List<TimeSlot>>> _getAllTimeSlots(DateTime startDate, DateTime endDate) async {
    // For now, we'll use the existing method with empty itemId
    // In a real implementation, this would be a separate repository method
    return await _bookingRepository.getAvailableTimeSlots('', startDate, endDate);
  }
}