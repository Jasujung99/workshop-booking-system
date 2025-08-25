import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/result.dart';
import '../../domain/entities/payment_info.dart';

/// Service for handling payment gateway integration
class PaymentService {
  final http.Client _httpClient;
  final Logger _logger;
  final String _baseUrl;
  final String _apiKey;
  final Uuid _uuid;

  PaymentService({
    http.Client? httpClient,
    Logger? logger,
    String? baseUrl,
    String? apiKey,
  }) : _httpClient = httpClient ?? http.Client(),
       _logger = logger ?? Logger(),
       _baseUrl = baseUrl ?? 'https://api.payment-gateway.com/v1',
       _apiKey = apiKey ?? 'test_api_key',
       _uuid = const Uuid();

  /// Process a payment through the payment gateway
  Future<Result<PaymentInfo>> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('Processing payment for booking: $bookingId, amount: $amount');

      final paymentId = _uuid.v4();
      final requestBody = {
        'payment_id': paymentId,
        'booking_id': bookingId,
        'amount': amount,
        'currency': currency,
        'payment_method': _getPaymentMethodString(method),
        'metadata': metadata ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final paymentInfo = _parsePaymentResponse(responseData);
        
        _logger.i('Payment processed successfully: ${paymentInfo.paymentId}');
        return Success(paymentInfo);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Payment processing failed';
        
        _logger.e('Payment failed: $errorMessage');
        return Failure(PaymentException(
          errorMessage,
          code: 'PAYMENT_FAILED',
        ));
      }
    } catch (e) {
      _logger.e('Payment processing error: $e');
      
      if (e.toString().contains('timeout')) {
        return Failure(PaymentException(
          '결제 처리 시간이 초과되었습니다. 다시 시도해주세요.',
          code: 'PAYMENT_TIMEOUT',
        ));
      }
      
      return Failure(PaymentException(
        '결제 처리 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_ERROR',
      ));
    }
  }

  /// Retry a failed payment
  Future<Result<PaymentInfo>> retryPayment(String paymentId) async {
    try {
      _logger.i('Retrying payment: $paymentId');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/payments/$paymentId/retry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final paymentInfo = _parsePaymentResponse(responseData);
        
        _logger.i('Payment retry successful: $paymentId');
        return Success(paymentInfo);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Payment retry failed';
        
        _logger.e('Payment retry failed: $errorMessage');
        return Failure(PaymentException(
          errorMessage,
          code: 'PAYMENT_RETRY_FAILED',
        ));
      }
    } catch (e) {
      _logger.e('Payment retry error: $e');
      return Failure(PaymentException(
        '결제 재시도 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_RETRY_ERROR',
      ));
    }
  }

  /// Cancel a pending payment
  Future<Result<void>> cancelPayment(String paymentId) async {
    try {
      _logger.i('Cancelling payment: $paymentId');

      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.i('Payment cancelled successfully: $paymentId');
        return const Success(null);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Payment cancellation failed';
        
        _logger.e('Payment cancellation failed: $errorMessage');
        return Failure(PaymentException(
          errorMessage,
          code: 'PAYMENT_CANCEL_FAILED',
        ));
      }
    } catch (e) {
      _logger.e('Payment cancellation error: $e');
      return Failure(PaymentException(
        '결제 취소 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_CANCEL_ERROR',
      ));
    }
  }

  /// Process a refund
  Future<Result<RefundInfo>> processRefund({
    required String paymentId,
    required double refundAmount,
    required String reason,
  }) async {
    try {
      _logger.i('Processing refund for payment: $paymentId, amount: $refundAmount');

      final refundId = _uuid.v4();
      final requestBody = {
        'refund_id': refundId,
        'payment_id': paymentId,
        'refund_amount': refundAmount,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/refunds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final refundInfo = _parseRefundResponse(responseData);
        
        _logger.i('Refund processed successfully: ${refundInfo.refundId}');
        return Success(refundInfo);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Refund processing failed';
        
        _logger.e('Refund failed: $errorMessage');
        return Failure(PaymentException(
          errorMessage,
          code: 'REFUND_FAILED',
        ));
      }
    } catch (e) {
      _logger.e('Refund processing error: $e');
      return Failure(PaymentException(
        '환불 처리 중 오류가 발생했습니다: ${e.toString()}',
        code: 'REFUND_ERROR',
      ));
    }
  }

  /// Get payment status from gateway
  Future<Result<PaymentInfo>> getPaymentStatus(String paymentId) async {
    try {
      _logger.i('Getting payment status: $paymentId');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final paymentInfo = _parsePaymentResponse(responseData);
        
        return Success(paymentInfo);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to get payment status';
        
        return Failure(PaymentException(
          errorMessage,
          code: 'PAYMENT_STATUS_ERROR',
        ));
      }
    } catch (e) {
      _logger.e('Payment status error: $e');
      return Failure(PaymentException(
        '결제 상태 조회 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_STATUS_ERROR',
      ));
    }
  }

  /// Simulate payment processing for testing
  Future<Result<PaymentInfo>> simulatePayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required String currency,
    bool shouldFail = false,
  }) async {
    try {
      _logger.i('Simulating payment for booking: $bookingId');

      // Simulate network delay
      await Future.delayed(Duration(milliseconds: Random().nextInt(2000) + 1000));

      final paymentId = _uuid.v4();
      final now = DateTime.now();

      if (shouldFail || Random().nextDouble() < 0.1) { // 10% failure rate
        final failureReasons = [
          '카드 한도 초과',
          '잘못된 카드 정보',
          '네트워크 오류',
          '은행 시스템 점검',
        ];
        
        final paymentInfo = PaymentInfo(
          paymentId: paymentId,
          method: method,
          status: PaymentStatus.failed,
          amount: amount,
          currency: currency,
          paidAt: now,
          failureReason: failureReasons[Random().nextInt(failureReasons.length)],
          createdAt: now,
        );

        return Success(paymentInfo);
      }

      final paymentInfo = PaymentInfo(
        paymentId: paymentId,
        method: method,
        status: PaymentStatus.completed,
        amount: amount,
        currency: currency,
        paidAt: now,
        transactionId: 'txn_${_uuid.v4().substring(0, 8)}',
        receiptUrl: 'https://receipts.example.com/$paymentId',
        createdAt: now,
      );

      _logger.i('Payment simulation completed: $paymentId');
      return Success(paymentInfo);
    } catch (e) {
      _logger.e('Payment simulation error: $e');
      return Failure(PaymentException(
        '결제 시뮬레이션 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_SIMULATION_ERROR',
      ));
    }
  }

  /// Parse payment response from gateway
  PaymentInfo _parsePaymentResponse(Map<String, dynamic> data) {
    return PaymentInfo(
      paymentId: data['payment_id'] ?? data['id'],
      method: _parsePaymentMethod(data['payment_method']),
      status: _parsePaymentStatus(data['status']),
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'KRW',
      paidAt: DateTime.parse(data['paid_at'] ?? data['created_at']),
      receiptUrl: data['receipt_url'],
      transactionId: data['transaction_id'],
      failureReason: data['failure_reason'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : null,
    );
  }

  /// Parse refund response from gateway
  RefundInfo _parseRefundResponse(Map<String, dynamic> data) {
    return RefundInfo(
      refundId: data['refund_id'] ?? data['id'],
      refundAmount: (data['refund_amount'] as num).toDouble(),
      reason: data['reason'],
      refundedAt: DateTime.parse(data['refunded_at'] ?? data['created_at']),
      refundTransactionId: data['refund_transaction_id'],
    );
  }

  /// Convert PaymentMethod enum to string
  String _getPaymentMethodString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.kakaoPayment:
        return 'kakao_pay';
      case PaymentMethod.naverPayment:
        return 'naver_pay';
      case PaymentMethod.paypal:
        return 'paypal';
    }
  }

  /// Parse payment method from string
  PaymentMethod _parsePaymentMethod(String? method) {
    switch (method) {
      case 'credit_card':
        return PaymentMethod.creditCard;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'kakao_pay':
        return PaymentMethod.kakaoPayment;
      case 'naver_pay':
        return PaymentMethod.naverPayment;
      case 'paypal':
        return PaymentMethod.paypal;
      default:
        return PaymentMethod.creditCard;
    }
  }

  /// Parse payment status from string
  PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
      case 'success':
        return PaymentStatus.completed;
      case 'failed':
      case 'error':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partially_refunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

