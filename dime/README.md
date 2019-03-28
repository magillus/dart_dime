Dime is Dart based Dependency Injection framework.

Dime allows to create modules and inject based on interfaces, provides way to specify factory methods and tag based same type instances.
Support for multiple modules and scopes with `Closable` interface to cleanup resources.

Get it from pub page: [Pub dime page](https://pub.dartlang.org/packages/dime)

__Note__: 
All examples below are from [example file](example/dime_example.dart) file. Go there for high level view.

## Usage

A simple usage example:

```dart
import 'package:dime/dime.dart';

void main() {
  /// Service Module does include details how to create the objects.   
  Dime.installModule(ServiceModule());
     
  MyTitleService titleService = Dime.inject();
  print(titleService.text());
  
}


```

## Setup

### Add package dependency to pubspec.yaml:

```yaml
 depedency: 
   ...
   dime: ^0.2.0
   ...
```

### Define module:

Create a module and how it creates its dependencies:

```dart
class MyModule  extends BaseAppInjectorModule {
    @override
    void updateInjections() {
        /// define injection factories - below for examples      
    }
}

```

Below are examples that can be used inside `updateInjections` method.

#### Singleton per type

Inject single value by its class type:

```dart
  addSingle(MyTitleService());
```

Inject singleton value by implementing interface:
```dart
  addSingle<TitleService>(MyTitleService());
```

#### Singleton per type with tag

Inject single value by its class type:

```dart
  addSingle(MyTitleService(), tag: "home-title");
  addSingle(MyTitleService(), tag: "details-title");
```

Inject singleton value by implementing interface:
```dart
  addSingle<TitleService>(MyTitleService(), tag: "home-title");
```

#### Creator on-demand injection, it uses type of Creator

This is creator - which will create an object at time of injection.
```dart
typedef T Creator<T>(String tag);
```

The Creator provides optional `String tag` that may be used to create the tagged instance.

```dart
addCreator<TextService>((tag) =>
        MyTitleService(title: "Test title: $tag: now: ${DateTime.now()}"));
```
#### Creator on-demand injection with singleton storage - delayed singleton.

Similar to above example with `addCreator`, however created instance will be cached per tag.

```dart
addSingleByCreator((tag)=>MyDescriptionService());
```

#### Create your own factory.

You can always create your own factory by extending `InjectFactory<T>` and add those to the module.

```dart
 addFactory(MyTooltipService, MyCustomFactory());
```

__Note:__
There are some other Factories already provided to be used - like:
- `InjectTagFactory` for create method with a Tag
- `TaggedSingletonInjectFactory` - for tagged singletons with `Closeable` interface
- `SingleInjectFactory` - single inject factory with `Closable` interface

### Add modules to the scope (global too)

You can add modules to the main global scope of Dime or into the opened scopes.
When a scope closes all modules in that scope will also close (clean up) by calling each of its `Closeable` factory `close()` method to cleanup resources.

#### Add Module to Global Dime scope.

```dart
  Dime.installModule(ServiceModule());
```




## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme

