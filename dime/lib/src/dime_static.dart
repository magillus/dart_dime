import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:fimber/fimber.dart';

import 'common.dart';
import 'dime_base.dart';
import 'dime_module.dart';

final DimeScope _rootScope = DimeScope("root");

/// Returns Dime root scope - top level scope for the Isolate.
DimeScope get dimeRootScope => _rootScope;

/// Fetches a value and returns it base on [T] type
/// and instance identifier [tag].
T dimeGetWithTag<T>(String tag) {
  return dimeGet(tag: tag);
}

/// Fetches a value and returns based on [T] type
/// and optional instance identifier [tag].
T dimeGet<T>({String? tag}) {
  var instance = _rootScope.get<T>(tag: tag);
  if (instance == null) {
    throw DimeException.factoryNotFound(type: T);
  } else {
    return instance;
  }
}

/// Fetches a value and returns based on [T] type
/// and optional instance identifier [tag].
T? dimeGetOrNull<T>({String? tag}) {
  var instance = _rootScope.getOrNull<T>(tag: tag);
  if (instance == null) {
    Fimber.w("No instance for $T");
  }
  return instance;
}

/// Fetches a Future of the type [T]
/// with optional tag identifier [tag].
FutureOr<T> dimeGetAsync<T>({String? tag}) async {
  var instance = _rootScope.get<Future<T>>(tag: tag);
  if (instance == null) {
    throw DimeException.factoryNotFound(type: T);
  } else {
    return instance;
  }
}

/// Adds child scope to this scope.
void dimeAddScope(DimeScope scope) {
  _rootScope.addScope(scope);
}

/// Gets the scope from root Scope by name.
/// Will return null if no scope found.
DimeScope? dimeGetScope(String name) {
  return _rootScope.getScope(name);
}

/// Opens a scope by name,
/// will return scope if was already created under that name
/// will return the created scope
DimeScope dimeOpenScope(String name) {
  var currentScope = dimeGetScope(name);
  if (currentScope != null) {
    Fimber.w("Scope $name was already created.");
    return currentScope;
  }
  var scope = DimeScope(name);
  dimeAddScope(scope);
  return scope;
}

/// Closes scope by name or scope
void dimeCloseScope({String? name, DimeScope? scope}) {
  if (name != null) {
    _rootScope.closeScope(name: name);
  } else if (scope != null) {
    _rootScope.closeScope(scope: scope);
  }
}

/// Closes Dime global scope and its child scopes.
void dimeClose() {
  _rootScope.close();
}

/// Resets global scope, clears all child scopes and modules.
void dimeReset() {
  _rootScope.reset();
}

/// Installs [module] to the global scope of Dime.
void dimeInstall(BaseDimeModule module, {bool override = false}) {
  _rootScope.installModule(module, override: override);
}

/// Uninstalls [module] to global scope of Dime.
void dimeUninstall(BaseDimeModule module) {
  _rootScope.uninstallModule(module);
}
