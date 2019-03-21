import 'package:dime/dime.dart';
import 'package:dime/src/common.dart';
import 'package:fimber/fimber.dart';

abstract class BaseDimeModule with Closable {
  final Map<Type, InjectFactory> _injectMap = {};

  Map<Type, InjectFactory> get injectMap => _injectMap;

  void updateInjections();

  void addFactory(Type type, InjectFactory factory) {
    _injectMap[type] = factory;
  }

  void remove(Type type) {
    _injectMap.remove(type);
  }

  void addCreator<T>(Creator<T> objectCreator) {
    injectMap[T] = CreatorInjectFactory<T>(objectCreator);
  }

  addSingleByCreator<T>(Creator<T> objectCreator) {
    injectMap[T] = CreatorSingleInjectFactory<T>(objectCreator);
  }

  /// Will add instance to the module, if T is defined in <T> method call, it will find the instance faster.
  /// Otherwise it would find first instance that matches type check with T
  void addSingle<T>(T instance, {String tag}) {
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
        }
        if (instanceFactory is SingleInjectFactory<T>) {
          // remove from single ad make it taggable factory
          var oldSingleInjectFactory =
              (instanceFactory as SingleInjectFactory<T>);
          instanceFactory = SingleByTagInstanceFactory<T>();
          _injectMap[T] = instanceFactory;
          if (oldSingleInjectFactory._localSingleton != null) {
            (instanceFactory as SingleByTagInstanceFactory<T>).put(
                InjectTagFactory.DEFAULT_TAG,
                oldSingleInjectFactory._localSingleton);
          }
          (instanceFactory as SingleByTagInstanceFactory<T>).put(tag, instance);
        }
        if (instanceFactory is SingleByTagInstanceFactory<T>) {
          instanceFactory.put(tag, instance);
        }
      }
    } else
      throw Exception("Instance provided does not match type.");
  }

  /// Injects the created value from the module
  T inject<T>({String tag}) {
    var name = T.toString();
    var injectFactory = injectMap[T];

    if (injectFactory != null && injectFactory is InjectTagFactory) {
      // use default tag for TaggedInjectFactory
      var instance =
          injectFactory.createTagged(tag ?? InjectTagFactory.DEFAULT_TAG);
      Fimber.d("Injecting: $name for tag $tag with $instance");
      return instance;
    } else if (injectFactory != null && injectFactory is InjectFactory) {
      if (tag != null && tag != InjectTagFactory.DEFAULT_TAG) {
        return null; // not providing instance because tagged instance was expected.
      } else {
        var instance = injectFactory.create();
        Fimber.d("Injecting: $name with $instance");
        return instance;
      }
    } else {
      return null;
    }
  }

  @override
  void close() {
    _injectMap.forEach((t, InjectFactory f) {
      if (f is SingleInjectFactory) {
        Closable.closeWith(f);
      }
    });
  }
}

class CreatorSingleInjectFactory<T> extends TaggedSingletonInjectFactory<T> {
  Creator<T> creatorDelegate;

  CreatorSingleInjectFactory(this.creatorDelegate);

  @override
  T createForTag(String tag) {
    return creatorDelegate(tag);
  }
}

class CreatorInjectFactory<T> extends InjectTagFactory<T> {
  Creator<T> creatorDelegate;

  CreatorInjectFactory(this.creatorDelegate);

  @override
  T create() {
    return creatorDelegate(InjectTagFactory.DEFAULT_TAG);
  }

  @override
  T createTagged(String tag) {
    return creatorDelegate(tag);
  }
}

typedef T Creator<T>(String tag);

class SingleByTagInstanceFactory<T> extends TaggedSingletonInjectFactory<T> {
  put(String tag, T instance) {
    if (taggedSingletons.containsKey(tag)) {
      // clear old instance
      Closable.closeWith(taggedSingletons[tag]);
    }
    taggedSingletons[tag] = instance;
  }

  @override
  T createForTag(String tag) {
    if (!taggedSingletons.containsKey(tag)) {
      return null;
    }
    return taggedSingletons[tag];
  }
}

/// Single instance factory where instance created is given at constructor.
class SingleInstanceFactory<T> extends SingleInjectFactory<T> {
  SingleInstanceFactory(T instance) {
    _localSingleton = instance;
  }

  @override
  T createInstance() => throw DimeException.message(
      "Single Instance should not call createInstance");
}

/// Injector factory that stores and re-shares the same instance of the T object.
abstract class SingleInjectFactory<T> extends InjectFactory<T> with Closable {
  T _localSingleton;

  /// Creates instance.
  T createInstance();

  @override
  T create() {
    if (_localSingleton == null) {
      _localSingleton = createInstance();
    }
    return _localSingleton;
  }

  @override
  void close() {
    Closable.closeWith(_localSingleton);
    _localSingleton = null;
  }
}

abstract class TaggedSingletonInjectFactory<T> extends InjectTagFactory<T>
    with Closable {
  Map<String, T> taggedSingletons = {};

  T createForTag(String tag);

  @override
  T createTagged(String tag) {
    if (tag == null) {
      return _handleDefault();
    }
    var localInstance = taggedSingletons[tag];
    if (localInstance == null) {
      taggedSingletons[tag] = localInstance = createForTag(tag);
    }
    return localInstance;
  }

  @override
  T create() {
    return createForTag(InjectTagFactory.DEFAULT_TAG);
  }

  T _handleDefault() {
    var localInstance = taggedSingletons[InjectTagFactory.DEFAULT_TAG];
    if (localInstance == null) {
      localInstance = create();
      taggedSingletons[InjectTagFactory.DEFAULT_TAG] = localInstance;
    }
    return localInstance;
  }

  @override
  void close() {
    taggedSingletons.values.forEach((T instance) {
      if (instance != null && instance is Closable) {
        instance.close();
      }
    });
    taggedSingletons.clear();
  }
}

abstract class InjectTagFactory<T> extends InjectFactory<T> {
  static const String DEFAULT_TAG = "_NULL_TAG";

  T createTagged(String tag);
}

abstract class InjectFactory<T> {
  T create();
}
