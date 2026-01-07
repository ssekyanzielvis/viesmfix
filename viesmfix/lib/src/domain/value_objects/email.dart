import '../../core/errors/failures.dart';

class Email {
  final String value;

  const Email._(this.value);

  factory Email(String input) {
    if (input.isEmpty) {
      throw const ValidationFailure('Email cannot be empty');
    }

    // Basic email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(input)) {
      throw const ValidationFailure('Invalid email format');
    }

    return Email._(input.trim().toLowerCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Email &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
