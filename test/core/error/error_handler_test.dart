import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/core/error/error_handler.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

void main() {
  group('ErrorHandler', () {
    test('should handle AuthException correctly', () {
      const exception = AuthException('Test auth error', code: 'user-not-found');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });

    test('should handle NetworkException correctly', () {
      const exception = NetworkException('Network connection failed');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });

    test('should handle PaymentException correctly', () {
      const exception = PaymentException('Payment processing failed');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });

    test('should handle BookingException correctly', () {
      const exception = BookingException('Booking slot not available');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });

    test('should handle ValidationException correctly', () {
      const exception = ValidationException('Invalid input data');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });

    test('should handle StorageException correctly', () {
      const exception = StorageException('File upload failed');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });

    test('should handle UnknownException correctly', () {
      const exception = UnknownException('Unknown error occurred');
      
      // This should not throw an exception
      expect(() => ErrorHandler.handleError(exception), returnsNormally);
    });
  });
}