import 'package:fimber/fimber.dart';

import 'common.dart';
import 'factories.dart';

/// Base Dime module for providing types and [InjectFactory] for types.
abstract class BaseDimeModule with Closable {
  final Map<Type, InjectFactory> _injectMap = {};

  /// Returns module's injection map.
  Map<Type, InjectFactory> get injectMap => _injectMap;

  /// Updates all injection - abstract method
  /// to be implemented by main [BaseDimeModule]
  void updateInjections();

  /// Adds a [factory] into module's injection map.
  void addFactory(Type type, InjectFactory factory) {
    _injectMap[type] = factory;
  }

  /// Removes a [type] from module's injection map.
  void remove(Type type) {
    _injectMap.remove(type);
  }

  /// Adds [InjectFactory] with [objectCreator] function.
  void addCreator<T>(Creator<T> objectCreator) {
    injectMap[T] = CreatorInjectFactory<T>(objectCreator);
  }

  /// Adds singleton [InjectFactory] with [objectCreator] function
  void addSingleByCreator<T>(Creator<T> objectCreator) {
    injectMap[T] = CreatorSingleInjectFactory<T>(objectCreator);
  }

  /// Will add instance to the module, if T is defined in <T> method call,
  /// it will find the instance faster.
  /// Otherwise it would find first instance that matches type check with T
  void addSingle<T>(T instance, {String? tag}) {
    if (instance is T) {
      if (tag == null) {
        if (injectMap.containsKey(T)) {
          Closable.closeWith(injectMap[T]);
        }
        injectMap[T] = SingleInstanceFactory<T>(instance);
      } else {
        var instanceFactory = injectMap[T];
        if (instanceFactory == null) {
          instanceFactory = SingleByTagInstanceFactory<T>();
          injectMap[T] = instanceFactory;
        }
        if (instanceFactory is SingleInjectFactory<T>) {
          // remove from single ad make it taggable factory
          var oldSingleInjectFactory = instanceFactory;
          instanceFactory = SingleByTagInstanceFactory<T>();
          _injectMap[T] = instanceFactory;
          if (oldSingleInjectFactory.localSingleton != null) {
            (instanceFactory as SingleByTagInstanceFactory<T>).put(
                InjectTagFactory.defaultTag,
                oldSingleInjectFactory.localSingleton);
          }
          (instanceFactory as SingleByTagInstanceFactory<T>).put(tag, instance);
        }
        if (instanceFactory is SingleByTagInstanceFactory<T>) {
          instanceFactory.put(tag, instance);
        }
      }
    } else {
      throw DimeException.message("Instance provided does not match type.");
    }
  }

  /// Gets the created value from the module
  T? get<T>({String? tag}) {
    var name = T.toString();
    var injectFactory = injectMap[T];

    if (injectFactory != null && injectFactory is InjectTagFactory) {
      // use default tag for TaggedInjectFactory
      var instance =
          injectFactory.createTagged(tag ?? InjectTagFactory.defaultTag);
      Fimber.d("Injecting: $name for tag $tag with $instance");
      return instance;
    } else if (injectFactory != null && injectFactory is InjectFactory) {
      if (tag != null && tag != InjectTagFactory.defaultTag) {
        return null; // Dime not provide providing instance,
        // because tagged instance was expected.
      } else {
        var instance = injectFactory.create();
        Fimber.d("Injecting: $name with $instance");
        return instance;
      }
    } else {
      return null;
    }
  }

  /// Closes the module and all its [InjectFactory].
  @override
  void close() {
    _injectMap.forEach((type, factory) {
      if (factory is SingleInjectFactory) {
        Closable.closeWith(factory);
      }
    });
  }
}
