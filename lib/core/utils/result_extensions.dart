import '../error/result.dart';
import '../error/exceptions.dart';

/// Utility extensions for working with Result types
extension FutureResultExtension<T> on Future<T> {
  /// Wraps a Future in a Result, catching any exceptions and converting them to Failure
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Success(data);
    } catch (e) {
      final exception = e is AppException ? e : UnknownException(e.toString());
      return Failure(exception);
    }
  }
}

extension ResultChaining<T> on Result<T> {
  /// Chains another operation that returns a Result
  Result<U> chain<U>(Result<U> Function(T data) operation) {
    return switch (this) {
      Success<T> success => operation(success.data),
      Failure<T> failure => Failure(failure.exception),
    };
  }

  /// Maps the success value to another type
  Result<U> map<U>(U Function(T data) mapper) {
    return switch (this) {
      Success<T> success => Success(mapper(success.data)),
      Failure<T> failure => Failure(failure.exception),
    };
  }

  /// Maps the failure exception to another exception
  Result<T> mapError(AppException Function(AppException exception) mapper) {
    return switch (this) {
      Success<T> success => success,
      Failure<T> failure => Failure(mapper(failure.exception)),
    };
  }
}

/// Helper functions for creating Results
class ResultHelper {
  /// Creates a Success result
  static Result<T> success<T>(T data) => Success(data);

  /// Creates a Failure result
  static Result<T> failure<T>(AppException exception) => Failure(exception);

  /// Executes a function and wraps the result in a Result
  static Result<T> execute<T>(T Function() operation) {
    try {
      return Success(operation());
    } catch (e) {
      final exception = e is AppException ? e : UnknownException(e.toString());
      return Failure(exception);
    }
  }

  /// Executes an async function and wraps the result in a Result
  static Future<Result<T>> executeAsync<T>(Future<T> Function() operation) async {
    try {
      final data = await operation();
      return Success(data);
    } catch (e) {
      final exception = e is AppException ? e : UnknownException(e.toString());
      return Failure(exception);
    }
  }
}