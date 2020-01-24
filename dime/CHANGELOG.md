## 0.3.3 - Upgrade Fimber version
- Upgrades Fimber version to not depend on `dart:io`

## 0.3.1 - Dime scopes updates

- added scopes usages
- minor updates for dependency

## 0.3.0 - Dime static change

- refactored to use static methods as `dime*` not `Dime.` static class
- `Dime.` still available via deprecated API notation
- changed name from `inject` to `get` to better match name to function of the method
- `inject` still available via deprecated API notation
- Code styles updates based on effective-dart lint rules.
- Adding global scope property - to be used with Dime Flutter package (in development)

## 0.2.0 - Bug fix

- added same module getion visible to next getions

## 0.1.1 - Scopes updates

- allow override module's instances for a types.
- Unit tests update

## 0.1.0 - initial release

- Dependency getion with global scope.
- get with modules and sub-scopes's modules.
- Support for modules and scopes.
- Creator types, on demand getion
- Ability to add singletons and singleton of same type per tag.
- Closable types will be properly disposed when closing scopes
