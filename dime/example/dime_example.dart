import 'package:dime/dime.dart';
import 'package:fimber/fimber.dart';

import '../test/common.dart';

/// Example app showing Dime installation and usage
void main() {
  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Started app");
  dimeInstall(ServiceModule());
  Fimber.i("Installed module");
  var scope = dimeOpenScope("test");
  scope.installModule(ScopeModule());

  // ignore: omit_local_variable_types
  MyTitleService titleService = dimeGet();
  print(titleService.text());

  // ignore: omit_local_variable_types
  MyTitleService titleService2 = dimeGetWithTag("Test tag");
  print(titleService2.text());

  var creatorService = dimeGet<TextService>();
  print(creatorService.text());

  creatorService = dimeGet<TextService>(tag: "TEST TAG A");
  print(creatorService.text());

  var scopeTitle = dimeGet<MyTitleService>();
  print(scopeTitle.text());

  scopeTitle = dimeGet<MyTitleService>();
  print(scopeTitle.text());

  var tooltip = dimeGet<MyTooltipService>();
  print(tooltip.text());

  var scopeDescription = scope.get<MyDescriptionService>();
  print(scopeDescription.text());

  dimeCloseScope(scope: scope);

  try {
    scopeDescription = scope.get<MyDescriptionService>();
    print(scopeDescription.text());
  } on DimeException catch (e, t) {
    // expected thrown exception
    print("Expected exception: $e,\n$t");
  }
}

class ScopeModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(MyTitleService(title: "test scope service"));
  }
}

class ServiceModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(MyTitleService());
    addSingle(MyTitleService(title: "second title"), tag: "Test tag");
    addSingleByCreator((tag) => MyDescriptionService());
    addCreator<TextService>((tag) =>
        MyTitleService(title: "Test title: $tag: now- ${DateTime.now()}"));
    addFactory(MyTooltipService, MyCustomFactory());
  }
}

class MyCustomFactory extends InjectFactory<TextService> {
  @override
  TextService create() {
    return MyTooltipService(tooltip: "My custom factory tooltip");
  }
}
