import '../../entities/payment_info.dart';
import '../../repositories/payment_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class RetryPaymentUseCase {
  final PaymentRepository _paymentRepository;

  RetryPaymentUseCase(this._paymentRepository);

  Future<Result<PaymentInfo>> execute(String paymentId) async {
    // Validate input
    if (paymentId.isEmpty) {
      return Failure(PaymentException(
        '결제 ID가 필요합니다',
        code: 'MISSING_PAYMENT_ID',
      ));
    }

    // Get current payment info to validate retry eligibility
    final currentPaymentResult = await _paymentRepository.getPaymentById(paymentId);
    if (currentPaymentResult is Failure) {
      return currentPaymentResult;
    }

    final currentPayment = (currentPaymentResult as Success<PaymentInfo>).data;

    // Check if payment can be retried
    if (currentPayment.status != PaymentStatus.failed) {
      return Failure(PaymentException(
        '실패한 결제만 재시도할 수 있습니다',
        code: 'RETRY_NOT_ALLOWED',
      ));
    }

    // Retry payment
    return await _paymentRepository.retryPayment(paymentId);
  }
}