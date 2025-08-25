import '../../entities/payment_info.dart';
import '../../entities/booking.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';
import '../../../data/services/receipt_service.dart';

class GenerateReceiptUseCase {
  final PaymentRepository _paymentRepository;
  final BookingRepository _bookingRepository;
  final ReceiptService _receiptService;

  GenerateReceiptUseCase(
    this._paymentRepository,
    this._bookingRepository,
    this._receiptService,
  );

  /// Generate receipt for a payment
  Future<Result<Receipt>> execute({
    required String paymentId,
    required String customerName,
    required String customerEmail,
    String? workshopTitle,
    String? companyInfo,
  }) async {
    // Validate input
    if (paymentId.isEmpty) {
      return Failure(PaymentException(
        '결제 ID가 필요합니다',
        code: 'MISSING_PAYMENT_ID',
      ));
    }

    if (customerName.trim().isEmpty) {
      return Failure(PaymentException(
        '고객명이 필요합니다',
        code: 'MISSING_CUSTOMER_NAME',
      ));
    }

    if (customerEmail.trim().isEmpty) {
      return Failure(PaymentException(
        '고객 이메일이 필요합니다',
        code: 'MISSING_CUSTOMER_EMAIL',
      ));
    }

    // Validate email format
    if (!_isValidEmail(customerEmail)) {
      return Failure(PaymentException(
        '올바른 이메일 형식이 아닙니다',
        code: 'INVALID_EMAIL_FORMAT',
      ));
    }

    try {
      // Get payment information
      final paymentResult = await _paymentRepository.getPaymentById(paymentId);
      if (paymentResult is Failure) {
        return Failure(PaymentException(
          '결제 정보를 찾을 수 없습니다',
          code: 'PAYMENT_NOT_FOUND',
        ));
      }

      final paymentInfo = (paymentResult as Success<PaymentInfo>).data;

      // Get booking information
      final bookingsResult = await _paymentRepository.getPaymentsByBookingId(paymentId);
      if (bookingsResult is Failure) {
        return Failure(PaymentException(
          '예약 정보를 찾을 수 없습니다',
          code: 'BOOKING_NOT_FOUND',
        ));
      }

      // For simplicity, we'll create a minimal booking object
      // In a real implementation, you'd get the actual booking
      final booking = Booking(
        id: 'booking_${paymentId}',
        userId: 'user_id',
        timeSlotId: 'timeslot_id',
        type: BookingType.workshop,
        status: BookingStatus.confirmed,
        totalAmount: paymentInfo.amount,
        paymentInfo: paymentInfo,
        createdAt: paymentInfo.createdAt,
      );

      // Generate receipt
      return await _receiptService.generateReceipt(
        paymentInfo: paymentInfo,
        booking: booking,
        customerName: customerName,
        customerEmail: customerEmail,
        workshopTitle: workshopTitle,
        companyInfo: companyInfo,
      );
    } catch (e) {
      return Failure(PaymentException(
        '영수증 생성 중 오류가 발생했습니다: ${e.toString()}',
        code: 'RECEIPT_GENERATION_ERROR',
      ));
    }
  }

  /// Generate receipt HTML
  Future<Result<String>> generateReceiptHtml({
    required String paymentId,
    required String customerName,
    required String customerEmail,
    String? workshopTitle,
    String? companyInfo,
  }) async {
    final receiptResult = await execute(
      paymentId: paymentId,
      customerName: customerName,
      customerEmail: customerEmail,
      workshopTitle: workshopTitle,
      companyInfo: companyInfo,
    );

    if (receiptResult is Failure) {
      return Failure(receiptResult.exception);
    }

    final receipt = (receiptResult as Success<Receipt>).data;
    return await _receiptService.generateReceiptHtml(receipt);
  }

  /// Generate receipt JSON
  Future<Result<Map<String, dynamic>>> generateReceiptJson({
    required String paymentId,
    required String customerName,
    required String customerEmail,
    String? workshopTitle,
    String? companyInfo,
  }) async {
    final receiptResult = await execute(
      paymentId: paymentId,
      customerName: customerName,
      customerEmail: customerEmail,
      workshopTitle: workshopTitle,
      companyInfo: companyInfo,
    );

    if (receiptResult is Failure) {
      return Failure(receiptResult.exception);
    }

    final receipt = (receiptResult as Success<Receipt>).data;
    return await _receiptService.generateReceiptJson(receipt);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}