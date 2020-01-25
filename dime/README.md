Dime is Dart Dependency "injection framework", it is more like factory and static lookup but with nice wrap.

Dime allows to create modules that define injection types and their InjectFactory implementations.
It can easily base on interfaces which allows to pick different implementations. 
Supports for tag tag based same type instances.
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
  dimeInstall(ServiceModule());
     
  MyTitleService titleService = dimeGet();
  // or 
  var titleService = dimeGet<MyTitleService>();
  print(titleService.text());
  
}


```

## Setup

### Add package dependency to pubspec.yaml:

```yaml
 depedency: 
   ...
   dime: ^0.3.4
   ...
```

### Define module:

Create a module and how it creates its dependencies:

```dart
class MyModule  extends BaseAppgetorModule {
    @override
    void updateInjections() {
        /// define injection factories - below for examples      
    }
}

```

Below are examples that can be used inside `updateinjections` method.

#### Singleton per type

get single value by its class type:

```dart
  addSingle(MyTitleService());
```

get singleton value by implementing interface:
```dart
  addSingle<TitleService>(MyTitleService());
```

#### Singletons per type with tag

get single value by its class type:

```dart
  addSingle(MyTitleService(), tag: "home-title");
  addSingle(MyTitleService(), tag: "details-title");
```

get singleton value by implementing interface:
```dart
  addSingle<TitleService>(MyTitleService(), tag: "home-title");
```

#### Creator on-demand injection, it uses type of Creator

This is creator - which will create an object at time of injection.
```dart
typedef Creator<T> = T Function(String tag);
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

You can always create your own factory by extending `getFactory<T>` and add those to the module.

```dart
 addFactory(MyTooltipService, MyCustomFactory());
```

__Note:__
There are some other Factories already provided to be used - like:
- `getTagFactory` for create method with a Tag
- `TaggedSingletongetFactory` - for tagged singletons with `Closeable` interface
- `SinglegetFactory` - single get factory with `Closable` interface

### Add modules to the scope (global too)

You can add modules to the main global scope of Dime or into the opened scopes.
When a scope closes all modules in that scope will also close (clean up) by calling each of its `Closeable` factory `close()` method to cleanup resources.

#### Add Module to Global Dime scope.

```dart
  dimeInstall(ServiceModule());
```

### Dime Scope fetch up the tree examples:

Test class to be referenced by main [scope_test.dart](https://github.com/magillus/dart_dime/blob/master/dime/test/scope_test.dart#L11) tests.

#### Modules:

| Module | Instance |
|----:|:---|
| ModuleA | AA() |
|         | AB() |
|         | AC() |
|||
|ModuleB  | BA() |
|         | BB() |
|         | BC() |
|||
|ModuleC  | CA() |
|         | CB() |
|         | CC() |
| | |
|ModuleXX | AA() |
|         | BB() |
|         | CC() |


#### Scope graph:

| Root Scope| Modules/Scopes | Modules/Scopes | Modules/Scopes |
|---:|:---|:---|:---|
|Dime  | - ModuleC|
|||||
|      | - ModuleXX (override) |
|||||
|      | - scope1  | - ModuleA|
|      |           | - ModuleB|
|||||
|      | - scope2  | - ModuleA|
|      |          | - ModuleC|
|||||
|      |          | - scope 21 | - ModuleC|
|||||
|      |          | - scope 22 | - ModuleA|
|      |           |          | - ModuleB|

#### Example injections:

scope2.inject<CA> -> from scope2.ModuleC.CA

Dime.inject<CA> -> from dime.ModuleC.CA

scope1.inject<CA> -> from dime.ModuleC.CA

scope1.inject<AA> -> from scope1.ModuleA.AA

scope2.inject<BC> -> not found - can't access other scopes

scope2.inject<AB> -> from scope2.ModuleA.AB

Dime.inject<AA>   -> dime.ModuleXX.AA

Dime.inject<AB>   -> not found - Dime can't drill to scopes

Dime.inject<CC>   -> dime.ModuleC.CC

scope21.inject<AA> -> scope2.ModuleA.AA

scope21.inject<CC> -> scope21.ModuleC.CC

scope22.inject<AC> -> scope22.ModuleA.AC

scope22.inject<CB> -> scope2.ModuleC.CB

scope21.inject<BB> -> dime.ModuleX.BB


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme

