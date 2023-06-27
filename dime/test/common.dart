import 'package:dime/dime.dart';
import 'package:test/test.dart';

typedef Runner = void Function();

/// Expects exception of the [type] when running a function [runner]
void expectException(Runner runner, Type type) {
  dynamic thrownException;
  try {
    runner();
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    thrownException = e;
  }
  expect(thrownException?.runtimeType, type,
      reason: "Expecting Exception of type: $type");
}

/// Sample Description service that implements [TextService]
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

/// Sample Service that implements [TextService]
class MyTooltipService extends TextService {
  String tooltip;

  MyTooltipService({this.tooltip = "empty tooltip"}) {
    print("Creatig instance of Tooltip Service: $tooltip\n");
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

/// Sample TextServiced used in Future DI test
class My2TitleService extends TextService {
  @override
  int someNumber() {
    return 2;
  }

  @override
  String text() {
    return 'Test Future Service';
  }
}

/// Sample Title service that implements [TextService]
class MyTitleService extends TextService {
  String title;

  MyTitleService({this.title = "My text title"}) {
    print("Creating instance of MyTitleService: $title\n");
  }

  @override
  int someNumber() {
    return 0;
  }

  @override
  String text() {
    return title;
  }
}

abstract class TextService {
  String text();

  int someNumber();
}

class DetailsService {
  TextService title = dimeGet<MyTitleService>();
  TextService description = dimeGet<MyDescriptionService>();
  TextService tooltip = dimeGet<MyTooltipService>();
}
