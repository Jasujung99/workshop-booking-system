import '../../entities/booking.dart';
import '../../entities/user.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository _bookingRepository;
  final AuthRepository _authRepository;

  const UpdateBookingStatusUseCase(this._bookingRepository, this._authRepository);

  /// Updates the status of a booking (admin only)
  /// 
  /// Validates admin permissions and status transition rules
  /// Returns [Result<Booking>] with updated booking on success or exception on failure
  Future<Result<Booking>> execute({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    try {
      // Check user authentication and admin permissions
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인이 필요합니다'));
      }

      if (!currentUser.isAdmin) {
        return Failure(AuthException('관리자 권한이 필요합니다'));
      }

      // Validate booking ID
      if (bookingId.isEmpty) {
        return Failure(ValidationException('예약 ID가 필요합니다'));
      }

      // Get current booking
      final bookingResult = await _bookingRepository.getBookingById(bookingId);
      if (bookingResult.isFailure) {
        return Failure(NotFoundException('예약을 찾을 수 없습니다'));
      }

      final currentBooking = bookingResult.data!;

      // Validate status transition
      final transitionError = _validateStatusTransition(
        currentBooking.status,
        newStatus,
      );
      if (transitionError != null) {
        return Failure(BusinessLogicException(transitionError));
      }

      // Update booking status
      final result = await _bookingRepository.updateBookingStatus(bookingId, newStatus);
      
      return result.fold(
        onSuccess: (updatedBooking) => Success(updatedBooking),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('예약 상태 변경 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  String? _validateStatusTransition(BookingStatus currentStatus, BookingStatus newStatus) {
    // Define valid status transitions
    final validTransitions = <BookingStatus, List<BookingStatus>>{
      BookingStatus.pending: [
        BookingStatus.confirmed,
        BookingStatus.cancelled,
      ],
      BookingStatus.confirmed: [
        BookingStatus.completed,
        BookingStatus.cancelled,
        BookingStatus.noShow,
      ],
      BookingStatus.cancelled: [], // Cannot transition from cancelled
      BookingStatus.completed: [], // Cannot transition from completed
      BookingStatus.noShow: [
        BookingStatus.completed, // In case of mistake
      ],
    };

    if (currentStatus == newStatus) {
      return '이미 해당 상태입니다';
    }

    final allowedTransitions = validTransitions[currentStatus] ?? [];
    if (!allowedTransitions.contains(newStatus)) {
      return '${currentStatus.name}에서 ${newStatus.name}로 상태를 변경할 수 없습니다';
    }

    return null;
  }
}