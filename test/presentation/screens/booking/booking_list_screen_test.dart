import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:untitled/presentation/screens/booking/booking_list_screen.dart';
import 'package:untitled/presentation/providers/booking_provider.dart';
import 'package:untitled/presentation/providers/auth_provider.dart';
import 'package:untitled/domain/entities/booking.dart';
import 'package:untitled/domain/entities/user.dart';

import 'booking_list_screen_test.mocks.dart';

@GenerateMocks([BookingProvider, AuthProvider])
void main() {
  group('BookingListScreen', () {
    late MockBookingProvider mockBookingProvider;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockBookingProvider = MockBookingProvider();
      mockAuthProvider = MockAuthProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingProvider>.value(
              value: mockBookingProvider,
            ),
            ChangeNotifierProvider<AuthProvider>.value(
              value: mockAuthProvider,
            ),
          ],
          child: const BookingListScreen(),
        ),
      );
    }

    testWidgets('displays loading widget when loading', (WidgetTester tester) async {
      // Arrange
      when(mockBookingProvider.isLoading).thenReturn(true);
      when(mockBookingProvider.allBookings).thenReturn([]);
      when(mockBookingProvider.upcomingBookings).thenReturn([]);
      when(mockBookingProvider.completedBookings).thenReturn([]);
      when(mockBookingProvider.cancelledBookings).thenReturn([]);
      when(mockBookingProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.currentUser).thenReturn(
        const User(
          id: 'test-user-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: null,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('예약 내역을 불러오는 중...'), findsOneWidget);
    });

    testWidgets('displays empty state when no bookings', (WidgetTester tester) async {
      // Arrange
      when(mockBookingProvider.isLoading).thenReturn(false);
      when(mockBookingProvider.allBookings).thenReturn([]);
      when(mockBookingProvider.upcomingBookings).thenReturn([]);
      when(mockBookingProvider.completedBookings).thenReturn([]);
      when(mockBookingProvider.cancelledBookings).thenReturn([]);
      when(mockBookingProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.currentUser).thenReturn(
        const User(
          id: 'test-user-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: null,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('전체 예약이 없습니다'), findsOneWidget);
    });

    testWidgets('displays booking cards when bookings exist', (WidgetTester tester) async {
      // Arrange
      final testBooking = Booking(
        id: 'test-booking-id',
        userId: 'test-user-id',
        timeSlotId: 'test-slot-id',
        type: BookingType.workshop,
        status: BookingStatus.confirmed,
        totalAmount: 50000.0,
        createdAt: DateTime.now(),
      );

      when(mockBookingProvider.isLoading).thenReturn(false);
      when(mockBookingProvider.allBookings).thenReturn([testBooking]);
      when(mockBookingProvider.upcomingBookings).thenReturn([testBooking]);
      when(mockBookingProvider.completedBookings).thenReturn([]);
      when(mockBookingProvider.cancelledBookings).thenReturn([]);
      when(mockBookingProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.currentUser).thenReturn(
        const User(
          id: 'test-user-id',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: null,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('워크샵'), findsOneWidget);
      expect(find.text('50,000원'), findsOneWidget);
    });
  });
}