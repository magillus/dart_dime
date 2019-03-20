import 'package:dime/src/dime_base.dart';

class DimeException implements Exception {
  String message;

  DimeException({this.message});

  factory DimeException.message(String message) =>
      DimeException(message: message);

  factory DimeException.scopeClosed({String name, DimeScope scope}) =>
      DimeException(
          message: "Dime Scope (${name ?? scope?.name ?? ""}) already closed.");

  factory DimeException.factoryNotFound({type}) =>
      DimeException(message: "Dime factory not found for: ${type ?? "NA"}");

  @override
  String toString() {
    return "DimeException: $message";
  }
}

abstract class Closable {
  void close();

  static closeWith(possibleClosable) {
    if (possibleClosable != null && possibleClosable is Closable) {
      possibleClosable.close();
    }
  }
}
