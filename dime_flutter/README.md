# Dime Flutter package

Bringing Dime dependency injection to Flutter with usable helper methods and Widgets.

## Getting Started

Take a look at [Dime](https://pub.dev/packages/dime) package for BaseModules and definitions.

Use `DimeScopeFlutter` to wrap child widget with Dime Scope and provide list of modules for that scope.
Root Scope modules are always fallback to.
Use `DimeFlutter.scopeOf(...)` as inherit widget to fetch `DimeScope` to get instances you need down the tree.

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

