import '../entities/payment_info.dart';
import '../../core/error/result.dart';

/// Repository interface for payment operations
abstract class PaymentRepository {
  /// Process a payment
  Future<Result<PaymentInfo>> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required String currency,
    Map<String, dynamic>? metadata,
  });

  /// Get payment by ID
  Future<Result<PaymentInfo>> getPaymentById(String paymentId);

  /// Get payments for a user
  Future<Result<List<PaymentInfo>>> getPaymentsByUserId(String userId);

  /// Get payments for a booking
  Future<Result<List<PaymentInfo>>> getPaymentsByBookingId(String bookingId);

  /// Process refund
  Future<Result<RefundInfo>> processRefund({
    required String paymentId,
    required double refundAmount,
    required String reason,
  });

  /// Get payment statistics for admin
  Future<Result<PaymentStatistics>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Retry failed payment
  Future<Result<PaymentInfo>> retryPayment(String paymentId);

  /// Cancel pending payment
  Future<Result<void>> cancelPayment(String paymentId);
}

/// Payment statistics for admin dashboard
class PaymentStatistics {
  final double totalRevenue;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final int refundedTransactions;
  final Map<PaymentMethod, int> paymentMethodBreakdown;
  final Map<String, double> dailyRevenue; // date -> revenue
  final double totalRefunds;

  const PaymentStatistics({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.refundedTransactions,
    required this.paymentMethodBreakdown,
    required this.dailyRevenue,
    required this.totalRefunds,
  });

  double get successRate => 
      totalTransactions > 0 ? successfulTransactions / totalTransactions : 0.0;

  double get refundRate => 
      totalTransactions > 0 ? refundedTransactions / totalTransactions : 0.0;
}