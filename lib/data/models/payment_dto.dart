import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_info.dart';

class PaymentDto {
  final String paymentId;
  final String method;
  final String status;
  final double amount;
  final String currency;
  final Timestamp paidAt;
  final String? receiptUrl;
  final String? transactionId;
  final String? failureReason;
  final Map<String, dynamic>? refundInfo;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String? bookingId;

  const PaymentDto({
    required this.paymentId,
    required this.method,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paidAt,
    this.receiptUrl,
    this.transactionId,
    this.failureReason,
    this.refundInfo,
    required this.createdAt,
    this.updatedAt,
    this.bookingId,
  });

  /// Convert from domain entity
  factory PaymentDto.fromDomain(PaymentInfo paymentInfo) {
    return PaymentDto(
      paymentId: paymentInfo.paymentId,
      method: paymentInfo.method.name,
      status: paymentInfo.status.name,
      amount: paymentInfo.amount,
      currency: paymentInfo.currency,
      paidAt: Timestamp.fromDate(paymentInfo.paidAt),
      receiptUrl: paymentInfo.receiptUrl,
      transactionId: paymentInfo.transactionId,
      failureReason: paymentInfo.failureReason,
      refundInfo: paymentInfo.refundInfo != null ? {
        'refundId': paymentInfo.refundInfo!.refundId,
        'refundAmount': paymentInfo.refundInfo!.refundAmount,
        'reason': paymentInfo.refundInfo!.reason,
        'refundedAt': Timestamp.fromDate(paymentInfo.refundInfo!.refundedAt),
        'refundTransactionId': paymentInfo.refundInfo!.refundTransactionId,
      } : null,
      createdAt: Timestamp.fromDate(paymentInfo.createdAt),
      updatedAt: paymentInfo.updatedAt != null 
          ? Timestamp.fromDate(paymentInfo.updatedAt!) 
          : null,
    );
  }

  /// Convert from Firestore document
  factory PaymentDto.fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentDto(
      paymentId: id,
      method: data['method'] ?? 'creditCard',
      status: data['status'] ?? 'pending',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'KRW',
      paidAt: data['paidAt'] as Timestamp? ?? Timestamp.now(),
      receiptUrl: data['receiptUrl'],
      transactionId: data['transactionId'],
      failureReason: data['failureReason'],
      refundInfo: data['refundInfo'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp?,
      bookingId: data['bookingId'],
    );
  }

  /// Convert to domain entity
  PaymentInfo toDomain() {
    return PaymentInfo(
      paymentId: paymentId,
      method: _parsePaymentMethod(method),
      status: _parsePaymentStatus(status),
      amount: amount,
      currency: currency,
      paidAt: paidAt.toDate(),
      receiptUrl: receiptUrl,
      transactionId: transactionId,
      failureReason: failureReason,
      refundInfo: refundInfo != null ? RefundInfo(
        refundId: refundInfo!['refundId'],
        refundAmount: (refundInfo!['refundAmount'] as num).toDouble(),
        reason: refundInfo!['reason'],
        refundedAt: (refundInfo!['refundedAt'] as Timestamp).toDate(),
        refundTransactionId: refundInfo!['refundTransactionId'],
      ) : null,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'method': method,
      'status': status,
      'amount': amount,
      'currency': currency,
      'paidAt': paidAt,
      'receiptUrl': receiptUrl,
      'transactionId': transactionId,
      'failureReason': failureReason,
      'refundInfo': refundInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'bookingId': bookingId,
    };
  }

  /// Parse payment method from string
  PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'creditCard':
        return PaymentMethod.creditCard;
      case 'bankTransfer':
        return PaymentMethod.bankTransfer;
      case 'kakaoPayment':
        return PaymentMethod.kakaoPayment;
      case 'naverPayment':
        return PaymentMethod.naverPayment;
      case 'paypal':
        return PaymentMethod.paypal;
      default:
        return PaymentMethod.creditCard;
    }
  }

  /// Parse payment status from string
  PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partiallyRefunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }

  /// Create a copy with updated fields
  PaymentDto copyWith({
    String? paymentId,
    String? method,
    String? status,
    double? amount,
    String? currency,
    Timestamp? paidAt,
    String? receiptUrl,
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? refundInfo,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? bookingId,
  }) {
    return PaymentDto(
      paymentId: paymentId ?? this.paymentId,
      method: method ?? this.method,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paidAt: paidAt ?? this.paidAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      transactionId: transactionId ?? this.transactionId,
      failureReason: failureReason ?? this.failureReason,
      refundInfo: refundInfo ?? this.refundInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingId: bookingId ?? this.bookingId,
    );
  }
}