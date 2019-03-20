import 'package:dime/dime.dart';
import 'package:fimber/fimber.dart';

main() {
  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Started app");
  Dime.installModule(ServiceModule());
  Fimber.i("Installed module");
  var scope = DimeScope("test");
  scope.installModule(ScopeModule());
  Dime.addScope(scope);

  MyTitleService titleService = Dime.inject();
  print(titleService.text());

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

class ScopeModule extends BaseAppInjectorModule {
  @override
  void updateInjections() {
    addSingle(MyTitleService(title: "test scope service"));
  }
}

class ServiceModule extends BaseAppInjectorModule {
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

class MyDescriptionService extends TextService {
  String description;

  MyDescriptionService({this.description = "My description"});

  @override
  int someNumber() {
    return 1;
  }

  @override
  String text() {
    return description;
  }
}

class MyTooltipService extends TextService {
  String tooltip;

  MyTooltipService({this.tooltip = "empty tooltip"}) {
    Fimber.i("Creatig instance of Tooltip Service: $tooltip");
  }

  @override
  int someNumber() {
    return tooltip.length;
  }

  @override
  String text() {
    return tooltip;
  }
}

class MyTitleService extends TextService {
  String title;

  MyTitleService({this.title = "My text title"}) {
    Fimber.i("Creating instance of MyTitleService: $title");
  }

  @override
  int someNumber() {
    return 0;
  }

  @override
  String text() {
    return this.title;
  }
}

abstract class TextService {
  String text();

  int someNumber();
}
