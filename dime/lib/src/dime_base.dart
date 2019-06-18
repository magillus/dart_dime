import 'dart:core' as prefix0;
import 'dart:core';

import 'package:dime/src/common.dart';
import 'package:dime/src/factories.dart';
import 'package:fimber/fimber.dart';

/**
 * note to myself:
 *
 * Scope A  -> [default, module A, module B]
 *          -> Scope B  -> [default, module B, module C]
 *                      -> Scope C  -> [default, module A]
 *                      -> Scope D -> [default, module D]
 *
 *
 */

/// Dime Scope, will keep instances and modules for this scope
/// Provides methods to install or uninstall Modules [installModule]/[uninstallModule]
/// Provides methods to add/remove factories with Scope's default module.
class DimeScope extends Closable {
  final _scopeModule = _DimeScopeModule();

  final List<DimeScope> _scopes = [];
  DimeScope _parent;

  /// Name of the scope
  String name;
  bool _wasClosed = false;
  final List<BaseDimeModule> _modules = [];

  /// Creates instance of the scope with [name] and optional [parent] scope.
  DimeScope(this.name, {DimeScope parent}) {
    _parent = parent;
    installModule(_scopeModule);
  }

  /// Installs a [module] into this scope.
  /// Optinal [override] allows to update current's scope instances
  /// if same are defined in a [module]
  void installModule(BaseDimeModule module, {bool override = false}) {
    _modules.add(module);
    module.updateInjections();
    if (override) {
      // override this scope values
      module.injectMap.keys.forEach((newModuleType) {
        _modules.forEach((currentModule) {
          if (currentModule != module &&
              currentModule.injectMap.containsKey(newModuleType)) {
            Fimber.i(
                "Overriding $newModuleType in current module: $currentModule");
            // todo  Do we need to resolve duplicate per tag?
            // cleanup removed factory
            Closable.closeWith(currentModule.injectMap[newModuleType]);
            currentModule.injectMap.remove(newModuleType);
          }
        });
      });
    } else {
      // detect duplicate for the type
      module.injectMap.keys.forEach((newModuleType) {
        _modules.forEach((currentModule) {
          if (currentModule != module &&
              currentModule.injectMap.containsKey(newModuleType)) {
            // todo Do we need resolve duplicates per tag?
            // found duplicate
            throw DimeException.message("Found duplicate type: $newModuleType "
                "inside current scope modules.");
          }
        });
      });
    }
  }

  /// Uninstalls a [module] from this scope.
  /// Closes the [module].
  void uninstallModule(BaseDimeModule module) {
    _modules.remove(module);
    module.close();
  }

  /// Adds [childScope] to this scope.
  void addScope(DimeScope childScope) {
    _scopes.add(childScope);
    childScope._parent = this;
  }

  /// Removes a child ]scope] from this scope.
  /// Also closes [scope]
  void removeScope(DimeScope scope) {
    scope.close();
    _scopes.remove(scope);
  }

  /// Adds a singleton [instance] to the scope.
  void addSingle<T>(T instance) {
    _scopeModule.addSingle(instance);
  }

  /// Adds a [InjectFactory] for a [type] to the module.
  void add(Type type, InjectFactory factory) {
    _scopeModule.injectMap[type] = factory;
  }

  /// Removes [InjectFactory] for a [type]
  void remove(Type type) {
    _scopeModule.injectMap.remove(type);
  }

  /// Closes the module and all instances of [InjectFactory]
  /// and [BaseDimeModule] implementing [Closable].
  @override
  void close() {
    for (var module in _modules) {
      module.close();
    }
    _modules.clear();
    for (var scope in _scopes) {
      scope.close();
    }
    _scopes.clear();
    _wasClosed = true;
  }

  /// Resets scops.
  void reset() {
    close();
    _wasClosed = false;
  }

  T _get<T>({String tag}) {
    T value;
    // check modules
    for (var module in _modules) {
      value = module.get<T>(tag: tag);
      if (value != null) return value;
    }
    if (value == null) {
      // try parent scope if exists
      return _parent?.get<T>(tag: tag);
    }
    return null;
  }

  /// Fetches a value from a module or child scopes to satisfy [T]
  /// and optional [tag]

  T get<T>({String tag}) {
    if (_wasClosed) {
      throw DimeException.scopeClosed(scope: this);
    }
    var instance = _get<T>(tag: tag);
    if (instance == null) {
      throw DimeException.factoryNotFound(type: T);
    } else {
      return instance;
    }
  }

  /// Fetches a value from a module or child scopes to satisfy [T]
  /// and optional [tag]
  /// [Deprecated] use [get] method
  @deprecated
  T inject<T>({String tag}) {
    return get(tag: tag);
  }

  /// Opens new scope by [name] and adds as child to this scope
  DimeScope openScope(String name) {
    var scope = DimeScope(name);
    addScope(scope);
    return scope;
  }

  /// Closes a child scope by [name] or [scope] instance.
  void closeScope({String name, DimeScope scope}) {
    _scopes
        .where((ds) => ds.name == name || ds == scope)
        .toList()
        .forEach(removeScope);
  }
}

class _DimeScopeModule extends BaseDimeModule {
  @override
  void updateInjections() {
    // empty
  }
}
