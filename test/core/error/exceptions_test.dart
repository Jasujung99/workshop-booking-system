import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

void main() {
  group('AppException', () {
    test('AuthException should extend AppException', () {
      const exception = AuthException('Auth failed', code: 'invalid-credentials');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Auth failed'));
      expect(exception.code, equals('invalid-credentials'));
    });

    test('NetworkException should extend AppException', () {
      const exception = NetworkException('Network failed');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Network failed'));
      expect(exception.code, isNull);
    });

    test('ValidationException should extend AppException', () {
      const exception = ValidationException('Validation failed', code: 'invalid-email');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Validation failed'));
      expect(exception.code, equals('invalid-email'));
    });

    test('BookingException should extend AppException', () {
      const exception = BookingException('Booking failed');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Booking failed'));
    });

    test('PaymentException should extend AppException', () {
      const exception = PaymentException('Payment failed', code: 'card-declined');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Payment failed'));
      expect(exception.code, equals('card-declined'));
    });

    test('StorageException should extend AppException', () {
      const exception = StorageException('Storage failed');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Storage failed'));
    });

    test('UnknownException should extend AppException', () {
      const exception = UnknownException('Unknown error');
      
      expect(exception, isA<AppException>());
      expect(exception.message, equals('Unknown error'));
    });

    test('toString should format correctly with code', () {
      const exception = AuthException('Auth failed', code: 'invalid-credentials');
      
      expect(exception.toString(), equals('AppException: Auth failed (Code: invalid-credentials)'));
    });

    test('toString should format correctly without code', () {
      const exception = NetworkException('Network failed');
      
      expect(exception.toString(), equals('AppException: Network failed'));
    });
  });
}