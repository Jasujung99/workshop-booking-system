import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/payment_info.dart';

class BookingDto {
  final String userId;
  final String timeSlotId;
  final String type;
  final String? itemId;
  final String status;
  final double totalAmount;
  final Map<String, dynamic>? paymentInfo;
  final String? notes;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final Timestamp? cancelledAt;
  final String? cancellationReason;

  const BookingDto({
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

  factory BookingDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingDto(
      userId: data['userId'] ?? '',
      timeSlotId: data['timeSlotId'] ?? '',
      type: data['type'] ?? 'workshop',
      itemId: data['itemId'],
      status: data['status'] ?? 'pending',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paymentInfo: data['paymentInfo'] as Map<String, dynamic>?,
      notes: data['notes'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      cancelledAt: data['cancelledAt'],
      cancellationReason: data['cancellationReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'timeSlotId': timeSlotId,
      'type': type,
      'itemId': itemId,
      'status': status,
      'totalAmount': totalAmount,
      'paymentInfo': paymentInfo,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
    };
  }

  Booking toDomain(String id) {
    PaymentInfo? domainPaymentInfo;
    if (paymentInfo != null) {
      domainPaymentInfo = PaymentInfo(
        paymentId: paymentInfo!['paymentId'] ?? '',
        method: PaymentMethod.values.byName(paymentInfo!['method'] ?? 'creditCard'),
        status: PaymentStatus.values.byName(paymentInfo!['status'] ?? 'pending'),
        amount: (paymentInfo!['amount'] ?? 0.0).toDouble(),
        paidAt: paymentInfo!['paidAt'] != null 
            ? (paymentInfo!['paidAt'] as Timestamp).toDate()
            : DateTime.now(),
        receiptUrl: paymentInfo!['receiptUrl'],
        transactionId: paymentInfo!['transactionId'],
        failureReason: paymentInfo!['failureReason'],
        createdAt: paymentInfo!['createdAt'] != null
            ? (paymentInfo!['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: paymentInfo!['updatedAt'] != null
            ? (paymentInfo!['updatedAt'] as Timestamp).toDate()
            : null,
      );
    }

    return Booking(
      id: id,
      userId: userId,
      timeSlotId: timeSlotId,
      type: BookingType.values.byName(type),
      itemId: itemId,
      status: BookingStatus.values.byName(status),
      totalAmount: totalAmount,
      paymentInfo: domainPaymentInfo,
      notes: notes,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
      cancelledAt: cancelledAt?.toDate(),
      cancellationReason: cancellationReason,
    );
  }

  static BookingDto fromDomain(Booking booking) {
    Map<String, dynamic>? paymentInfoMap;
    if (booking.paymentInfo != null) {
      final payment = booking.paymentInfo!;
      paymentInfoMap = {
        'paymentId': payment.paymentId,
        'method': payment.method.name,
        'status': payment.status.name,
        'amount': payment.amount,
        'paidAt': Timestamp.fromDate(payment.paidAt),
        'receiptUrl': payment.receiptUrl,
        'transactionId': payment.transactionId,
        'failureReason': payment.failureReason,
        'createdAt': Timestamp.fromDate(payment.createdAt),
        'updatedAt': payment.updatedAt != null ? Timestamp.fromDate(payment.updatedAt!) : null,
      };
    }

    return BookingDto(
      userId: booking.userId,
      timeSlotId: booking.timeSlotId,
      type: booking.type.name,
      itemId: booking.itemId,
      status: booking.status.name,
      totalAmount: booking.totalAmount,
      paymentInfo: paymentInfoMap,
      notes: booking.notes,
      createdAt: Timestamp.fromDate(booking.createdAt),
      updatedAt: booking.updatedAt != null ? Timestamp.fromDate(booking.updatedAt!) : null,
      cancelledAt: booking.cancelledAt != null ? Timestamp.fromDate(booking.cancelledAt!) : null,
      cancellationReason: booking.cancellationReason,
    );
  }
}