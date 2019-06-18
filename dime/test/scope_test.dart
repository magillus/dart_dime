import 'package:dime/dime.dart';
import 'package:test/test.dart';

import 'common.dart';

// if executed directly.
void main() {
  DimeScopeTests.testScopes();
}

/// Test class to be referenced by main 'dime_test.dart' tests.
/// modules:
/// ModuleA   -> AA()
///           -> AB()
///           -> AC()
/// ModuleB   -> BA()
///           -> BB()
///           -> BC()
/// ModuleC   -> CA()
///           -> CB()
///           -> CC()
/// ModuleXX  -> AA()
///           -> BB()
///           -> CC()
///
/// scope graph:
///
/// Dime  -> ModuleC
///       -> ModuleXX (override)
///       ->  scope1  -> ModuleA
///                   -> ModuleB
///       ->  scope2  -> ModuleA
///                   -> ModuleC
///                   -> scope 21 -> ModuleC
///                   -> scope 22 -> ModuleA
///                               -> ModuleB
///
/// example injections:
/// scope2.inject<CA> -> from scope2.ModuleC.CA
/// Dime.inject<CA> -> from dime.ModuleC.CA
/// scope1.inject<CA> -> from dime.ModuleC.CA
/// scope1.inject<AA> -> from scope1.ModuleA.AA
/// scope2.inject<BC> -> not found - can't access other scopes
/// scope2.inject<AB> -> from scope2.ModuleA.AB
/// Dime.inject<AA>   -> dime.ModuleXX.AA
/// Dime.inject<AB>   -> not found - Dime can't drill to scopes
/// Dime.inject<CC>   -> dime.ModuleC.CC
///
/// scope21.inject<AA> -> scope2.ModuleA.AA
/// scope21.inject<CC> -> scope21.ModuleC.CC
/// scope22.inject<AC> -> scope22.ModuleA.AC
/// scope22.inject<CB> -> scope2.ModuleC.CB
/// scope21.inject<BB> -> dime.ModuleX.BB
///
/// todo should we allow go down the tree?
/// todo how to resolve duplicate on same level
///
class DimeScopeTests {

  static void testScopes() {
    DimeScope scope1;
    DimeScope scope2;
    DimeScope scope21;
    DimeScope scope22;

    group('Dime inject - scoped', () {
      setUp(() {
        Dime.clearAll();
        Dime.installModule(ModuleC());
        Dime.installModule(ModuleXX(), override: true);
        scope1 = Dime.openScope("1");
        scope1.installModule(ModuleA());
        scope1.installModule(ModuleB());
        scope2 = Dime.openScope("2");
        scope2.installModule(ModuleA());
        scope2.installModule(ModuleC());
        scope21 = scope2.openScope("1");
        scope21.installModule(ModuleC());
        scope22 = scope2.openScope("2");
        scope22.installModule(ModuleA());
        scope22.installModule(ModuleB());
      });

      test('test multiple scopes levels injects', () {
        expect(Dime.inject<CA>().runtimeType, CA);
        expect(Dime.inject<AA>().runtimeType, AA);
        expect(Dime.inject<CC>().runtimeType, CC);
        // ignore: unnecessary_lambdas
        expectException(() => Dime.inject<AB>(), DimeException);

        expect(scope2.inject<CA>().runtimeType, CA);
        expect(scope1.inject<CA>().runtimeType, CA);
        expect(scope1.inject<AA>().runtimeType, AA);
        expectException(() => scope2.inject<BC>(), DimeException);
        expect(scope2.inject<AB>().runtimeType, AB);

        expect(scope21.inject<AA>().runtimeType, AA);
        expect(scope21.inject<CC>().runtimeType, CC);
        expect(scope22.inject<AC>().runtimeType, AC);
        expect(scope22.inject<CB>().runtimeType, CB);
        expect(scope21.inject<BB>().runtimeType, BB);
      });
    });
  }
}

class CA {}

class CB {}

class CC {}

class BA {}

class BB {}

class BC {}

class AA {}

class AB {}

class AC {}

class ModuleA extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(AA());
    addSingle(AB());
    addSingle(AC());
  }
}

class ModuleB extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(BA());
    addSingle(BB());
    addSingle(BC());
  }
}

class ModuleC extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(CA());
    addSingle(CB());
    addSingle(CC());
  }
}

class ModuleXX extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(AA());
    addSingle(BB());
    addSingle(CC());
  }
}
