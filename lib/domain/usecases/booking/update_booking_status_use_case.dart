import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository _bookingRepository;

  UpdateBookingStatusUseCase(this._bookingRepository);

  Future<Result<Booking>> execute(String bookingId, BookingStatus newStatus) async {
    if (bookingId.isEmpty) {
      return const Failure(ValidationException('예약 ID가 필요합니다'));
    }

    // Validate status transition
    final bookingResult = await _bookingRepository.getBookingById(bookingId);
    if (bookingResult is Failure) {
      return bookingResult;
    }

    final booking = (bookingResult as Success<Booking>).data;
    
    // Check if status transition is valid
    if (!_isValidStatusTransition(booking.status, newStatus)) {
      return const Failure(BusinessLogicException('유효하지 않은 상태 변경입니다'));
    }

    return await _bookingRepository.updateBookingStatus(bookingId, newStatus);
  }

  bool _isValidStatusTransition(BookingStatus currentStatus, BookingStatus newStatus) {
    switch (currentStatus) {
      case BookingStatus.pending:
        return [BookingStatus.confirmed, BookingStatus.cancelled].contains(newStatus);
      case BookingStatus.confirmed:
        return [BookingStatus.completed, BookingStatus.cancelled, BookingStatus.noShow].contains(newStatus);
      case BookingStatus.completed:
        return false; // Completed bookings cannot be changed
      case BookingStatus.cancelled:
        return [BookingStatus.refunded].contains(newStatus); // Cancelled bookings can be refunded
      case BookingStatus.noShow:
        return false; // No-show bookings cannot be changed
      case BookingStatus.refunded:
        return false; // Refunded bookings cannot be changed
    }
  }
}