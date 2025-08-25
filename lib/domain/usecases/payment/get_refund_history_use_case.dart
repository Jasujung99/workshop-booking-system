import '../../entities/payment_info.dart';
import '../../repositories/payment_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetRefundHistoryUseCase {
  final PaymentRepository _paymentRepository;

  GetRefundHistoryUseCase(this._paymentRepository);

  /// Get all refunded payments for a user
  Future<Result<List<PaymentInfo>>> executeForUser(String userId) async {
    if (userId.isEmpty) {
      return Failure(PaymentException(
        '사용자 ID가 필요합니다',
        code: 'MISSING_USER_ID',
      ));
    }

    final paymentsResult = await _paymentRepository.getPaymentsByUserId(userId);
    if (paymentsResult is Failure) {
      return paymentsResult;
    }

    final payments = (paymentsResult as Success<List<PaymentInfo>>).data;
    
    // Filter only refunded payments
    final refundedPayments = payments
        .where((payment) => payment.isRefunded)
        .toList();

    return Success(refundedPayments);
  }

  /// Get refund information for a specific payment
  Future<Result<RefundInfo?>> executeForPayment(String paymentId) async {
    if (paymentId.isEmpty) {
      return Failure(PaymentException(
        '결제 ID가 필요합니다',
        code: 'MISSING_PAYMENT_ID',
      ));
    }

    final paymentResult = await _paymentRepository.getPaymentById(paymentId);
    if (paymentResult is Failure) {
      return Failure(PaymentException(
        '결제 정보를 찾을 수 없습니다',
        code: 'PAYMENT_NOT_FOUND',
      ));
    }

    final payment = (paymentResult as Success<PaymentInfo>).data;
    return Success(payment.refundInfo);
  }

  /// Get refund statistics for admin
  Future<Result<RefundStatistics>> getRefundStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final statisticsResult = await _paymentRepository.getPaymentStatistics(
      startDate: startDate,
      endDate: endDate,
    );

    if (statisticsResult is Failure) {
      return Failure(PaymentException(
        '환불 통계 조회 중 오류가 발생했습니다',
        code: 'REFUND_STATISTICS_ERROR',
      ));
    }

    final paymentStats = (statisticsResult as Success).data;
    
    final refundStats = RefundStatistics(
      totalRefunds: paymentStats.totalRefunds,
      refundedTransactions: paymentStats.refundedTransactions,
      refundRate: paymentStats.refundRate,
      averageRefundAmount: paymentStats.refundedTransactions > 0 
          ? paymentStats.totalRefunds / paymentStats.refundedTransactions 
          : 0.0,
    );

    return Success(refundStats);
  }
}

/// Statistics for refund operations
class RefundStatistics {
  final double totalRefunds;
  final int refundedTransactions;
  final double refundRate;
  final double averageRefundAmount;

  const RefundStatistics({
    required this.totalRefunds,
    required this.refundedTransactions,
    required this.refundRate,
    required this.averageRefundAmount,
  });

  /// Formats total refunds as Korean Won
  String get formattedTotalRefunds {
    return '${totalRefunds.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Formats average refund amount as Korean Won
  String get formattedAverageRefundAmount {
    return '${averageRefundAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Gets refund rate as percentage
  String get refundRatePercentage {
    return '${(refundRate * 100).toStringAsFixed(1)}%';
  }
}