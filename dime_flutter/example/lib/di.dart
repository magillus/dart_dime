import 'package:dime_flutter/dime_flutter.dart';
import 'package:flutter/material.dart';

class ServiceModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(DescriptionService());
    addSingle(TitleService());
  }
}

class DescriptionService extends TextService {
  @override
  String get path => "/home/description";

  @override
  // TODO: implement text
  String get text => "Test description text\nfor this instance.";
}

class TitlePageAService extends TitleService {
  @override
  String get path => "/home/title/pageA";

  @override
  String get text => "Page A title";
}

class TitleService extends TextService {
  @override
  String get path => "/home/title";

  @override
  String get text => "Test title";
}

abstract class TextService {
  String get path;

  String get text;
}

class RedUiModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle<ThemeGenerator>(RedThemeGenerator());
  }
}

class UiModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle(ThemeGenerator());
  }
}

class RedThemeGenerator extends ThemeGenerator {
  @override
  ThemeData updateTheme(ThemeData themeData) {
    var newTheme = themeData.copyWith(
      primaryColor: Colors.blue,
      accentColor: Colors.red,
      textTheme: themeData.textTheme
          .apply(displayColor: Colors.white, bodyColor: Colors.white),
    );
    return newTheme;
  }
}

class ThemeGenerator {
  ThemeData updateTheme(ThemeData themeData) {
    return themeData;
  }
}
