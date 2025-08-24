import 'exceptions.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T? get data => switch (this) {
    Success<T> success => success.data,
    Failure<T> _ => null,
  };
  
  AppException? get exception => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.exception,
  };
  
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException exception) onFailure,
  }) {
    return switch (this) {
      Success<T> success => onSuccess(success.data),
      Failure<T> failure => onFailure(failure.exception),
    };
  }
}