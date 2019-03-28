import 'package:dime/dime.dart';
import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

import 'common.dart';
import 'scope_test.dart';

void main() {
  Fimber.plantTree(DebugTree());
  group('Dime inject', () {
    setUp(() {
      Dime.clearAll();
      Dime.installModule(SinglesModule());
    });

    test('inject on Interface Test', () {
      TextService textService = Dime.inject();
      assert(textService != null);
      assert(textService is MyDescriptionService);
      expect(textService.text(), "Some description for tests.");
    });

    test('inject on class MyTitleService', () {
      MyTitleService textService = Dime.inject();
      assert(textService != null);
      assert(textService is MyTitleService);
      expect(textService.text(), "My text title");
    });

    test('inject on class MyDescriptionService', () {
      try {
        Dime.inject<MyDescriptionService>();
      } catch (e) {
        assert(e is DimeException);
        return;
      }
      expect(true, false, reason: "Should expect DimeException");
    });

    test('inject on class MyTooltipService', () {
      MyTooltipService textService = Dime.inject();
      assert(textService != null);
      assert(textService is MyTooltipService);
      expect(textService.text(), "test tooltip");
    });

    test('add new module', () {
      try {
        Dime.installModule(SinglesModule_Copy());
      } catch (e) {
        expect(e.runtimeType, DimeException);
        return;
      }
      expect(null, DimeException,
          reason: "Expecting DimeException thrown error for duplicates.");
    });
    test('add override from new module', () {
      Dime.installModule(SinglesModule_Copy(), override: true);

      TextService textService = Dime.inject();
      assert(textService != null);
      assert(textService is MyDescriptionService);
      expect(textService.text(), "Some description for tests. COPY");

      MyTitleService titleService = Dime.inject();
      assert(titleService != null);
      assert(titleService is MyTitleService);
      expect(titleService.text(), "Test title_COPY");

      // instance not replaced by new module override
      MyTooltipService tooltipService = Dime.inject();
      assert(tooltipService != null);
      assert(tooltipService is MyTooltipService);
      expect(tooltipService.text(), "test tooltip");
    });
  });

  group('Dime inject - tagged', () {
    setUp(() {
      Dime.clearAll();
      Dime.installModule(SinglesModule());
    });

    test('inject with tag', () {
      MyTitleService titleService = Dime.injectWithTag("Test tag");
      assert(titleService != null);
      assert(titleService is MyTitleService);
      expect(titleService.text(), "second title");
    });

    test('inject with unkown tag', () {
      try {
        Dime.injectWithTag<MyTitleService>("Some random Tag");
      } catch (e) {
        expect(e.runtimeType, DimeException);
        return;
      }
      expect(null, DimeException,
          reason: "Expedting DimeException for factory not found.");
    });

    test('inject with tag on untagged instance', () {
      try {
        Dime.injectWithTag<TextService>("Test");
      } catch (e) {
        expect(e.runtimeType, DimeException);
        return;
      }
      expect(null, DimeException,
          reason: "Expecting DimeException for factor with a tag not found");
    });
  });

  group("Dime inject within module", () {
    setUp(() {
      Dime.clearAll();
      //Dime.installModule(SinglesModule());
    });
    test("Single module dependency", () {
      Dime.installModule(SameModuleDep());
      expect(Dime
          .inject<DetailsService>()
          .runtimeType, DetailsService);
    });
  });

  DimeScopeTests.testScopes();
}

class SameModuleDep extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(MyTooltipService());
    addSingle(MyTitleService());
    addSingle(MyDescriptionService());
    addSingle(DetailsService());
  }
}

class SinglesModule_Copy extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(MyTitleService(title: "Test title_COPY"));
    addSingle<TextService>(
        MyDescriptionService(description: "Some description for tests. COPY"));
  }
}

class SinglesModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(MyTitleService());
    addSingle(MyTitleService(title: "second title"), tag: "Test tag");
    addSingle(MyTooltipService(tooltip: "test tooltip"));
    addSingle<TextService>(
        MyDescriptionService(description: "Some description for tests."));
  }
}
