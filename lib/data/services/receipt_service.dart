import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/entities/booking.dart';

class ReceiptService {
  final Logger _logger;

  ReceiptService({
    Logger? logger,
  }) : _logger = logger ?? Logger();

  /// Generate receipt for a payment
  Future<Result<Receipt>> generateReceipt({
    required PaymentInfo paymentInfo,
    required Booking booking,
    required String customerName,
    required String customerEmail,
    String? workshopTitle,
    String? companyInfo,
  }) async {
    try {
      _logger.i('Generating receipt for payment: ${paymentInfo.paymentId}');

      final receipt = Receipt(
        receiptId: 'RCP_${paymentInfo.paymentId}',
        paymentId: paymentInfo.paymentId,
        bookingId: booking.id,
        customerName: customerName,
        customerEmail: customerEmail,
        workshopTitle: workshopTitle ?? 'Workshop Booking',
        amount: paymentInfo.amount,
        currency: paymentInfo.currency,
        paymentMethod: paymentInfo.method,
        paymentStatus: paymentInfo.status,
        paidAt: paymentInfo.paidAt,
        transactionId: paymentInfo.transactionId,
        companyInfo: companyInfo ?? _getDefaultCompanyInfo(),
        generatedAt: DateTime.now(),
        refundInfo: paymentInfo.refundInfo,
      );

      _logger.i('Receipt generated successfully: ${receipt.receiptId}');
      return Success(receipt);
    } catch (e) {
      _logger.e('Error generating receipt: $e');
      return Failure(PaymentException(
        '영수증 생성 중 오류가 발생했습니다: ${e.toString()}',
        code: 'RECEIPT_GENERATION_ERROR',
      ));
    }
  }

  /// Generate receipt HTML for display or printing
  Future<Result<String>> generateReceiptHtml(Receipt receipt) async {
    try {
      _logger.i('Generating receipt HTML: ${receipt.receiptId}');

      final html = '''
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>영수증 - ${receipt.receiptId}</title>
    <style>
        body {
            font-family: 'Malgun Gothic', sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .receipt {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #333;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .company-name {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        .receipt-title {
            font-size: 18px;
            color: #666;
        }
        .info-section {
            margin-bottom: 25px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .info-label {
            font-weight: bold;
            color: #333;
        }
        .info-value {
            color: #666;
        }
        .amount-section {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 6px;
            margin: 20px 0;
        }
        .total-amount {
            font-size: 24px;
            font-weight: bold;
            color: #2c5aa0;
            text-align: center;
        }
        .status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        .status-refunded {
            background-color: #f8d7da;
            color: #721c24;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #666;
            font-size: 12px;
        }
        .refund-info {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 6px;
            padding: 15px;
            margin-top: 20px;
        }
        .refund-title {
            font-weight: bold;
            color: #856404;
            margin-bottom: 10px;
        }
        @media print {
            body {
                background-color: white;
            }
            .receipt {
                box-shadow: none;
            }
        }
    </style>
</head>
<body>
    <div class="receipt">
        <div class="header">
            <div class="company-name">${receipt.companyInfo}</div>
            <div class="receipt-title">결제 영수증</div>
        </div>

        <div class="info-section">
            <div class="info-row">
                <span class="info-label">영수증 번호</span>
                <span class="info-value">${receipt.receiptId}</span>
            </div>
            <div class="info-row">
                <span class="info-label">결제 ID</span>
                <span class="info-value">${receipt.paymentId}</span>
            </div>
            <div class="info-row">
                <span class="info-label">예약 ID</span>
                <span class="info-value">${receipt.bookingId}</span>
            </div>
            <div class="info-row">
                <span class="info-label">고객명</span>
                <span class="info-value">${receipt.customerName}</span>
            </div>
            <div class="info-row">
                <span class="info-label">이메일</span>
                <span class="info-value">${receipt.customerEmail}</span>
            </div>
            <div class="info-row">
                <span class="info-label">상품명</span>
                <span class="info-value">${receipt.workshopTitle}</span>
            </div>
            <div class="info-row">
                <span class="info-label">결제 방법</span>
                <span class="info-value">${receipt.paymentMethodDisplayName}</span>
            </div>
            <div class="info-row">
                <span class="info-label">결제 상태</span>
                <span class="info-value">
                    <span class="status ${receipt.paymentStatus == PaymentStatus.completed ? 'status-completed' : (receipt.paymentStatus == PaymentStatus.refunded || receipt.paymentStatus == PaymentStatus.partiallyRefunded ? 'status-refunded' : '')}">
                        ${receipt.paymentStatusDisplayName}
                    </span>
                </span>
            </div>
            <div class="info-row">
                <span class="info-label">결제 일시</span>
                <span class="info-value">${_formatDateTime(receipt.paidAt)}</span>
            </div>
            ${receipt.transactionId != null ? '''
            <div class="info-row">
                <span class="info-label">거래 번호</span>
                <span class="info-value">${receipt.transactionId}</span>
            </div>
            ''' : ''}
        </div>

        <div class="amount-section">
            <div class="total-amount">${receipt.formattedAmount}</div>
        </div>

        ${receipt.refundInfo != null ? '''
        <div class="refund-info">
            <div class="refund-title">환불 정보</div>
            <div class="info-row">
                <span class="info-label">환불 ID</span>
                <span class="info-value">${receipt.refundInfo!.refundId}</span>
            </div>
            <div class="info-row">
                <span class="info-label">환불 금액</span>
                <span class="info-value">${receipt.refundInfo!.formattedRefundAmount}</span>
            </div>
            <div class="info-row">
                <span class="info-label">환불 사유</span>
                <span class="info-value">${receipt.refundInfo!.reason}</span>
            </div>
            <div class="info-row">
                <span class="info-label">환불 일시</span>
                <span class="info-value">${_formatDateTime(receipt.refundInfo!.refundedAt)}</span>
            </div>
        </div>
        ''' : ''}

        <div class="footer">
            <p>이 영수증은 ${_formatDateTime(receipt.generatedAt)}에 생성되었습니다.</p>
            <p>문의사항이 있으시면 고객센터로 연락해주세요.</p>
        </div>
    </div>
</body>
</html>
      ''';

      return Success(html);
    } catch (e) {
      _logger.e('Error generating receipt HTML: $e');
      return Failure(PaymentException(
        '영수증 HTML 생성 중 오류가 발생했습니다: ${e.toString()}',
        code: 'RECEIPT_HTML_ERROR',
      ));
    }
  }

