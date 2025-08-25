import '../../entities/payment_info.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class ProcessRefundUseCase {
  final BookingRepository _bookingRepository;

  ProcessRefundUseCase(this._bookingRepository);

  Future<Result<PaymentInfo>> execute(String paymentId, double refundAmount) async {
    if (paymentId.isEmpty) {
      return const Failure(ValidationException('결제 ID가 필요합니다'));
    }

    if (refundAmount <= 0) {
      return const Failure(ValidationException('환불 금액은 0보다 커야 합니다'));
    }

    // Get payment info to validate refund amount
    final paymentResult = await _bookingRepository.getPaymentInfo(paymentId);
    if (paymentResult is Failure) {
      return paymentResult;
    }

    final paymentInfo = (paymentResult as Success<PaymentInfo>).data;
    
    // Check if refund amount is valid
    if (refundAmount > paymentInfo.amount) {
      return const Failure(BusinessLogicException('환불 금액이 결제 금액을 초과할 수 없습니다'));
    }

    // Check if payment is refundable
    if (paymentInfo.status != PaymentStatus.completed) {
      return const Failure(BusinessLogicException('완료된 결제만 환불 가능합니다'));
    }

    return await _bookingRepository.processRefund(paymentId, refundAmount);
  }
}