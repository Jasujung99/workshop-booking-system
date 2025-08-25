import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/result.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_dto.dart';
import '../services/payment_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;
  final PaymentService _paymentService;
  final Logger _logger;

  PaymentRepositoryImpl({
    FirebaseFirestore? firestore,
    required PaymentService paymentService,
    Logger? logger,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _paymentService = paymentService,
       _logger = logger ?? Logger();

  @override
  Future<Result<PaymentInfo>> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('Processing payment for booking: $bookingId');

      // Process payment through gateway
      final paymentResult = await _paymentService.processPayment(
        bookingId: bookingId,
        amount: amount,
        method: method,
        currency: currency,
        metadata: metadata,
      );

      if (paymentResult is Failure) {
        return paymentResult;
      }

      final paymentInfo = (paymentResult as Success<PaymentInfo>).data;

      // Save payment info to Firestore
      final paymentDto = PaymentDto.fromDomain(paymentInfo);
      await _firestore
          .collection('payments')
          .doc(paymentInfo.paymentId)
          .set(paymentDto.toFirestore());

      // Update booking with payment info
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({
        'paymentInfo': paymentDto.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Payment saved successfully: ${paymentInfo.paymentId}');
      return Success(paymentInfo);
    } catch (e) {
      _logger.e('Payment processing error: $e');
      return Failure(PaymentException(
        '결제 처리 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_PROCESSING_ERROR',
      ));
    }
  }

  @override
  Future<Result<PaymentInfo>> getPaymentById(String paymentId) async {
    try {
      _logger.i('Getting payment by ID: $paymentId');

      final doc = await _firestore
          .collection('payments')
          .doc(paymentId)
          .get();

      if (!doc.exists) {
        return Failure(PaymentException(
          '결제 정보를 찾을 수 없습니다',
          code: 'PAYMENT_NOT_FOUND',
        ));
      }

      final paymentDto = PaymentDto.fromFirestore(doc.data()!, doc.id);
      return Success(paymentDto.toDomain());
    } catch (e) {
      _logger.e('Get payment error: $e');
      return Failure(PaymentException(
        '결제 정보 조회 중 오류가 발생했습니다: ${e.toString()}',
        code: 'GET_PAYMENT_ERROR',
      ));
    }
  }

  @override
  Future<Result<List<PaymentInfo>>> getPaymentsByUserId(String userId) async {
    try {
      _logger.i('Getting payments for user: $userId');

      // Get bookings for the user first
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      final bookingIds = bookingsQuery.docs.map((doc) => doc.id).toList();

      if (bookingIds.isEmpty) {
        return const Success([]);
      }

      // Get payments for these bookings
      final paymentsQuery = await _firestore
          .collection('payments')
          .where('bookingId', whereIn: bookingIds)
          .orderBy('createdAt', descending: true)
          .get();

      final payments = paymentsQuery.docs
          .map((doc) => PaymentDto.fromFirestore(doc.data(), doc.id).toDomain())
          .toList();

      return Success(payments);
    } catch (e) {
      _logger.e('Get user payments error: $e');
      return Failure(PaymentException(
        '사용자 결제 내역 조회 중 오류가 발생했습니다: ${e.toString()}',
        code: 'GET_USER_PAYMENTS_ERROR',
      ));
    }
  }

  @override
  Future<Result<List<PaymentInfo>>> getPaymentsByBookingId(String bookingId) async {
    try {
      _logger.i('Getting payments for booking: $bookingId');

      final query = await _firestore
          .collection('payments')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('createdAt', descending: true)
          .get();

      final payments = query.docs
          .map((doc) => PaymentDto.fromFirestore(doc.data(), doc.id).toDomain())
          .toList();

      return Success(payments);
    } catch (e) {
      _logger.e('Get booking payments error: $e');
      return Failure(PaymentException(
        '예약 결제 내역 조회 중 오류가 발생했습니다: ${e.toString()}',
        code: 'GET_BOOKING_PAYMENTS_ERROR',
      ));
    }
  }

  @override
  Future<Result<RefundInfo>> processRefund({
    required String paymentId,
    required double refundAmount,
    required String reason,
  }) async {
    try {
      _logger.i('Processing refund for payment: $paymentId');

      // Get payment info first
      final paymentResult = await getPaymentById(paymentId);
      if (paymentResult is Failure) {
        return Failure(PaymentException(
          '결제 정보를 찾을 수 없습니다',
          code: 'PAYMENT_NOT_FOUND',
        ));
      }

      final paymentInfo = (paymentResult as Success<PaymentInfo>).data;

      // Check if refund is possible
      if (!paymentInfo.canRefund) {
        return Failure(PaymentException(
          '환불이 불가능한 결제입니다',
          code: 'REFUND_NOT_ALLOWED',
        ));
      }

      // Process refund through gateway
      final refundResult = await _paymentService.processRefund(
        paymentId: paymentId,
        refundAmount: refundAmount,
        reason: reason,
      );

      if (refundResult is Failure) {
        return refundResult;
      }

      final refundInfo = (refundResult as Success<RefundInfo>).data;

      // Update payment status in Firestore
      final newStatus = refundAmount >= paymentInfo.amount
          ? PaymentStatus.refunded
          : PaymentStatus.partiallyRefunded;

      await _firestore
          .collection('payments')
          .doc(paymentId)
          .update({
        'status': newStatus.name,
        'refundInfo': {
          'refundId': refundInfo.refundId,
          'refundAmount': refundInfo.refundAmount,
          'reason': refundInfo.reason,
          'refundedAt': Timestamp.fromDate(refundInfo.refundedAt),
          'refundTransactionId': refundInfo.refundTransactionId,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Refund processed successfully: ${refundInfo.refundId}');
      return Success(refundInfo);
    } catch (e) {
      _logger.e('Refund processing error: $e');
      return Failure(PaymentException(
        '환불 처리 중 오류가 발생했습니다: ${e.toString()}',
        code: 'REFUND_PROCESSING_ERROR',
      ));
    }
  }

  @override
  Future<Result<PaymentStatistics>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Getting payment statistics');

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      Query query = _firestore.collection('payments');
      
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));

      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        return const Success(PaymentStatistics(
          totalRevenue: 0,
          totalTransactions: 0,
          successfulTransactions: 0,
          failedTransactions: 0,
          refundedTransactions: 0,
          paymentMethodBreakdown: {},
          dailyRevenue: {},
          totalRefunds: 0,
        ));
      }

      final payments = snapshot.docs
          .map((doc) => PaymentDto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id).toDomain())
          .toList();

      // Calculate statistics
      double totalRevenue = 0;
      int successfulTransactions = 0;
      int failedTransactions = 0;
      int refundedTransactions = 0;
      double totalRefunds = 0;
      final Map<PaymentMethod, int> paymentMethodBreakdown = {};
      final Map<String, double> dailyRevenue = {};

      for (final payment in payments) {
        // Count by status
        switch (payment.status) {
          case PaymentStatus.completed:
            successfulTransactions++;
            totalRevenue += payment.amount;
            break;
          case PaymentStatus.failed:
            failedTransactions++;
            break;
          case PaymentStatus.refunded:
          case PaymentStatus.partiallyRefunded:
            refundedTransactions++;
            if (payment.refundInfo != null) {
              totalRefunds += payment.refundInfo!.refundAmount;
            }
            break;
          default:
            break;
        }

        // Count by payment method
        paymentMethodBreakdown[payment.method] = 
            (paymentMethodBreakdown[payment.method] ?? 0) + 1;

        // Daily revenue (only for successful payments)
        if (payment.status == PaymentStatus.completed) {
          final dateKey = payment.paidAt.toIso8601String().substring(0, 10);
          dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + payment.amount;
        }
      }

      final statistics = PaymentStatistics(
        totalRevenue: totalRevenue,
        totalTransactions: payments.length,
        successfulTransactions: successfulTransactions,
        failedTransactions: failedTransactions,
        refundedTransactions: refundedTransactions,
        paymentMethodBreakdown: paymentMethodBreakdown,
        dailyRevenue: dailyRevenue,
        totalRefunds: totalRefunds,
      );

      return Success(statistics);
    } catch (e) {
      _logger.e('Get payment statistics error: $e');
      return Failure(PaymentException(
        '결제 통계 조회 중 오류가 발생했습니다: ${e.toString()}',
        code: 'GET_PAYMENT_STATISTICS_ERROR',
      ));
    }
  }

  @override
  Future<Result<PaymentInfo>> retryPayment(String paymentId) async {
    try {
      _logger.i('Retrying payment: $paymentId');

      // Get current payment info
      final paymentResult = await getPaymentById(paymentId);
      if (paymentResult is Failure) {
        return paymentResult;
      }

      final currentPayment = (paymentResult as Success<PaymentInfo>).data;

      // Check if retry is allowed
      if (currentPayment.status != PaymentStatus.failed) {
        return Failure(PaymentException(
          '실패한 결제만 재시도할 수 있습니다',
          code: 'RETRY_NOT_ALLOWED',
        ));
      }

      // Retry payment through gateway
      final retryResult = await _paymentService.retryPayment(paymentId);
      if (retryResult is Failure) {
        return retryResult;
      }

      final updatedPayment = (retryResult as Success<PaymentInfo>).data;

      // Update payment in Firestore
      final paymentDto = PaymentDto.fromDomain(updatedPayment);
      await _firestore
          .collection('payments')
          .doc(paymentId)
          .update(paymentDto.toFirestore());

      return Success(updatedPayment);
    } catch (e) {
      _logger.e('Retry payment error: $e');
      return Failure(PaymentException(
        '결제 재시도 중 오류가 발생했습니다: ${e.toString()}',
        code: 'RETRY_PAYMENT_ERROR',
      ));
    }
  }

  @override
  Future<Result<void>> cancelPayment(String paymentId) async {
    try {
      _logger.i('Cancelling payment: $paymentId');

      // Get current payment info
      final paymentResult = await getPaymentById(paymentId);
      if (paymentResult is Failure) {
        return paymentResult;
      }

      final currentPayment = (paymentResult as Success<PaymentInfo>).data;

      // Check if cancellation is allowed
      if (currentPayment.status != PaymentStatus.pending) {
        return Failure(PaymentException(
          '대기 중인 결제만 취소할 수 있습니다',
          code: 'CANCEL_NOT_ALLOWED',
        ));
      }

      // Cancel payment through gateway
      final cancelResult = await _paymentService.cancelPayment(paymentId);
      if (cancelResult is Failure) {
        return cancelResult;
      }

      // Update payment status in Firestore
      await _firestore
          .collection('payments')
          .doc(paymentId)
          .update({
        'status': PaymentStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } catch (e) {
      _logger.e('Cancel payment error: $e');
      return Failure(PaymentException(
        '결제 취소 중 오류가 발생했습니다: ${e.toString()}',
        code: 'CANCEL_PAYMENT_ERROR',
      ));
    }
  }
}