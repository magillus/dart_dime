import 'package:dime/src/common.dart';
import 'package:dime/src/dime_base.dart';
import 'package:dime/src/factories.dart';

// ignore: avoid_classes_with_only_static_members
/// Main Dime Dependency Injection Framework utility class
/// After installing a module we can access module's instances via [get].
///
class Dime {
  /// Global scope
  static final DimeScope _rootScope = DimeScope("root");

  /// Fetches a value and returns it base on [T] type
  /// and instance identifier [tag].
  static T getWithTag<T>(String tag) {
    return get(tag: tag);
  }

  /// Fetches a value and returns it base on [T] type
  /// and instance identifier [tag].
  /// [Deprecated] - use [getWithTag] method.
  @deprecated
  static T injectWithTag<T>(String tag) {
    return getWithTag(tag);
  }

  /// Fetches a value and returns based on [T] type
  /// and optional instance identifier [tag].
  static T get<T>({String tag}) {
    var instance = _rootScope.get<T>(tag: tag);
    if (instance == null) {
      throw DimeException.factoryNotFound(type: T);
    } else {
      return instance;
    }
  }

  /// Fetches a value and returns based on [T] type
  /// and optional instance identifier [tag].
  /// [Deprecated] - use [get] method.
  @deprecated
  static T inject<T>({String tag}) {
    return get(tag: tag);
  }

  /// Adds child scope to this scope.
  static void addScope(DimeScope scope) {
    _rootScope.addScope(scope);
  }

  /// Opens a scope by name,
  /// will return the created scope.
  static DimeScope openScope(String name) {
    var scope = DimeScope(name);
    addScope(scope);
    return scope;
  }

  /// Closes scope by name or scope
  static void closeScope({String name, DimeScope scope}) {
    if (name != null) {
      _rootScope.closeScope(name: name);
    } else if (scope != null) {
      _rootScope.closeScope(scope: scope);
    }
  }

  /// Clears all modules
  static void clearAll() {
    _rootScope.close();
  }

  /// Uninstalls module with closing any [Closable] instances in the module
  static void uninstallModule(BaseDimeModule module) {
    _rootScope.uninstallModule(module);
  }

  /// Installs [module] in the Dime root scope.
  /// [override] if set True it will override any currently inject
  /// factory for the type/tag
  static void installModule(BaseDimeModule module, {bool override = false}) {
    _rootScope.installModule(module, override: override);
  }
}

final DimeScope _rootScope = DimeScope("root");

/// Fetches a value and returns it base on [T] type
/// and instance identifier [tag].
T dimeGetWithTag<T>(String tag) {
  return dimeGet(tag: tag);
}

/// Fetches a value and returns based on [T] type
/// and optional instance identifier [tag].
T dimeGet<T>({String tag}) {
  var instance = _rootScope.get<T>(tag: tag);
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

/// Opens a scope by name,
/// will return the created scope.
DimeScope dimeOpenScope(String name) {
  var scope = DimeScope(name);
  dimeAddScope(scope);
  return scope;
}

/// Closes scope by name or scope
void dimeCloseScope({String name, DimeScope scope}) {
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
