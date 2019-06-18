import 'package:dime/dime.dart';
import 'package:dime/src/common.dart';
import 'package:fimber/fimber.dart';

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
                InjectTagFactory.defaultTag,
                oldSingleInjectFactory._localSingleton);
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
  T get<T>({String tag}) {
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
  /// Injects the created value from the module
  /// [Deprecated] - use [get]
  @deprecated
  T inject<T>({String tag}) {
    return get(tag: tag);
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

/// Singleton [InjectFactory] for a [T] type.
/// It wil create an object using [Creator] method
/// and store as singleton for future injections.
class CreatorSingleInjectFactory<T> extends TaggedSingletonInjectFactory<T> {
  /// Creator delegate to create the instance.
  Creator<T> creatorDelegate;

  /// Creates instance for this [InjectFactory] with [Creator] function.
  CreatorSingleInjectFactory(this.creatorDelegate);

  /// Creates an instance for a [tag].
  @override
  T createForTag(String tag) {
    return creatorDelegate(tag);
  }
}

/// [Creator] based [InjectFactory] that creates new instance on every
/// injection.
class CreatorInjectFactory<T> extends InjectTagFactory<T> {
  /// [Creator] method instance
  Creator<T> creatorDelegate;

  /// Creates [CreatorInjectFactory] with provided [Creator]
  CreatorInjectFactory(this.creatorDelegate);

  /// Creates instance with default tag.
  @override
  T create() {
    return creatorDelegate(InjectTagFactory.defaultTag);
  }

  /// Creates instance with defined [tag]
  @override
  T createTagged(String tag) {
    return creatorDelegate(tag);
  }
}

/// Typed type to create a instance with a [tag] definition provided.
/// This type is used in generative InjectFactory
typedef Creator<T> = T Function(String tag);

/// InjectFactory that stores singleton instances per tag.
class SingleByTagInstanceFactory<T> extends TaggedSingletonInjectFactory<T> {
  /// Adds [instance] for a given [tag], overriding old value if exists.
  void put(String tag, T instance) {
    if (taggedSingletons.containsKey(tag)) {
      // clear old instance
      Closable.closeWith(taggedSingletons[tag]);
    }
    taggedSingletons[tag] = instance;
  }

  /// Creates a [T] instance for a [tag].
  /// If instance of [T] exists in singleton map it will return it
  /// without creation of new.
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
  /// Creates [InjectFactory] with single [instance] of [T] type.
  SingleInstanceFactory(T instance) {
    _localSingleton = instance;
  }

  /// Implementation of [createInstance] should never be called
  @override
  T createInstance() => throw DimeException.message(
      "Single Instance should not call createInstance");
}

/// Injector factory that stores and re-shares the same instance
/// of the T object.
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

/// InjectFactory that stores singleton map per each tag of a given type [T].
abstract class TaggedSingletonInjectFactory<T> extends InjectTagFactory<T>
    with Closable {
  /// Map of singleton instances of [T] per each [String] tag.
  Map<String, T> taggedSingletons = {};

  /// Abstract method to create instance of [T] for a tag.
  T createForTag(String tag);

  /// Method that checks if instance is already in singleton map
  /// before creating new instance of [T]
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
    return createForTag(InjectTagFactory.defaultTag);
  }

  T _handleDefault() {
    var localInstance = taggedSingletons[InjectTagFactory.defaultTag];
    if (localInstance == null) {
      localInstance = create();
      taggedSingletons[InjectTagFactory.defaultTag] = localInstance;
    }
    return localInstance;
  }

  /// Closes all instances of singleton if they implement [Closable]
  /// Cleans up the singleton map.
  @override
  void close() {
    for (var instance in taggedSingletons.values.toList()) {
      Closable.closeWith(instance);
    }
    taggedSingletons.clear();
  }
}

/// InjectTagFactory abstract class with a tag support
abstract class InjectTagFactory<T> extends InjectFactory<T> {
  /// Default tag if not provided
  static const String defaultTag = "_NULL_TAG";

  /// Creates instance of [T] with provided tag value.
  T createTagged(String tag);
}

/// InjectFactory abstract class that provides a instance from a [create] method
// ignore: one_member_abstracts
abstract class InjectFactory<T> {
  /// Creates a instance of [T]
  T create();
}
