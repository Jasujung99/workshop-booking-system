import '../../entities/payment_info.dart';
import '../../repositories/payment_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetPaymentHistoryUseCase {
  final PaymentRepository _paymentRepository;

  GetPaymentHistoryUseCase(this._paymentRepository);

  /// Get payment history for a specific user
  Future<Result<List<PaymentInfo>>> executeForUser(String userId) async {
    if (userId.isEmpty) {
      return Failure(PaymentException(
        '사용자 ID가 필요합니다',
        code: 'MISSING_USER_ID',
      ));
    }

    return await _paymentRepository.getPaymentsByUserId(userId);
  }

  /// Get payment history for a specific booking
  Future<Result<List<PaymentInfo>>> executeForBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      return Failure(PaymentException(
        '예약 ID가 필요합니다',
        code: 'MISSING_BOOKING_ID',
      ));
    }

    return await _paymentRepository.getPaymentsByBookingId(bookingId);
  }

  /// Get specific payment by ID
  Future<Result<PaymentInfo>> executeById(String paymentId) async {
    if (paymentId.isEmpty) {
      return Failure(PaymentException(
        '결제 ID가 필요합니다',
        code: 'MISSING_PAYMENT_ID',
      ));
    }

    return await _paymentRepository.getPaymentById(paymentId);
  }
}