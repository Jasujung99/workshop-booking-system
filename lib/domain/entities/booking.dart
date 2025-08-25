import 'package:equatable/equatable.dart';
import 'payment_info.dart';

enum BookingType {
  workshop,
  space,
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
  refunded,
}

class Booking extends Equatable {
  final String id;
  final String userId;
  final String timeSlotId;
  final BookingType type;
  final String? itemId; // workshop ID or space ID
  final BookingStatus status;
  final double totalAmount;
  final PaymentInfo? paymentInfo;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const Booking({
    required this.id,
    required this.userId,
    required this.timeSlotId,
    required this.type,
    this.itemId,
    required this.status,
    required this.totalAmount,
    this.paymentInfo,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  /// Creates a copy of this Booking with the given fields replaced with new values
  Booking copyWith({
    String? id,
    String? userId,
    String? timeSlotId,
    BookingType? type,
    String? itemId,
    BookingStatus? status,
    double? totalAmount,
    PaymentInfo? paymentInfo,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// Validates booking data
  static String? validateAmount(double? amount) {
    if (amount == null) {
      return '예약 금액을 입력해주세요';
    }
    
    if (amount < 0) {
      return '예약 금액은 0원 이상이어야 합니다';
    }
    
    if (amount > 10000000) { // 10 million KRW limit
      return '예약 금액은 10,000,000원 이하여야 합니다';
    }
    
    return null;
  }

  static String? validateNotes(String? notes) {
    if (notes != null && notes.length > 500) {
      return '메모는 500글자 이하여야 합니다';
    }
    
    return null;
  }

  /// Formats total amount as Korean Won
  String get formattedTotalAmount {
    return '${totalAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Gets booking type display name in Korean
  String get typeDisplayName {
    switch (type) {
      case BookingType.workshop:
        return '워크샵';
      case BookingType.space:
        return '공간 대관';
    }
  }

  /// Gets booking status display name in Korean
  String get statusDisplayName {
    switch (status) {
      case BookingStatus.pending:
        return '예약 대기';
      case BookingStatus.confirmed:
        return '예약 확정';
      case BookingStatus.cancelled:
        return '예약 취소';
      case BookingStatus.completed:
        return '이용 완료';
      case BookingStatus.noShow:
        return '노쇼';
      case BookingStatus.refunded:
        return '환불 완료';
    }
  }

  /// Checks if booking is active (not cancelled or completed)
  bool get isActive => 
      status == BookingStatus.pending || 
      status == BookingStatus.confirmed;

  /// Checks if booking is cancelled
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Checks if booking is completed
  bool get isCompleted => status == BookingStatus.completed;

  /// Checks if booking can be cancelled
  bool canBeCancelled(DateTime slotStartTime) {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final cancellationCutoff = slotStartTime.subtract(const Duration(hours: 24));
    
    return now.isBefore(cancellationCutoff);
  }

  /// Calculates refund amount based on cancellation policy
  double calculateRefundAmount(DateTime slotStartTime) {
    if (!canBeCancelled(slotStartTime)) return 0.0;
    
    final now = DateTime.now();
    final hoursUntilStart = slotStartTime.difference(now).inHours;
    
    // Refund policy:
    // - More than 7 days: 100% refund
    // - 3-7 days: 80% refund
    // - 1-3 days: 50% refund
    // - Less than 24 hours: No refund
    
    if (hoursUntilStart >= 168) { // 7 days
      return totalAmount;
    } else if (hoursUntilStart >= 72) { // 3 days
      return totalAmount * 0.8;
    } else if (hoursUntilStart >= 24) { // 1 day
      return totalAmount * 0.5;
    } else {
      return 0.0;
    }
  }

  /// Gets refund policy text
  String getRefundPolicyText(DateTime slotStartTime) {
    final now = DateTime.now();
    final hoursUntilStart = slotStartTime.difference(now).inHours;
    
    if (hoursUntilStart >= 168) {
      return '7일 전 취소: 100% 환불';
    } else if (hoursUntilStart >= 72) {
      return '3-7일 전 취소: 80% 환불';
    } else if (hoursUntilStart >= 24) {
      return '1-3일 전 취소: 50% 환불';
    } else {
      return '24시간 이내 취소: 환불 불가';
    }
  }

  /// Checks if payment is completed
  bool get isPaymentCompleted => 
      paymentInfo != null && paymentInfo!.isSuccessful;

  /// Checks if refund is possible
  bool get canRefund => 
      isPaymentCompleted && 
      paymentInfo!.canRefund && 
      isCancelled;

  @override
  List<Object?> get props => [
        id,
        userId,
        timeSlotId,
        type,
        itemId,
        status,
        totalAmount,
        paymentInfo,
        notes,
        createdAt,
        updatedAt,
        cancelledAt,
        cancellationReason,
      ];

  @override
  String toString() {
    return 'Booking(id: $id, userId: $userId, type: $type, status: $status, amount: $formattedTotalAmount)';
  }
}