import 'package:dime/dime.dart';
import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

typedef Runner = void Function();

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
    return title;
  }
}

abstract class TextService {
  String text();

  int someNumber();
}

class DetailsService {
  TextService title = Dime.get<MyTitleService>();
  TextService description = Dime.get<MyDescriptionService>();
  TextService tooltip = Dime.get<MyTooltipService>();
}
