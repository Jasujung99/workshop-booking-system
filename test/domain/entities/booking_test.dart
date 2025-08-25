import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/domain/entities/booking.dart';
import 'package:workshop_booking_system/domain/entities/payment_info.dart';

void main() {
  group('Booking Entity Tests', () {
    late Booking testBooking;
    late DateTime testDate;
    late PaymentInfo testPaymentInfo;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testPaymentInfo = PaymentInfo(
        paymentId: 'payment123',
        method: PaymentMethod.creditCard,
        status: PaymentStatus.completed,
        amount: 50000.0,
        paidAt: testDate,
        receiptUrl: 'https://example.com/receipt.pdf',
        createdAt: testDate,
      );

      testBooking = Booking(
        id: 'booking123',
        userId: 'user123',
        timeSlotId: 'slot123',
        type: BookingType.workshop,
        itemId: 'workshop123',
        status: BookingStatus.confirmed,
        totalAmount: 50000.0,
        paymentInfo: testPaymentInfo,
        notes: 'Test booking notes',
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Constructor and Properties', () {
      test('should create booking with all properties', () {
        expect(testBooking.id, 'booking123');
        expect(testBooking.userId, 'user123');
        expect(testBooking.timeSlotId, 'slot123');
        expect(testBooking.type, BookingType.workshop);
        expect(testBooking.itemId, 'workshop123');
        expect(testBooking.status, BookingStatus.confirmed);
        expect(testBooking.totalAmount, 50000.0);
        expect(testBooking.paymentInfo, testPaymentInfo);
        expect(testBooking.notes, 'Test booking notes');
        expect(testBooking.createdAt, testDate);
        expect(testBooking.updatedAt, testDate);
      });

      test('should create booking with minimal required properties', () {
        final minimalBooking = Booking(
          id: 'booking456',
          userId: 'user456',
          timeSlotId: 'slot456',
          type: BookingType.space,
          status: BookingStatus.pending,
          totalAmount: 30000.0,
          createdAt: testDate,
        );

        expect(minimalBooking.itemId, isNull);
        expect(minimalBooking.paymentInfo, isNull);
        expect(minimalBooking.notes, isNull);
        expect(minimalBooking.updatedAt, isNull);
        expect(minimalBooking.cancelledAt, isNull);
        expect(minimalBooking.cancellationReason, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated properties', () {
        final updatedBooking = testBooking.copyWith(
          status: BookingStatus.cancelled,
          totalAmount: 60000.0,
          cancelledAt: testDate.add(Duration(days: 1)),
          cancellationReason: 'User requested cancellation',
        );

        expect(updatedBooking.id, testBooking.id);
        expect(updatedBooking.userId, testBooking.userId);
        expect(updatedBooking.status, BookingStatus.cancelled);
        expect(updatedBooking.totalAmount, 60000.0);
        expect(updatedBooking.cancelledAt, testDate.add(Duration(days: 1)));
        expect(updatedBooking.cancellationReason, 'User requested cancellation');
      });

      test('should create identical copy when no parameters provided', () {
        final copiedBooking = testBooking.copyWith();

        expect(copiedBooking, equals(testBooking));
        expect(copiedBooking.hashCode, equals(testBooking.hashCode));
      });
    });

    group('Amount Validation', () {
      test('should return null for valid amount', () {
        expect(Booking.validateAmount(0.0), isNull);
        expect(Booking.validateAmount(50000.0), isNull);
        expect(Booking.validateAmount(9999999.0), isNull);
      });

      test('should return error for null amount', () {
        expect(Booking.validateAmount(null), '예약 금액을 입력해주세요');
      });

      test('should return error for negative amount', () {
        expect(Booking.validateAmount(-1.0), '예약 금액은 0원 이상이어야 합니다');
        expect(Booking.validateAmount(-100.0), '예약 금액은 0원 이상이어야 합니다');
      });

      test('should return error for amount too high', () {
        expect(Booking.validateAmount(10000001.0), '예약 금액은 10,000,000원 이하여야 합니다');
      });

      test('should accept amount at boundary values', () {
        expect(Booking.validateAmount(0.0), isNull);
        expect(Booking.validateAmount(10000000.0), isNull);
      });
    });

    group('Notes Validation', () {
      test('should return null for valid notes', () {
        expect(Booking.validateNotes(null), isNull);
        expect(Booking.validateNotes(''), isNull);
        expect(Booking.validateNotes('Valid notes'), isNull);
        expect(Booking.validateNotes('a' * 500), isNull);
      });

      test('should return error for notes too long', () {
        final longNotes = 'a' * 501;
        expect(Booking.validateNotes(longNotes), '메모는 500글자 이하여야 합니다');
      });
    });

    group('formattedTotalAmount', () {
      test('should format amount with Korean Won and commas', () {
        final booking1 = testBooking.copyWith(totalAmount: 50000.0);
        expect(booking1.formattedTotalAmount, '50,000원');

        final booking2 = testBooking.copyWith(totalAmount: 1000000.0);
        expect(booking2.formattedTotalAmount, '1,000,000원');

        final booking3 = testBooking.copyWith(totalAmount: 0.0);
        expect(booking3.formattedTotalAmount, '0원');

        final booking4 = testBooking.copyWith(totalAmount: 123456.0);
        expect(booking4.formattedTotalAmount, '123,456원');
      });
    });

    group('Display Names', () {
      test('should return correct type display name', () {
        final workshopBooking = testBooking.copyWith(type: BookingType.workshop);
        expect(workshopBooking.typeDisplayName, '워크샵');

        final spaceBooking = testBooking.copyWith(type: BookingType.space);
        expect(spaceBooking.typeDisplayName, '공간 대관');
      });

      test('should return correct status display name', () {
        expect(testBooking.copyWith(status: BookingStatus.pending).statusDisplayName, '예약 대기');
        expect(testBooking.copyWith(status: BookingStatus.confirmed).statusDisplayName, '예약 확정');
        expect(testBooking.copyWith(status: BookingStatus.cancelled).statusDisplayName, '예약 취소');
        expect(testBooking.copyWith(status: BookingStatus.completed).statusDisplayName, '이용 완료');
        expect(testBooking.copyWith(status: BookingStatus.noShow).statusDisplayName, '노쇼');
      });
    });

    group('Status Checks', () {
      test('should correctly identify active bookings', () {
        expect(testBooking.copyWith(status: BookingStatus.pending).isActive, isTrue);
        expect(testBooking.copyWith(status: BookingStatus.confirmed).isActive, isTrue);
        expect(testBooking.copyWith(status: BookingStatus.cancelled).isActive, isFalse);
        expect(testBooking.copyWith(status: BookingStatus.completed).isActive, isFalse);
        expect(testBooking.copyWith(status: BookingStatus.noShow).isActive, isFalse);
      });

      test('should correctly identify cancelled bookings', () {
        expect(testBooking.copyWith(status: BookingStatus.cancelled).isCancelled, isTrue);
        expect(testBooking.copyWith(status: BookingStatus.confirmed).isCancelled, isFalse);
      });

      test('should correctly identify completed bookings', () {
        expect(testBooking.copyWith(status: BookingStatus.completed).isCompleted, isTrue);
        expect(testBooking.copyWith(status: BookingStatus.confirmed).isCompleted, isFalse);
      });
    });

    group('Cancellation Logic', () {
      test('should allow cancellation when booking is active and within time limit', () {
        final now = DateTime.now();
        final futureSlotTime = now.add(Duration(days: 2)); // 2 days from now
        final activeBooking = testBooking.copyWith(status: BookingStatus.confirmed);

        expect(activeBooking.canBeCancelled(futureSlotTime), isTrue);
      });

      test('should not allow cancellation when booking is not active', () {
        final now = DateTime.now();
        final futureSlotTime = now.add(Duration(days: 2));
        final cancelledBooking = testBooking.copyWith(status: BookingStatus.cancelled);

        expect(cancelledBooking.canBeCancelled(futureSlotTime), isFalse);
      });

      test('should not allow cancellation when within 24 hours', () {
        final now = DateTime.now();
        final nearSlotTime = now.add(Duration(hours: 12)); // 12 hours from now
        final activeBooking = testBooking.copyWith(status: BookingStatus.confirmed);

        expect(activeBooking.canBeCancelled(nearSlotTime), isFalse);
      });
    });

    group('Refund Calculation', () {
      test('should calculate 100% refund when more than 7 days', () {
        final now = DateTime.now();
        final futureSlotTime = now.add(Duration(days: 8));
        final booking = testBooking.copyWith(totalAmount: 50000.0);

        expect(booking.calculateRefundAmount(futureSlotTime), 50000.0);
      });

      test('should calculate 80% refund when 3-7 days', () {
        final now = DateTime.now();
        final futureSlotTime = now.add(Duration(days: 5));
        final booking = testBooking.copyWith(totalAmount: 50000.0);

        expect(booking.calculateRefundAmount(futureSlotTime), 40000.0);
      });

      test('should calculate 50% refund when 1-3 days', () {
        final now = DateTime.now();
        final futureSlotTime = now.add(Duration(days: 2));
        final booking = testBooking.copyWith(totalAmount: 50000.0);

        expect(booking.calculateRefundAmount(futureSlotTime), 25000.0);
      });

      test('should calculate 0% refund when less than 24 hours', () {
        final now = DateTime.now();
        final nearSlotTime = now.add(Duration(hours: 12));
        final booking = testBooking.copyWith(totalAmount: 50000.0);

        expect(booking.calculateRefundAmount(nearSlotTime), 0.0);
      });

      test('should return 0 refund when booking cannot be cancelled', () {
        final now = DateTime.now();
        final futureSlotTime = now.add(Duration(days: 8));
        final cancelledBooking = testBooking.copyWith(
          status: BookingStatus.cancelled,
          totalAmount: 50000.0,
        );

        expect(cancelledBooking.calculateRefundAmount(futureSlotTime), 0.0);
      });
    });

    group('Refund Policy Text', () {
      test('should return correct policy text based on time until start', () {
        final now = DateTime.now();

        final booking = testBooking.copyWith(totalAmount: 50000.0);

        // More than 7 days
        final slot8Days = now.add(Duration(days: 8));
        expect(booking.getRefundPolicyText(slot8Days), '7일 전 취소: 100% 환불');

        // 3-7 days
        final slot5Days = now.add(Duration(days: 5));
        expect(booking.getRefundPolicyText(slot5Days), '3-7일 전 취소: 80% 환불');

        // 1-3 days
        final slot2Days = now.add(Duration(days: 2));
        expect(booking.getRefundPolicyText(slot2Days), '1-3일 전 취소: 50% 환불');

        // Less than 24 hours
        final slot12Hours = now.add(Duration(hours: 12));
        expect(booking.getRefundPolicyText(slot12Hours), '24시간 이내 취소: 환불 불가');
      });
    });

    group('Payment Status Checks', () {
      test('should correctly identify completed payment', () {
        final completedPayment = testPaymentInfo.copyWith(status: PaymentStatus.completed);
        final booking = testBooking.copyWith(paymentInfo: completedPayment);

        expect(booking.isPaymentCompleted, isTrue);
      });

      test('should return false for incomplete payment', () {
        final pendingPayment = testPaymentInfo.copyWith(status: PaymentStatus.pending);
        final booking = testBooking.copyWith(paymentInfo: pendingPayment);

        expect(booking.isPaymentCompleted, isFalse);
      });

      test('should return false when no payment info', () {
        final booking = testBooking.copyWith();
        final bookingWithoutPayment = Booking(
          id: booking.id,
          userId: booking.userId,
          timeSlotId: booking.timeSlotId,
          type: booking.type,
          itemId: booking.itemId,
          status: booking.status,
          totalAmount: booking.totalAmount,
          paymentInfo: null, // Explicitly null
          notes: booking.notes,
          createdAt: booking.createdAt,
          updatedAt: booking.updatedAt,
        );

        expect(bookingWithoutPayment.isPaymentCompleted, isFalse);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all properties are same', () {
        final sameBooking = Booking(
          id: 'booking123',
          userId: 'user123',
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          itemId: 'workshop123',
          status: BookingStatus.confirmed,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
          notes: 'Test booking notes',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(testBooking, equals(sameBooking));
        expect(testBooking.hashCode, equals(sameBooking.hashCode));
      });

      test('should not be equal when properties differ', () {
        final differentBooking = testBooking.copyWith(status: BookingStatus.cancelled);

        expect(testBooking, isNot(equals(differentBooking)));
        expect(testBooking.hashCode, isNot(equals(differentBooking.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation with key properties', () {
        final bookingString = testBooking.toString();

        expect(bookingString, contains('Booking('));
        expect(bookingString, contains('id: booking123'));
        expect(bookingString, contains('userId: user123'));
        expect(bookingString, contains('type: BookingType.workshop'));
        expect(bookingString, contains('status: BookingStatus.confirmed'));
        expect(bookingString, contains('amount: 50,000원'));
      });
    });

    group('Enum Values', () {
      test('should have correct BookingType enum values', () {
        expect(BookingType.values, contains(BookingType.workshop));
        expect(BookingType.values, contains(BookingType.space));
        expect(BookingType.values.length, 2);
      });

      test('should have correct BookingStatus enum values', () {
        expect(BookingStatus.values, contains(BookingStatus.pending));
        expect(BookingStatus.values, contains(BookingStatus.confirmed));
        expect(BookingStatus.values, contains(BookingStatus.cancelled));
        expect(BookingStatus.values, contains(BookingStatus.completed));
        expect(BookingStatus.values, contains(BookingStatus.noShow));
        expect(BookingStatus.values.length, 5);
      });
    });
  });
}