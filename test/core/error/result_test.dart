import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create success result with data', () {
        const data = 'test data';
        const result = Success(data);
        
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.data, equals(data));
        expect(result.exception, isNull);
      });

      test('should fold correctly for success', () {
        const data = 'test data';
        const result = Success(data);
        
        final folded = result.fold(
          onSuccess: (data) => 'Success: $data',
          onFailure: (exception) => 'Failure: ${exception.message}',
        );
        
        expect(folded, equals('Success: test data'));
      });
    });

    group('Failure', () {
      test('should create failure result with exception', () {
        const exception = NetworkException('Network error');
        const result = Failure<String>(exception);
        
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.data, isNull);
        expect(result.exception, equals(exception));
      });

      test('should fold correctly for failure', () {
        const exception = NetworkException('Network error');
        const result = Failure<String>(exception);
        
        final folded = result.fold(
          onSuccess: (data) => 'Success: $data',
          onFailure: (exception) => 'Failure: ${exception.message}',
        );
        
        expect(folded, equals('Failure: Network error'));
      });
    });

    group('ResultExtension', () {
      test('should provide correct properties for Success', () {
        const data = 42;
        const result = Success(data);
        
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.data, equals(42));
        expect(result.exception, isNull);
      });

      test('should provide correct properties for Failure', () {
        const exception = ValidationException('Invalid data');
        const result = Failure<int>(exception);
        
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.data, isNull);
        expect(result.exception, equals(exception));
      });
    });
  });
}