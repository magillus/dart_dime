import 'package:dime/src/dime_base.dart';

/// Dime Exception is special exception for Dime related errors.
/// Easier to find DI errors to fix with in logs.
class DimeException implements Exception {
  /// Message of the exception if porivded.
  String message;

  /// Creates instance of [DimeException] with optional [message]
  DimeException({this.message});

  /// Factory method to create message based [DimeException].
  factory DimeException.message(String message) =>
      DimeException(message: message);

  /// Factory method to create scope closed dime exception.
  /// Optionally uou can provide [name] or [scope] for name in message.
  factory DimeException.scopeClosed({String name, DimeScope scope}) =>
      DimeException(
          message: "Dime Scope (${name ?? scope?.name ?? ""}) already closed.");

  /// Factory method to create factory not found for [type] message exception.
  factory DimeException.factoryNotFound({type}) =>
      DimeException(message: "Dime factory not found for: ${type ?? "NA"}");

  /// Returns string representation of [DimeException]
  @override
  String toString() {
    return "DimeException: $message";
  }
}

/// Closable class that must implement [close] method.
abstract class Closable {
  /// Releasing resources that a class is using.
  void close();

  /// If provided [possibleClosable] instance is [Closable] it will close it.
  /// It is helper method pass any instance here and it will be closed if can.
  static void closeWith(dynamic possibleClosable) {
    if (possibleClosable != null && possibleClosable is Closable) {
      possibleClosable.close();
    }
    if (possibleClosable is Future<Closable>) {
      possibleClosable.then((value) => value.close());
    }
  }
}
