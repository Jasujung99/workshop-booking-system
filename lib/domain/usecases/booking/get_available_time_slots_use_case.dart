import '../../entities/time_slot.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetAvailableTimeSlotsUseCase {
  final BookingRepository _bookingRepository;

  const GetAvailableTimeSlotsUseCase(this._bookingRepository);

  /// Gets available time slots for a specific item (workshop or space)
  /// 
  /// Validates date range and returns available time slots
  /// Returns [Result<List<TimeSlot>>] with time slot list on success or exception on failure
  Future<Result<List<TimeSlot>>> execute({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validate input
      if (itemId.isEmpty) {
        return Failure(ValidationException('아이템 ID가 필요합니다'));
      }

      // Validate date range
      if (startDate.isAfter(endDate)) {
        return Failure(ValidationException('시작 날짜는 종료 날짜보다 이전이어야 합니다'));
      }

      // Check if date range is not too large (max 3 months)
      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 90) {
        return Failure(ValidationException('조회 기간은 최대 3개월까지 가능합니다'));
      }

      // Ensure start date is not in the past
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final queryStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      if (queryStartDate.isBefore(today)) {
        return Failure(ValidationException('과거 날짜는 조회할 수 없습니다'));
      }

      // Get available time slots from repository
      final result = await _bookingRepository.getAvailableTimeSlots(
        itemId,
        startDate,
        endDate,
      );
      
      return result.fold(
        onSuccess: (timeSlots) {
          // Filter out past time slots and unavailable slots
          final availableSlots = timeSlots.where((slot) {
            return slot.isAvailable && 
                   slot.hasAvailableCapacity && 
                   slot.isBookingAllowed;
          }).toList();

          // Sort by date and time
          availableSlots.sort((a, b) {
            final dateComparison = a.date.compareTo(b.date);
            if (dateComparison != 0) return dateComparison;
            
            final aStartMinutes = a.startTime.hour * 60 + a.startTime.minute;
            final bStartMinutes = b.startTime.hour * 60 + b.startTime.minute;
            return aStartMinutes.compareTo(bStartMinutes);
          });

          return Success(availableSlots);
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('예약 가능한 시간대 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}