import 'package:dime_flutter/dime_flutter.dart';
import 'package:dime_flutter/flutter_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const title = "TITLE";

void main() {
  testWidgets("Test scope widget", (widgetTester) async {
    dimeInstall(StringModule());
    final testWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: DimeScopeFlutter(
        child: TitleView(),
        modules: [StringScopedModule()],
      ),
    );

    await widgetTester.pumpWidget(testWidget);

    await widgetTester.ensureVisible(find.text("Scoped title"));
  });
}

class StringModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle<String>("Main title");
  }
}

class StringScopedModule extends BaseDimeModule {
  @override
  void updateInjections() {
    addSingle<String>("Scoped title");
  }
}

class TitleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scope = DimeFlutter.scopeOf(context);
    final titleText = scope.get();
    return Text(titleText);
  }
}
