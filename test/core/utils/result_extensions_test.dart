import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/core/utils/result_extensions.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

void main() {
  group('FutureResultExtension', () {
    test('should convert successful Future to Success Result', () async {
      final future = Future.value('test data');
      final result = await future.toResult();
      
      expect(result, isA<Success<String>>());
      expect(result.data, equals('test data'));
    });

    test('should convert failed Future to Failure Result', () async {
      final future = Future<String>.error(Exception('Test error'));
      final result = await future.toResult();
      
      expect(result, isA<Failure<String>>());
      expect(result.exception, isA<UnknownException>());
    });

    test('should preserve AppException in failed Future', () async {
      const exception = NetworkException('Network error');
      final future = Future<String>.error(exception);
      final result = await future.toResult();
      
      expect(result, isA<Failure<String>>());
      expect(result.exception, equals(exception));
    });
  });

  group('ResultChaining', () {
    test('should chain successful operations', () {
      const result = Success(5);
      final chained = result.chain((data) => Success(data * 2));
      
      expect(chained, isA<Success<int>>());
      expect(chained.data, equals(10));
    });

    test('should not chain on failure', () {
      const exception = ValidationException('Invalid data');
      const result = Failure<int>(exception);
      final chained = result.chain((data) => Success(data * 2));
      
      expect(chained, isA<Failure<int>>());
      expect(chained.exception, equals(exception));
    });

    test('should map successful values', () {
      const result = Success(5);
      final mapped = result.map((data) => data.toString());
      
      expect(mapped, isA<Success<String>>());
      expect(mapped.data, equals('5'));
    });

    test('should not map on failure', () {
      const exception = ValidationException('Invalid data');
      const result = Failure<int>(exception);
      final mapped = result.map((data) => data.toString());
      
      expect(mapped, isA<Failure<String>>());
      expect(mapped.exception, equals(exception));
    });

    test('should map error exceptions', () {
      const originalException = ValidationException('Original error');
      const result = Failure<int>(originalException);
      final mappedException = NetworkException('Mapped error');
      final mapped = result.mapError((_) => mappedException);
      
      expect(mapped, isA<Failure<int>>());
      expect(mapped.exception, equals(mappedException));
    });

    test('should not map error on success', () {
      const result = Success(5);
      final mapped = result.mapError((_) => const NetworkException('Should not be called'));
      
      expect(mapped, isA<Success<int>>());
      expect(mapped.data, equals(5));
    });
  });

  group('ResultHelper', () {
    test('should create Success result', () {
      final result = ResultHelper.success('test');
      
      expect(result, isA<Success<String>>());
      expect(result.data, equals('test'));
    });

    test('should create Failure result', () {
      const exception = NetworkException('Network error');
      final result = ResultHelper.failure<String>(exception);
      
      expect(result, isA<Failure<String>>());
      expect(result.exception, equals(exception));
    });

    test('should execute successful operation', () {
      final result = ResultHelper.execute(() => 42);
      
      expect(result, isA<Success<int>>());
      expect(result.data, equals(42));
    });

    test('should execute failing operation', () {
      final result = ResultHelper.execute<int>(() => throw Exception('Test error'));
      
      expect(result, isA<Failure<int>>());
      expect(result.exception, isA<UnknownException>());
    });

    test('should execute successful async operation', () async {
      final result = await ResultHelper.executeAsync(() async => 42);
      
      expect(result, isA<Success<int>>());
      expect(result.data, equals(42));
    });

    test('should execute failing async operation', () async {
      final result = await ResultHelper.executeAsync<int>(() async => throw Exception('Test error'));
      
      expect(result, isA<Failure<int>>());
      expect(result.exception, isA<UnknownException>());
    });

    test('should preserve AppException in async operation', () async {
      const exception = AuthException('Auth failed');
      final result = await ResultHelper.executeAsync<int>(() async => throw exception);
      
      expect(result, isA<Failure<int>>());
      expect(result.exception, equals(exception));
    });
  });
}