import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class DeleteTimeSlotUseCase {
  final BookingRepository _bookingRepository;

  const DeleteTimeSlotUseCase(this._bookingRepository);

  /// Deletes a time slot
  /// 
  /// Validates that the time slot can be safely deleted (no active bookings)
  /// Returns [Result<void>] on success or exception on failure
  Future<Result<void>> execute(String timeSlotId) async {
    try {
      // Validate time slot ID
      if (timeSlotId.isEmpty) {
        return Failure(ValidationException('시간대 ID가 필요합니다'));
      }

      // Check if there are any bookings for this time slot
      final bookingsResult = await _bookingRepository.getBookingsByTimeSlot(timeSlotId);
      
      return bookingsResult.fold(
        onSuccess: (bookings) async {
          // Check if there are any active bookings
          final activeBookings = bookings.where((booking) => 
            booking.status != BookingStatus.cancelled &&
            booking.status != BookingStatus.completed
          ).toList();

          if (activeBookings.isNotEmpty) {
            return Failure(ValidationException(
              '활성 예약이 있는 시간대는 삭제할 수 없습니다 (${activeBookings.length}개 예약)'
            ));
          }

          // Delete time slot
          final deleteResult = await _bookingRepository.deleteTimeSlot(timeSlotId);
          
          return deleteResult.fold(
            onSuccess: (_) => const Success(null),
            onFailure: (exception) => Failure(exception),
          );
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('시간대 삭제 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}