import '../error/failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get getOrThrow {
    if (this is Success<T>) return (this as Success<T>).value;
    throw Exception('Called getOrThrow on Failure Result');
  }

  AppFailure get failureOrThrow {
    if (this is Failure<T>) return (this as Failure<T>).error;
    throw Exception('Called failureOrThrow on Success Result');
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppFailure error;
  const Failure(this.error);
}
