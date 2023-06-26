import '../dime.dart';
import 'common.dart';

/// Typed type to create a instance with a [tag] definition provided.
/// This type is used in generative InjectFactory
typedef Creator<T> = T Function(String? tag);

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
  T createForTag(String? tag) {
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
  T createTagged(String? tag) {
    return creatorDelegate(tag);
  }
}

/// InjectFactory that stores singleton instances per tag.
class SingleByTagInstanceFactory<T> extends TaggedSingletonInjectFactory<T> {
  /// Adds [instance] for a given [tag], overriding old value if exists.
  void put(String? tag, T instance) {
    if (taggedSingletons.containsKey(tag)) {
      // clear old instance
      Closable.closeWith(taggedSingletons[tag]);
    }
    taggedSingletons[tag ?? InjectTagFactory.defaultTag] = instance;
  }

  /// Creates a [T] instance for a [tag].
  /// If instance of [T] exists in singleton map it will return it
  /// without creation of new.
  @override
  T createForTag(String? tag) {
    final instance = taggedSingletons[tag ?? InjectTagFactory.defaultTag];
    if (instance == null) {
      throw DimeException(message: 'No value for tag: $tag');
    }
    return instance;
  }
}

/// Single instance factory where instance created is given at constructor.
class SingleInstanceFactory<T> extends SingleInjectFactory<T> {
  /// Creates [InjectFactory] with single [instance] of [T] type.
  SingleInstanceFactory(T instance) : super(instance);

  /// Implementation of [createInstance] should never be called
  @override
  T createInstance() => throw DimeException.message(
      "Single Instance should not call createInstance");
}

/// Injector factory that stores and re-shares the same instance
/// of the T object.
abstract class SingleInjectFactory<T> extends InjectFactory<T> with Closable {
  T? _localSingleton;

  /// Local singleton value created in this factory
  T? get localSingleton => _localSingleton;

  /// Creates instance of SingleInjectFactory
  /// with preloaded instance as optional.
  SingleInjectFactory([this._localSingleton]);

  /// Creates instance.
  T createInstance();

  @override
  T create() {
    final singleton = _localSingleton;
    if (singleton == null) {
      final createdSingleton = createInstance();
      _localSingleton = createdSingleton;
      return createdSingleton;
    } else {
      return singleton;
    }
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
  T createForTag(String? tag);

  /// Method that checks if instance is already in singleton map
  /// before creating new instance of [T]
  @override
  T createTagged(String? tag) {
    if (tag == null) {
      return _handleDefault();
    }
    var localInstance = taggedSingletons[tag];
    if (localInstance == null) {
      final createdInstance = createForTag(tag);
      taggedSingletons[tag] = createdInstance;
      return createdInstance;
    } else {
      return localInstance;
    }
  }

  @override
  T create() {
    return createForTag(InjectTagFactory.defaultTag);
  }

  T _handleDefault() {
    var localInstance = taggedSingletons[InjectTagFactory.defaultTag];
    if (localInstance == null) {
      final createdInstance = create();
      taggedSingletons[InjectTagFactory.defaultTag] = createdInstance;
      return createdInstance;
    } else {
      return localInstance;
    }
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
  T createTagged(String? tag);
}

/// InjectFactory abstract class that provides a instance from a [create] method
// ignore: one_member_abstracts
abstract class InjectFactory<T> {
  /// Creates a instance of [T]
  T create();
}
