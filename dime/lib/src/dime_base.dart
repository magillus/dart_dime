import 'package:dime/src/common.dart';
import 'package:dime/src/factories.dart';

/// Main Dime entry call out
class Dime {
  /// Global scope
  static DimeScope _rootScope = DimeScope("root");

  static T injectWithTag<T>(String tag) {
    return inject(tag: tag);
  }

  static T inject<T>({String tag}) {
    var instance = _rootScope._inject<T>(tag: tag);
    if (instance == null) {
      throw DimeException.factoryNotFound(type: T);
    } else
      return instance;
  }

  static void addScope(DimeScope scope) {
    _rootScope.addScope(scope);
  }

  static DimeScope openScope(String name) {
    DimeScope scope = DimeScope(name);
    addScope(scope);
    return scope;
  }

  static void closeScope({String name, DimeScope scope}) {
    if (name != null) {
      _rootScope.closeScope(name: name);
    } else if (scope != null) {
      _rootScope.closeScope(scope: scope);
    }
  }

  static void clearAll() {
    _rootScope._modules.clear();
  }

  static void uninstallModule(BaseAppInjectorModule module) {
    _rootScope._modules.remove(module);
  }

  static void installModule(BaseAppInjectorModule module) {
    _rootScope.installModule(module);
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

  List<BaseAppInjectorModule> _modules = [];

  installModule(BaseAppInjectorModule module) {
    _modules.add(module);
    module.updateInjections();
  }

  uninstallModule(BaseAppInjectorModule module) {
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

  add(Type type, InjectFactory factory) {
    _scopeModule.injectMap[type] = factory;
  }

  remove(Type type) {
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
    for (BaseAppInjectorModule module in _modules) {
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

class _DimeScopeModule extends BaseAppInjectorModule {
  @override
  void updateInjections() {
    // empty
  }
}
