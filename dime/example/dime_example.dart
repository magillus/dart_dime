import 'package:dime/dime.dart';
import 'package:fimber/fimber.dart';

import '../test/common.dart';

/// Example app showing Dime installation and usage
void main() {
  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Started app");
  Dime.installModule(ServiceModule());
  Fimber.i("Installed module");
  var scope = DimeScope("test");
  scope.installModule(ScopeModule());
  Dime.addScope(scope);

  // ignore: omit_local_variable_types
  MyTitleService titleService = Dime.inject();
  print(titleService.text());

  // ignore: omit_local_variable_types
  MyTitleService titleService2 = Dime.inject(tag: "Test tag");
  print(titleService2.text());

  var creatorService = Dime.inject<TextService>();
  print(creatorService.text());

  creatorService = Dime.inject<TextService>(tag: "TEST TAG A");
  print(creatorService.text());

  var scopeTitle = Dime.inject<MyTitleService>();
  print(scopeTitle.text());

  scopeTitle = scope.inject<MyTitleService>();
  print(scopeTitle.text());

  var tooltip = Dime.inject<MyTooltipService>();
  print(tooltip.text());

  var scopeDescription = scope.inject<MyDescriptionService>();
  print(scopeDescription.text());

  Dime.closeScope(scope: scope);

  scopeDescription = scope.inject<MyDescriptionService>();
  print(scopeDescription.text());
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
