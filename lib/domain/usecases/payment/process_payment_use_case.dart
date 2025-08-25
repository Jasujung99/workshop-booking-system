import '../../entities/payment_info.dart';
import '../../repositories/payment_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class ProcessPaymentUseCase {
  final PaymentRepository _paymentRepository;

  ProcessPaymentUseCase(this._paymentRepository);

  Future<Result<PaymentInfo>> execute({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    String currency = 'KRW',
    Map<String, dynamic>? metadata,
  }) async {
    // Validate input
    final amountValidation = PaymentInfo.validateAmount(amount);
    if (amountValidation != null) {
      return Failure(PaymentException(amountValidation, code: 'INVALID_AMOUNT'));
    }

    if (bookingId.isEmpty) {
      return Failure(PaymentException(
        '예약 ID가 필요합니다',
        code: 'MISSING_BOOKING_ID',
      ));
    }

    // Process payment
    return await _paymentRepository.processPayment(
      bookingId: bookingId,
      amount: amount,
      method: method,
      currency: currency,
      metadata: metadata,
    );
  }
}