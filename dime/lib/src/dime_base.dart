import 'package:dime/src/common.dart';
import 'package:dime/src/factories.dart';
import 'package:fimber/fimber.dart';

/// Main Dime Dependency Injection Framework.
class Dime {
  /// Global scope
  static DimeScope _rootScope = DimeScope("root");

  /// Fetches a value and returns it base on [T] type and instance identifier [tag].
  static T injectWithTag<T>(String tag) {
    return inject(tag: tag);
  }

  /// Fetches a value and returns based on [T] type and optional instance identifier [tag].
  ///
  static T inject<T>({String tag}) {
    var instance = _rootScope._inject<T>(tag: tag);
    if (instance == null) {
      throw DimeException.factoryNotFound(type: T);
    } else
      return instance;
  }

  /// Adds child scope to this scope.
  static void addScope(DimeScope scope) {
    _rootScope.addScope(scope);
  }

  /// Opens a scope by name,
  /// will return the created scope.
  static DimeScope openScope(String name) {
    DimeScope scope = DimeScope(name);
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
    _rootScope._modules.forEach(Closable.closeWith);
    _rootScope._modules.clear();
  }

  /// Uninstalls module with closing any [Closeables] instances in the module
  static void uninstallModule(BaseDimeModule module) {
    _rootScope._modules.remove(module);
  }

  /// Installs module in the Dime root scope.
  /// [override] if set True it will override any currently inject factory for the type/tag // todo implement
  static void installModule(BaseDimeModule module,
      {bool override = false}) {
    _rootScope.installModule(module, override: override);
  }

}

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
  var _scopeModule = _DimeScopeModule();

  List<DimeScope> _scopes = [];
  DimeScope _parent;
  String name;
  bool _wasClosed = false;

  DimeScope(this.name, {DimeScope parent}) {
    this._parent = parent;
    installModule(_scopeModule);
  }

  List<BaseDimeModule> _modules = [];

  installModule(BaseDimeModule module, {bool override = false}) {
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
            throw DimeException.message(
                "Found duplicate type: $newModuleType inside current scope modules.");
          }
        });
      });
    }
  }

  uninstallModule(BaseDimeModule module) {
    _modules.remove(module);
    module.close();
  }

  void addScope(DimeScope childScope) {
    _scopes.add(childScope);
    childScope._parent = this;
  }

  void removeScope(DimeScope scope) {
    scope.close();
    _scopes.remove(scope);
  }

  void addSingle<T>(T instance) {
    _scopeModule.addSingle(instance);
  }

  void add(Type type, InjectFactory factory) {
    _scopeModule.injectMap[type] = factory;
  }

  void remove(Type type) {
    _scopeModule.injectMap.remove(type);
  }

  @override
  close() {
    _modules.forEach((module) => module.close());
    _scopes.forEach((scope) => scope.close());
    _wasClosed = true;
  }

  T _inject<T>({String tag}) {
    if (_wasClosed) {
      throw DimeException.scopeClosed(scope: this);
    }
    T value;
    // check modules
    for (BaseDimeModule module in _modules) {
      value = module.inject<T>(tag: tag);
      if (value != null) return value;
    }
    if (value == null) {
      return _parent?.inject<T>(tag: tag);
    }
    return null;
  }

  T inject<T>({String tag}) {
    if (_wasClosed) {
      throw DimeException.scopeClosed(scope: this);
    }
    var instance = _inject<T>(tag: tag);
    if (instance == null) {
      throw DimeException.factoryNotFound(type: T);
    } else
      return instance;
  }

  DimeScope openScope(String name) {
    var scope = DimeScope(name);
    addScope(scope);
    return scope;
  }

  void closeScope({String name, DimeScope scope}) {
    _scopes
        .where((ds) => ds.name == name || ds == scope)
        .toList()
        .forEach((ds) => removeScope(ds));
  }
}

class _DimeScopeModule extends BaseDimeModule {
  @override
  void updateInjections() {
    // empty
  }
}
