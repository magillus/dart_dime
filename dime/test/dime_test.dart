import 'dart:async';

import 'package:dime/dime.dart';
import 'package:dime/src/dime_module.dart';
import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

import 'common.dart';
import 'scope_test.dart';

void main() {
  Fimber.plantTree(DebugTree());

  group('Dime inject', () {
    setUp(() {
      dimeReset();
      dimeInstall(SinglesModule());
    });

    test('inject on Interface Test', () {
      var textService = dimeGet<TextService>();
      assert(textService is MyDescriptionService);
      expect(textService.text(), "Some description for tests.");
    });

    test('inject on class MyTitleService', () {
      var textService = dimeGet<MyTitleService>();
      assert(textService is MyTitleService);
      expect(textService.text(), "My text title");
    });

    test('inject on class MyDescriptionService', () {
      try {
        dimeGet<MyDescriptionService>();
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        assert(e is DimeException);
        return;
      }
      expect(true, false, reason: "Should expect DimeException");
    });

    test('inject on class MyTooltipService', () {
      var textService = dimeGet<MyTooltipService>();
      assert(textService is MyTooltipService);
      expect(textService.text(), "test tooltip");
    });

    test('add new module', () {
      try {
        dimeInstall(SinglesModuleCopy());
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        expect(e.runtimeType, DimeException);
        return;
      }
      expect(null, DimeException,
          reason: "Expecting DimeException thrown error for duplicates.");
    });
    test('add override from new module', () {
      dimeInstall(SinglesModuleCopy(), override: true);

      var textService = dimeGet<TextService>();
      assert(textService is MyDescriptionService);
      expect(textService.text(), "Some description for tests. COPY");

      var titleService = dimeGet<MyTitleService>();
      assert(titleService is MyTitleService);
      expect(titleService.text(), "Test title_COPY");

      // instance not replaced by new module override
      var tooltipService = dimeGet<MyTooltipService>();
      assert(tooltipService is MyTooltipService);
      expect(tooltipService.text(), "test tooltip");
    });
  });

  group('Dime inject - tagged', () {
    setUp(() {
      dimeReset();
      dimeInstall(SinglesModule());
    });

    test('inject with Future', () async {
      var textFuture = await dimeGetAsync<My2TitleService>();
      My2TitleService service;
      service = await dimeGetAsync();
      assert(textFuture is My2TitleService);

      expect(service.text(), 'Test Future Service');
      expect(textFuture.text(), 'Test Future Service');
    });

    test('inject with tag', () {
      var titleService = dimeGetWithTag<MyTitleService>("Test tag");
      assert(titleService is MyTitleService);
      expect(titleService.text(), "second title");
    });

    test('inject with unkown tag', () {
      try {
        dimeGetWithTag<MyTitleService>("Some random Tag");
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        expect(e.runtimeType, DimeException);
        return;
      }
      expect(null, DimeException,
          reason: "Expedting DimeException for factory not found.");
    });

    test('inject with tag on untagged instance', () {
      try {
        dimeGetWithTag<TextService>("Test");
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        expect(e.runtimeType, DimeException);
        return;
      }
      expect(null, DimeException,
          reason: "Expecting DimeException for factor with a tag not found");
    });
  });

  group("Dime inject within module", () {
    // ignore: unnecessary_lambdas
    setUp(() {
      dimeReset();
    });
    test("Single module dependency", () {
      dimeInstall(SameModuleDep());
      expect(dimeGet<DetailsService>().runtimeType, DetailsService);
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

class SinglesModuleCopy extends BaseDimeModule {
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
    addSingleByCreator((tag) async {
      return Future.delayed(Duration(seconds: 2), () {
        return My2TitleService();
      });
    });
    addSingle(MyTitleService());
    addSingle(MyTitleService(title: "second title"), tag: "Test tag");
    addSingle(MyTooltipService(tooltip: "test tooltip"));
    addSingle<TextService>(
        MyDescriptionService(description: "Some description for tests."));
  }
}
