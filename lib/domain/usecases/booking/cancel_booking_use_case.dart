import '../../entities/booking.dart';
import '../../entities/time_slot.dart';
import '../../entities/payment_info.dart';
import '../../entities/user.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class CancelBookingUseCase {
  final BookingRepository _bookingRepository;
  final AuthRepository _authRepository;

  const CancelBookingUseCase(this._bookingRepository, this._authRepository);

  /// Cancels an existing booking and processes refund if applicable
  /// 
  /// Validates user permissions, cancellation policy, and processes refund
  /// Returns [Result<Booking>] with cancelled booking on success or exception on failure
  Future<Result<Booking>> execute({
    required String bookingId,
    required String reason,
  }) async {
    try {
      // Check user authentication
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인이 필요합니다'));
      }

      // Validate input
      if (bookingId.isEmpty) {
        return Failure(ValidationException('예약 ID가 필요합니다'));
      }

      if (reason.trim().isEmpty) {
        return Failure(ValidationException('취소 사유를 입력해주세요'));
      }

      if (reason.length > 500) {
        return Failure(ValidationException('취소 사유는 500글자 이하여야 합니다'));
      }

      // Get booking details
      final bookingResult = await _bookingRepository.getBookingById(bookingId);
      if (bookingResult.isFailure) {
        return Failure(NotFoundException('예약을 찾을 수 없습니다'));
      }

      final booking = bookingResult.data!;

      // Check user permissions (user can cancel their own booking, admin can cancel any)
      if (booking.userId != currentUser.id && !currentUser.isAdmin) {
        return Failure(AuthException('이 예약을 취소할 권한이 없습니다'));
      }

      // Check if booking can be cancelled
      if (!booking.isActive) {
        return Failure(BusinessLogicException('이미 취소되었거나 완료된 예약입니다'));
      }

      // Get time slot information to check cancellation policy
      final timeSlotsResult = await _bookingRepository.getAvailableTimeSlots(
        booking.itemId ?? '',
        DateTime.now(),
        DateTime.now().add(const Duration(days: 365)),
      );

      TimeSlot? timeSlot;
      if (timeSlotsResult.isSuccess) {
        final timeSlots = timeSlotsResult.data!;
        try {
          timeSlot = timeSlots.firstWhere((slot) => slot.id == booking.timeSlotId);
        } catch (e) {
          // Time slot might not be in available slots if it's in the past
          // We'll proceed with cancellation but no refund
        }
      }

      // Calculate refund amount
      double refundAmount = 0.0;
      if (timeSlot != null && booking.canBeCancelled(timeSlot.startDateTime)) {
        refundAmount = booking.calculateRefundAmount(timeSlot.startDateTime);
      }

      // Process refund if applicable
      PaymentInfo? updatedPaymentInfo = booking.paymentInfo;
      if (refundAmount > 0 && booking.paymentInfo != null && booking.paymentInfo!.canRefund) {
        final refundResult = await _bookingRepository.processRefund(
          booking.paymentInfo!.paymentId,
          refundAmount,
        );

        if (refundResult.isSuccess) {
          updatedPaymentInfo = refundResult.data!;
        }
        // Note: We don't fail the cancellation if refund fails, 
        // but we should log this for manual processing
      }

      // Cancel the booking
      final cancelledBooking = booking.copyWith(
        status: BookingStatus.cancelled,
        paymentInfo: updatedPaymentInfo,
        cancelledAt: DateTime.now(),
        cancellationReason: reason.trim(),
        updatedAt: DateTime.now(),
      );

      final result = await _bookingRepository.cancelBooking(bookingId, reason.trim());
      
      return result.fold(
        onSuccess: (booking) => Success(booking),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('예약 취소 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}