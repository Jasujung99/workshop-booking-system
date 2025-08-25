import '../../entities/payment_info.dart';
import '../../repositories/payment_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class ProcessRefundUseCase {
  final PaymentRepository _paymentRepository;

  ProcessRefundUseCase(this._paymentRepository);

  Future<Result<RefundInfo>> execute({
    required String paymentId,
    required double refundAmount,
    required String reason,
  }) async {
    // Validate input
    if (paymentId.isEmpty) {
      return Failure(PaymentException(
        '결제 ID가 필요합니다',
        code: 'MISSING_PAYMENT_ID',
      ));
    }

    if (refundAmount <= 0) {
      return Failure(PaymentException(
        '환불 금액은 0원보다 커야 합니다',
        code: 'INVALID_REFUND_AMOUNT',
      ));
    }

    if (reason.trim().isEmpty) {
      return Failure(PaymentException(
        '환불 사유를 입력해주세요',
        code: 'MISSING_REFUND_REASON',
      ));
    }

    // Get payment info to validate refund eligibility
    final paymentResult = await _paymentRepository.getPaymentById(paymentId);
    if (paymentResult is Failure) {
      return Failure(PaymentException(
        '결제 정보를 찾을 수 없습니다',
        code: 'PAYMENT_NOT_FOUND',
      ));
    }

    final paymentInfo = (paymentResult as Success<PaymentInfo>).data;

    // Validate refund eligibility
    if (!paymentInfo.canRefund) {
      return Failure(PaymentException(
        '환불이 불가능한 결제입니다',
        code: 'REFUND_NOT_ALLOWED',
      ));
    }

    // Check refund amount doesn't exceed payment amount
    final currentRefundAmount = paymentInfo.refundInfo?.refundAmount ?? 0.0;
    final totalRefundAmount = currentRefundAmount + refundAmount;
    
    if (totalRefundAmount > paymentInfo.amount) {
      return Failure(PaymentException(
        '환불 금액이 결제 금액을 초과할 수 없습니다',
        code: 'REFUND_AMOUNT_EXCEEDED',
      ));
    }

    // Process refund
    return await _paymentRepository.processRefund(
      paymentId: paymentId,
      refundAmount: refundAmount,
      reason: reason,
    );
  }

  /// Calculate automatic refund amount based on cancellation policy
  Future<Result<double>> calculateRefundAmount({
    required String paymentId,
    required DateTime slotStartTime,
  }) async {
    // Get payment info
    final paymentResult = await _paymentRepository.getPaymentById(paymentId);
    if (paymentResult is Failure) {
      return Failure(PaymentException(
        '결제 정보를 찾을 수 없습니다',
        code: 'PAYMENT_NOT_FOUND',
      ));
    }

    final paymentInfo = (paymentResult as Success<PaymentInfo>).data;
    final now = DateTime.now();
    final hoursUntilStart = slotStartTime.difference(now).inHours;

    // Refund policy:
    // - More than 7 days: 100% refund
    // - 3-7 days: 80% refund
    // - 1-3 days: 50% refund
    // - Less than 24 hours: No refund
    
    double refundRate;
    if (hoursUntilStart >= 168) { // 7 days
      refundRate = 1.0;
    } else if (hoursUntilStart >= 72) { // 3 days
      refundRate = 0.8;
    } else if (hoursUntilStart >= 24) { // 1 day
      refundRate = 0.5;
    } else {
      refundRate = 0.0;
    }

    final refundAmount = paymentInfo.amount * refundRate;
    return Success(refundAmount);
  }

  /// Get refund policy text for display
  String getRefundPolicyText(DateTime slotStartTime) {
    final now = DateTime.now();
    final hoursUntilStart = slotStartTime.difference(now).inHours;

    if (hoursUntilStart >= 168) {
      return '7일 전 취소: 100% 환불 가능';
    } else if (hoursUntilStart >= 72) {
      return '3-7일 전 취소: 80% 환불 가능';
    } else if (hoursUntilStart >= 24) {
      return '1-3일 전 취소: 50% 환불 가능';
    } else {
      return '24시간 이내 취소: 환불 불가';
    }
  }
}