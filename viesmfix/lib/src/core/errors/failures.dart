import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);

  factory NetworkFailure.noConnection() => const NetworkFailure(
    'No internet connection. Please check your network.',
  );
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);

  factory AuthenticationFailure.invalidCredentials() =>
      const AuthenticationFailure('Invalid email or password');
  factory AuthenticationFailure.sessionExpired() => const AuthenticationFailure(
    'Your session has expired. Please login again.',
  );
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
