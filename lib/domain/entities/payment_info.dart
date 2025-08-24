import 'package:equatable/equatable.dart';

enum PaymentMethod {
  creditCard,
  bankTransfer,
  kakaoPayment,
  naverPayment,
  paypal,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}

class PaymentInfo extends Equatable {
  final String paymentId;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final DateTime paidAt;
  final String? receiptUrl;
  final String? transactionId;
  final String? failureReason;
  final RefundInfo? refundInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentInfo({
    required this.paymentId,
    required this.method,
    required this.status,
    required this.amount,
    this.currency = 'KRW',
    required this.paidAt,
    this.receiptUrl,
    this.transactionId,
    this.failureReason,
    this.refundInfo,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this PaymentInfo with the given fields replaced with new values
  PaymentInfo copyWith({
    String? paymentId,
    PaymentMethod? method,
    PaymentStatus? status,
    double? amount,
    String? currency,
    DateTime? paidAt,
    String? receiptUrl,
    String? transactionId,
    String? failureReason,
    RefundInfo? refundInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentInfo(
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
    );
  }

  /// Validates payment amount
  static String? validateAmount(double? amount) {
    if (amount == null) {
      return '결제 금액을 입력해주세요';
    }
    
    if (amount <= 0) {
      return '결제 금액은 0원보다 커야 합니다';
    }
    
    if (amount > 10000000) { // 10 million KRW limit
      return '결제 금액은 10,000,000원 이하여야 합니다';
    }
    
    return null;
  }

  /// Formats amount as Korean Won
  String get formattedAmount {
    return '${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Gets payment method display name in Korean
  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return '신용카드';
      case PaymentMethod.bankTransfer:
        return '계좌이체';
      case PaymentMethod.kakaoPayment:
        return '카카오페이';
      case PaymentMethod.naverPayment:
        return '네이버페이';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }

  /// Gets payment status display name in Korean
  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return '결제 대기';
      case PaymentStatus.processing:
        return '결제 처리중';
      case PaymentStatus.completed:
        return '결제 완료';
      case PaymentStatus.failed:
        return '결제 실패';
      case PaymentStatus.cancelled:
        return '결제 취소';
      case PaymentStatus.refunded:
        return '환불 완료';
      case PaymentStatus.partiallyRefunded:
        return '부분 환불';
    }
  }

  /// Checks if payment is successful
  bool get isSuccessful => status == PaymentStatus.completed;

  /// Checks if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Checks if payment is refunded (fully or partially)
  bool get isRefunded => 
      status == PaymentStatus.refunded || 
      status == PaymentStatus.partiallyRefunded;

  /// Checks if refund is possible
  bool get canRefund => 
      status == PaymentStatus.completed && 
      refundInfo == null;

  @override
  List<Object?> get props => [
        paymentId,
        method,
        status,
        amount,
        currency,
        paidAt,
        receiptUrl,
        transactionId,
        failureReason,
        refundInfo,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'PaymentInfo(paymentId: $paymentId, method: $method, status: $status, amount: $formattedAmount)';
  }
}

class RefundInfo extends Equatable {
  final String refundId;
  final double refundAmount;
  final String reason;
  final DateTime refundedAt;
  final String? refundTransactionId;

  const RefundInfo({
    required this.refundId,
    required this.refundAmount,
    required this.reason,
    required this.refundedAt,
    this.refundTransactionId,
  });

  /// Creates a copy of this RefundInfo with the given fields replaced with new values
  RefundInfo copyWith({
    String? refundId,
    double? refundAmount,
    String? reason,
    DateTime? refundedAt,
    String? refundTransactionId,
  }) {
    return RefundInfo(
      refundId: refundId ?? this.refundId,
      refundAmount: refundAmount ?? this.refundAmount,
      reason: reason ?? this.reason,
      refundedAt: refundedAt ?? this.refundedAt,
      refundTransactionId: refundTransactionId ?? this.refundTransactionId,
    );
  }

  /// Formats refund amount as Korean Won
  String get formattedRefundAmount {
    return '${refundAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  @override
  List<Object?> get props => [
        refundId,
        refundAmount,
        reason,
        refundedAt,
        refundTransactionId,
      ];

  @override
  String toString() {
    return 'RefundInfo(refundId: $refundId, refundAmount: $formattedRefundAmount, reason: $reason)';
  }
}