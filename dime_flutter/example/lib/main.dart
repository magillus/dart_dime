import 'package:dime_flutter/dime_flutter.dart';
import 'package:flutter/material.dart';

import 'di.dart';

void main(List<String> args) {
  runApp(DimeApp());
}

class DimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DimeScopeFlutter(
      scopeName: "myroot",
      modules: [
        ServiceModule(),
        UiModule(),
      ],
      child: MaterialApp(
        title: "Dime test App",
        theme: Theme.of(context).copyWith(primaryColor: Colors.amber),
        initialRoute: "/",
        routes: {"/": (ctx) => HomePage(), "/A": (_) => TestAPageScope()},
      ),
    );
  }
}

AppBar provideAppBar(BuildContext context) {
  var title = DimeFlutter.get<TitleService>(context).text;
  // it is better to wrap it with Theme object
  return AppBar(
    title: Text(title),
  );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme =
        DimeFlutter.get<ThemeGenerator>(context).updateTheme(Theme.of(context));
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: provideAppBar(context),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Home Page"),
              ElevatedButton(
                child: Text("PAGE A"),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TestAPageScope()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TestAPageScope extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DimeScopeFlutter(
        scopeName: "test-a",
        modules: [RedUiModule()..addSingle<TitleService>(TitlePageAService())],
        child: TestAPage());
  }
}

class TestAPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme =
        DimeFlutter.get<ThemeGenerator>(context).updateTheme(Theme.of(context));
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: provideAppBar(context),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Test Page A"),
              ElevatedButton(
                child: Text("PAGE A 1"),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
