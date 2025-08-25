import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:workshop_booking_system/domain/entities/booking.dart';
import 'package:workshop_booking_system/domain/entities/time_slot.dart';
import 'package:workshop_booking_system/domain/entities/payment_info.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';
import 'package:workshop_booking_system/domain/repositories/booking_repository.dart';
import 'package:workshop_booking_system/domain/repositories/auth_repository.dart';
import 'package:workshop_booking_system/domain/usecases/booking/create_booking_use_case.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

import 'create_booking_use_case_test.mocks.dart';

@GenerateMocks([BookingRepository, AuthRepository])
void main() {
  group('CreateBookingUseCase Tests', () {
    late CreateBookingUseCase useCase;
    late MockBookingRepository mockBookingRepository;
    late MockAuthRepository mockAuthRepository;
    late User testUser;
    late TimeSlot testTimeSlot;
    late PaymentInfo testPaymentInfo;
    late Booking testBooking;

    setUp(() {
      mockBookingRepository = MockBookingRepository();
      mockAuthRepository = MockAuthRepository();
      useCase = CreateBookingUseCase(mockBookingRepository, mockAuthRepository);

      testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: DateTime(2024, 1, 1),
      );

      testTimeSlot = TimeSlot(
        id: 'slot123',
        date: DateTime(2024, 2, 1),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        type: SlotType.workshop,
        itemId: 'workshop123',
        isAvailable: true,
        maxCapacity: 20,
        currentBookings: 5,
        createdAt: DateTime(2024, 1, 1),
      );

      testPaymentInfo = PaymentInfo(
        paymentId: 'payment123',
        method: PaymentMethod.creditCard,
        status: PaymentStatus.completed,
        amount: 50000.0,
        paidAt: DateTime(2024, 1, 1),
        receiptUrl: 'https://example.com/receipt.pdf',
        createdAt: DateTime(2024, 1, 1),
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
        createdAt: DateTime(2024, 1, 1),
      );
    });

    group('Successful Booking Creation', () {
      test('should create booking when all conditions are met', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([testTimeSlot]));
        
        when(mockBookingRepository.processPayment(any))
            .thenAnswer((_) async => Success(testPaymentInfo));
        
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => Success(testBooking));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          itemId: 'workshop123',
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
          notes: 'Test booking',
        );

        // Assert
        expect(result, isA<Success<Booking>>());
        expect((result as Success<Booking>).data, equals(testBooking));
        
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verify(mockBookingRepository.getAvailableTimeSlots(any, any, any)).called(1);
        verify(mockBookingRepository.processPayment(any)).called(1);
        verify(mockBookingRepository.createBooking(any)).called(1);
      });

      test('should create booking with pending status when payment is not successful', () async {
        // Arrange
        final pendingPayment = testPaymentInfo.copyWith(status: PaymentStatus.pending);
        
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([testTimeSlot]));
        
        when(mockBookingRepository.processPayment(any))
            .thenAnswer((_) async => Success(pendingPayment));
        
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => Success(testBooking.copyWith(
              status: BookingStatus.pending,
              paymentInfo: pendingPayment,
            )));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          itemId: 'workshop123',
          totalAmount: 50000.0,
          paymentInfo: pendingPayment,
        );

        // Assert
        expect(result, isA<Success<Booking>>());
        final booking = (result as Success<Booking>).data;
        expect(booking.status, BookingStatus.pending);
      });
    });

    group('Authentication Validation', () {
      test('should return Failure when user is not authenticated', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<AuthException>());
        expect(result.exception.message, '로그인이 필요합니다');
        
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verifyNever(mockBookingRepository.getAvailableTimeSlots(any, any, any));
      });
    });

    group('Input Validation', () {
      test('should return Failure when timeSlotId is empty', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await useCase.execute(
          timeSlotId: '',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<ValidationException>());
        expect(result.exception.message, '시간대를 선택해주세요');
      });

      test('should return Failure when totalAmount is negative', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: -1000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<ValidationException>());
        expect(result.exception.message, '예약 금액은 0원 이상이어야 합니다');
      });

      test('should return Failure when notes are too long', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
          notes: 'a' * 501, // Too long
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<ValidationException>());
        expect(result.exception.message, '메모는 500글자 이하여야 합니다');
      });
    });

    group('Time Slot Availability', () {
      test('should return Failure when time slot is not found', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([])); // Empty list

        // Act
        final result = await useCase.execute(
          timeSlotId: 'nonexistent',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<UnknownException>());
        expect(result.exception.message, contains('선택한 시간대를 찾을 수 없습니다'));
      });

      test('should return Failure when time slot is full', () async {
        // Arrange
        final fullTimeSlot = testTimeSlot.copyWith(
          currentBookings: 20, // Same as maxCapacity
        );
        
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([fullTimeSlot]));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<BusinessLogicException>());
        expect(result.exception.message, '선택한 시간대가 만석입니다');
      });

      test('should return Failure when booking is not allowed', () async {
        // Arrange
        // Create a time slot in the past to make booking not allowed
        final pastDate = DateTime.now().subtract(Duration(hours: 2));
        final closedTimeSlot = testTimeSlot.copyWith(
          date: pastDate,
        );
        
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([closedTimeSlot]));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<BusinessLogicException>());
        expect(result.exception.message, '예약 마감 시간이 지났습니다');
      });
    });

    group('Payment Processing', () {
      test('should return Failure when payment processing fails', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([testTimeSlot]));
        
        when(mockBookingRepository.processPayment(any))
            .thenAnswer((_) async => Failure(PaymentException('결제 처리 실패')));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<PaymentException>());
        expect(result.exception.message, '결제 처리 실패');
        
        verifyNever(mockBookingRepository.createBooking(any));
      });
    });

    group('Repository Error Handling', () {
      test('should return Failure when getAvailableTimeSlots fails', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Failure(NetworkException('네트워크 오류')));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<NetworkException>());
        expect(result.exception.message, '네트워크 오류');
      });

      test('should return Failure when createBooking fails', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([testTimeSlot]));
        
        when(mockBookingRepository.processPayment(any))
            .thenAnswer((_) async => Success(testPaymentInfo));
        
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => Failure(DataException('데이터베이스 오류')));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<DataException>());
        expect(result.exception.message, '데이터베이스 오류');
      });

      test('should handle unexpected exceptions', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Failure<Booking>>());
        expect((result as Failure<Booking>).exception, isA<UnknownException>());
        expect(result.exception.message, contains('예약 생성 중 오류가 발생했습니다'));
      });
    });

    group('Edge Cases', () {
      test('should handle space booking type', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([testTimeSlot]));
        
        when(mockBookingRepository.processPayment(any))
            .thenAnswer((_) async => Success(testPaymentInfo));
        
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => Success(testBooking.copyWith(type: BookingType.space)));

        // Act
        final result = await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.space,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
        );

        // Assert
        expect(result, isA<Success<Booking>>());
        final booking = (result as Success<Booking>).data;
        expect(booking.type, BookingType.space);
      });

      test('should trim notes before saving', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        
        when(mockBookingRepository.getAvailableTimeSlots(any, any, any))
            .thenAnswer((_) async => Success([testTimeSlot]));
        
        when(mockBookingRepository.processPayment(any))
            .thenAnswer((_) async => Success(testPaymentInfo));
        
        when(mockBookingRepository.createBooking(any))
            .thenAnswer((_) async => Success(testBooking));

        // Act
        await useCase.execute(
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          totalAmount: 50000.0,
          paymentInfo: testPaymentInfo,
          notes: '  Test notes with spaces  ',
        );

        // Assert
        final captured = verify(mockBookingRepository.createBooking(captureAny)).captured;
        final booking = captured.first as Booking;
        expect(booking.notes, 'Test notes with spaces');
      });
    });
  });
}