  /// Generate receipt JSON for API responses
  Future<Result<Map<String, dynamic>>> generateReceiptJson(Receipt receipt) async {
    try {
      _logger.i('Generating receipt JSON: ${receipt.receiptId}');

      final json = {
        'receiptId': receipt.receiptId,
        'paymentId': receipt.paymentId,
        'bookingId': receipt.bookingId,
        'customerName': receipt.customerName,
        'customerEmail': receipt.customerEmail,
        'workshopTitle': receipt.workshopTitle,
        'amount': receipt.amount,
        'currency': receipt.currency,
        'formattedAmount': receipt.formattedAmount,
        'paymentMethod': receipt.paymentMethod.name,
        'paymentMethodDisplayName': receipt.paymentMethodDisplayName,
        'paymentStatus': receipt.paymentStatus.name,
        'paymentStatusDisplayName': receipt.paymentStatusDisplayName,
        'paidAt': receipt.paidAt.toIso8601String(),
        'transactionId': receipt.transactionId,
        'companyInfo': receipt.companyInfo,
        'generatedAt': receipt.generatedAt.toIso8601String(),
        'refundInfo': receipt.refundInfo != null ? {
          'refundId': receipt.refundInfo!.refundId,
          'refundAmount': receipt.refundInfo!.refundAmount,
          'formattedRefundAmount': receipt.refundInfo!.formattedRefundAmount,
          'reason': receipt.refundInfo!.reason,
          'refundedAt': receipt.refundInfo!.refundedAt.toIso8601String(),
          'refundTransactionId': receipt.refundInfo!.refundTransactionId,
        } : null,
      };

      return Success(json);
    } catch (e) {
      _logger.e('Error generating receipt JSON: $e');
      return Failure(PaymentException(
        '영수증 JSON 생성 중 오류가 발생했습니다: ${e.toString()}',
        code: 'RECEIPT_JSON_ERROR',
      ));
    }
  }

  /// Get default company information
  String _getDefaultCompanyInfo() {
    return 'Workshop Booking System';
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Receipt data model
class Receipt {
  final String receiptId;
  final String paymentId;
  final String bookingId;
  final String customerName;
  final String customerEmail;
  final String workshopTitle;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime paidAt;
  final String? transactionId;
  final String companyInfo;
  final DateTime generatedAt;
  final RefundInfo? refundInfo;

  const Receipt({
    required this.receiptId,
    required this.paymentId,
    required this.bookingId,
    required this.customerName,
    required this.customerEmail,
    required this.workshopTitle,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paidAt,
    this.transactionId,
    required this.companyInfo,
    required this.generatedAt,
    this.refundInfo,
  });

  /// Format amount as Korean Won
  String get formattedAmount {
    return '${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Get payment method display name in Korean
  String get paymentMethodDisplayName {
    switch (paymentMethod) {
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

  /// Get payment status display name in Korean
  String get paymentStatusDisplayName {
    switch (paymentStatus) {
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
}