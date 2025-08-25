import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';
import 'package:workshop_booking_system/domain/entities/workshop.dart';
import 'package:workshop_booking_system/domain/entities/booking.dart';
import 'package:workshop_booking_system/domain/entities/time_slot.dart';
import 'package:workshop_booking_system/domain/entities/payment_info.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

void main() {
  group('Simple Integration Tests', () {
    group('Domain Entity Integration', () {
      test('should create and validate user entity correctly', () {
        // Arrange & Act
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: DateTime(2024, 1, 1),
        );

        // Assert
        expect(user.id, 'user123');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, UserRole.user);
        expect(user.isAdmin, isFalse);
        
        // Test validation
        expect(User.validateEmail('test@example.com'), isNull);
        expect(User.validateEmail('invalid-email'), isNotNull);
        expect(User.validateName('Test User'), isNull);
        expect(User.validateName(''), isNotNull);
      });

      test('should create and validate workshop entity correctly', () {
        // Arrange & Act
        final workshop = Workshop(
          id: 'workshop123',
          title: 'Flutter 개발 워크샵',
          description: '플러터를 이용한 모바일 앱 개발을 배우는 워크샵입니다.',
          price: 50000.0,
          capacity: 20,
          tags: ['Flutter', 'Mobile'],
          createdAt: DateTime(2024, 1, 1),
        );

        // Assert
        expect(workshop.id, 'workshop123');
        expect(workshop.title, 'Flutter 개발 워크샵');
        expect(workshop.price, 50000.0);
        expect(workshop.capacity, 20);
        expect(workshop.formattedPrice, '50,000원');
        expect(workshop.hasAvailableCapacity(10), isTrue);
        expect(workshop.hasAvailableCapacity(20), isFalse);
        
        // Test validation
        expect(Workshop.validateTitle('Valid Title'), isNull);
        expect(Workshop.validateTitle(''), isNotNull);
        expect(Workshop.validatePrice(50000.0), isNull);
        expect(Workshop.validatePrice(-1.0), isNotNull);
      });

      test('should create and manage booking entity correctly', () {
        // Arrange
        final paymentInfo = PaymentInfo(
          paymentId: 'payment123',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          amount: 50000.0,
          paidAt: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        );

        // Act
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          itemId: 'workshop123',
          status: BookingStatus.confirmed,
          totalAmount: 50000.0,
          paymentInfo: paymentInfo,
          createdAt: DateTime(2024, 1, 1),
        );

        // Assert
        expect(booking.id, 'booking123');
        expect(booking.userId, 'user123');
        expect(booking.type, BookingType.workshop);
        expect(booking.status, BookingStatus.confirmed);
        expect(booking.formattedTotalAmount, '50,000원');
        expect(booking.typeDisplayName, '워크샵');
        expect(booking.statusDisplayName, '예약 확정');
        expect(booking.isActive, isTrue);
        expect(booking.isCancelled, isFalse);
        expect(booking.isPaymentCompleted, isTrue);
        
        // Test validation
        expect(Booking.validateAmount(50000.0), isNull);
        expect(Booking.validateAmount(-1.0), isNotNull);
      });

      test('should handle time slot entity correctly', () {
        // Arrange & Act
        final timeSlot = TimeSlot(
          id: 'slot123',
          date: DateTime(2024, 2, 1),
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 12, minute: 0),
          type: SlotType.workshop,
          itemId: 'workshop123',
          isAvailable: true,
          maxCapacity: 20,
          currentBookings: 5,
          createdAt: DateTime(2024, 1, 1),
        );

        // Assert
        expect(timeSlot.id, 'slot123');
        expect(timeSlot.type, SlotType.workshop);
        expect(timeSlot.maxCapacity, 20);
        expect(timeSlot.currentBookings, 5);
        expect(timeSlot.hasAvailableCapacity, isTrue);
        expect(timeSlot.remainingCapacity, 15);
        expect(timeSlot.durationInMinutes, 120);
        expect(timeSlot.timeRangeString, '10:00 - 12:00');
        
        // Test validation
        expect(TimeSlot.validateCapacity(20), isNull);
        expect(TimeSlot.validateCapacity(0), isNotNull);
        expect(TimeSlot.validateDate(DateTime.now().add(Duration(days: 1))), isNull);
        expect(TimeSlot.validateDate(DateTime.now().subtract(Duration(days: 1))), isNotNull);
      });
    });

    group('Business Logic Integration', () {
      test('should handle complete booking workflow', () {
        // Step 1: Create user
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );
        expect(user.isAdmin, isFalse);

        // Step 2: Create workshop
        final workshop = Workshop(
          id: 'workshop123',
          title: 'Flutter Workshop',
          description: 'Learn Flutter development',
          price: 50000.0,
          capacity: 20,
          tags: ['Flutter'],
          createdAt: DateTime.now(),
        );
        expect(workshop.hasAvailableCapacity(0), isTrue);

        // Step 3: Create time slot
        final timeSlot = TimeSlot(
          id: 'slot123',
          date: DateTime.now().add(Duration(days: 7)),
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 12, minute: 0),
          type: SlotType.workshop,
          itemId: workshop.id,
          isAvailable: true,
          maxCapacity: workshop.capacity,
          currentBookings: 0,
          createdAt: DateTime.now(),
        );
        expect(timeSlot.hasAvailableCapacity, isTrue);
        expect(timeSlot.isBookingAllowed, isTrue);

        // Step 4: Process payment
        final paymentInfo = PaymentInfo(
          paymentId: 'payment123',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          amount: workshop.price,
          paidAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        expect(paymentInfo.isSuccessful, isTrue);

        // Step 5: Create booking
        final booking = Booking(
          id: 'booking123',
          userId: user.id,
          timeSlotId: timeSlot.id,
          type: BookingType.workshop,
          itemId: workshop.id,
          status: BookingStatus.confirmed,
          totalAmount: workshop.price,
          paymentInfo: paymentInfo,
          createdAt: DateTime.now(),
        );

        // Verify complete workflow
        expect(booking.userId, user.id);
        expect(booking.itemId, workshop.id);
        expect(booking.timeSlotId, timeSlot.id);
        expect(booking.totalAmount, workshop.price);
        expect(booking.isPaymentCompleted, isTrue);
        expect(booking.isActive, isTrue);
      });

      test('should handle booking cancellation workflow', () {
        // Arrange - Create a booking
        final futureDate = DateTime.now().add(Duration(days: 7));
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          status: BookingStatus.confirmed,
          totalAmount: 50000.0,
          paymentInfo: PaymentInfo(
            paymentId: 'payment123',
            method: PaymentMethod.creditCard,
            status: PaymentStatus.completed,
            amount: 50000.0,
            paidAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Test cancellation logic
        expect(booking.canBeCancelled(futureDate), isTrue);
        expect(booking.calculateRefundAmount(futureDate), 50000.0); // 100% refund for 7+ days

        // Test different refund scenarios
        final threeDaysLater = DateTime.now().add(Duration(days: 3));
        expect(booking.calculateRefundAmount(threeDaysLater), 40000.0); // 80% refund for 3-7 days

        final oneDayLater = DateTime.now().add(Duration(hours: 12));
        expect(booking.calculateRefundAmount(oneDayLater), 0.0); // No refund

        // Test cancellation
        final cancelledBooking = booking.copyWith(
          status: BookingStatus.cancelled,
          cancelledAt: DateTime.now(),
          cancellationReason: 'User requested',
        );
        expect(cancelledBooking.isCancelled, isTrue);
        expect(cancelledBooking.isActive, isFalse);
      });

      test('should handle admin vs user permissions', () {
        // Create regular user
        final regularUser = User(
          id: 'user123',
          email: 'user@example.com',
          name: 'Regular User',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        // Create admin user
        final adminUser = User(
          id: 'admin123',
          email: 'admin@example.com',
          name: 'Admin User',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        );

        // Assert permissions
        expect(regularUser.isAdmin, isFalse);
        expect(adminUser.isAdmin, isTrue);

        // Test role-based functionality
        expect(regularUser.role, UserRole.user);
        expect(adminUser.role, UserRole.admin);
      });
    });

    group('Error Handling Integration', () {
      test('should handle Result pattern correctly', () {
        // Test Success case
        final successResult = Success<String>('Operation completed');
        expect(successResult.isSuccess, isTrue);
        expect(successResult.isFailure, isFalse);
        expect(successResult.data, 'Operation completed');

        // Test Failure case
        final failureResult = Failure<String>(ValidationException('Invalid input'));
        expect(failureResult.isSuccess, isFalse);
        expect(failureResult.isFailure, isTrue);
        expect(failureResult.exception, isA<ValidationException>());
        expect(failureResult.exception.message, 'Invalid input');
      });

      test('should handle different exception types', () {
        // Test various exception types
        final authException = AuthException('Authentication failed');
        expect(authException.message, 'Authentication failed');

        final validationException = ValidationException('Validation failed');
        expect(validationException.message, 'Validation failed');

        final networkException = NetworkException('Network error');
        expect(networkException.message, 'Network error');

        final businessException = BusinessLogicException('Business rule violated');
        expect(businessException.message, 'Business rule violated');

        final unknownException = UnknownException('Unknown error occurred');
        expect(unknownException.message, 'Unknown error occurred');
      });

      test('should handle validation errors in entities', () {
        // Test user validation errors
        expect(User.validateEmail(''), isNotNull);
        expect(User.validateEmail('invalid'), isNotNull);
        expect(User.validateName(''), isNotNull);
        expect(User.validateName('a'), isNotNull);

        // Test workshop validation errors
        expect(Workshop.validateTitle(''), isNotNull);
        expect(Workshop.validateTitle('ab'), isNotNull);
        expect(Workshop.validateDescription(''), isNotNull);
        expect(Workshop.validatePrice(-1.0), isNotNull);
        expect(Workshop.validateCapacity(0), isNotNull);

        // Test booking validation errors
        expect(Booking.validateAmount(-1.0), isNotNull);
        expect(Booking.validateNotes('a' * 501), isNotNull);

        // Test time slot validation errors
        expect(TimeSlot.validateCapacity(0), isNotNull);
        expect(TimeSlot.validateDate(DateTime.now().subtract(Duration(days: 1))), isNotNull);
      });
    });

    group('Data Consistency Integration', () {
      test('should maintain data consistency across entities', () {
        // Create related entities
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        final workshop = Workshop(
          id: 'workshop123',
          title: 'Test Workshop',
          description: 'Test workshop description',
          price: 50000.0,
          capacity: 20,
          tags: ['Test'],
          createdAt: DateTime.now(),
        );

        final timeSlot = TimeSlot(
          id: 'slot123',
          date: DateTime.now().add(Duration(days: 1)),
          startTime: TimeOfDay(hour: 10, minute: 0),
          endTime: TimeOfDay(hour: 12, minute: 0),
          type: SlotType.workshop,
          itemId: workshop.id,
          isAvailable: true,
          maxCapacity: workshop.capacity,
          currentBookings: 0,
          createdAt: DateTime.now(),
        );

        final booking = Booking(
          id: 'booking123',
          userId: user.id,
          timeSlotId: timeSlot.id,
          type: BookingType.workshop,
          itemId: workshop.id,
          status: BookingStatus.confirmed,
          totalAmount: workshop.price,
          createdAt: DateTime.now(),
        );

        // Verify relationships
        expect(booking.userId, user.id);
        expect(booking.itemId, workshop.id);
        expect(booking.timeSlotId, timeSlot.id);
        expect(booking.totalAmount, workshop.price);
        expect(timeSlot.itemId, workshop.id);
        expect(timeSlot.maxCapacity, workshop.capacity);
      });

      test('should handle entity state transitions correctly', () {
        // Test booking state transitions
        var booking = Booking(
          id: 'booking123',
          userId: 'user123',
          timeSlotId: 'slot123',
          type: BookingType.workshop,
          status: BookingStatus.pending,
          totalAmount: 50000.0,
          createdAt: DateTime.now(),
        );

        expect(booking.status, BookingStatus.pending);
        expect(booking.isActive, isTrue);

        // Confirm booking
        booking = booking.copyWith(status: BookingStatus.confirmed);
        expect(booking.status, BookingStatus.confirmed);
        expect(booking.isActive, isTrue);

        // Complete booking
        booking = booking.copyWith(status: BookingStatus.completed);
        expect(booking.status, BookingStatus.completed);
        expect(booking.isCompleted, isTrue);
        expect(booking.isActive, isFalse);

        // Cancel booking
        booking = booking.copyWith(
          status: BookingStatus.cancelled,
          cancelledAt: DateTime.now(),
        );
        expect(booking.status, BookingStatus.cancelled);
        expect(booking.isCancelled, isTrue);
        expect(booking.isActive, isFalse);
      });
    });
  });
}