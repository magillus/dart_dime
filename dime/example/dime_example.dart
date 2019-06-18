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
  MyTitleService titleService = Dime.get();
  print(titleService.text());

  // ignore: omit_local_variable_types
  MyTitleService titleService2 = Dime.get(tag: "Test tag");
  print(titleService2.text());

  var creatorService = Dime.get<TextService>();
  print(creatorService.text());

  creatorService = Dime.get<TextService>(tag: "TEST TAG A");
  print(creatorService.text());

  var scopeTitle = Dime.get<MyTitleService>();
  print(scopeTitle.text());

  scopeTitle = scope.get<MyTitleService>();
  print(scopeTitle.text());

  var tooltip = Dime.get<MyTooltipService>();
  print(tooltip.text());

  var scopeDescription = scope.get<MyDescriptionService>();
  print(scopeDescription.text());

  Dime.closeScope(scope: scope);

  scopeDescription = scope.get<MyDescriptionService>();
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
