import 'package:dime/dime.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/widgets.dart';

/// Wraps a [child] with Dime scope implementation.
/// Also cleans up the scope on [dispose]
class DimeScopeFlutter extends StatefulWidget {
  final Widget child;
  final String scopeName;
  final List<BaseDimeModule> modules;

  /// Wraps [child] with a scope by [scopeName] and defined [modules]
  DimeScopeFlutter(
      {Key key, this.scopeName, this.child, this.modules = const []})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DimeScopeFlutterState();
  }
}

class _DimeScopeFlutterState extends State<DimeScopeFlutter> {
  DimeScope scope;

  @override
  void initState() {
    super.initState();
    scope = dimeOpenScope(widget.scopeName);
    for (var module in widget.modules) {
      scope.installModule(module);
    }
  }

  @override
  void dispose() {
    dimeCloseScope(scope: scope);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DimeFlutter(scope, child: widget.child);
  }
}

/// Provider of the current Dime Scope.
/// It will store in tree of widgets the scope opened. and with [scopeOf] will provide that scope
class DimeFlutter extends InheritedWidget {
  /// [DimeScope] that can be accessed from [child] widgets.
  final DimeScope scope;

  /// Creates DimeFlutter scope [InheritedWidget].
  DimeFlutter(this.scope, {Widget child}) : super(child: child);

  /// Checks if update should notify other widgets about change.
  /// For this checks if scope changed.
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    if (oldWidget is DimeFlutter) {
      return oldWidget.scope != scope;
    } else {
      return oldWidget != this;
    }
  }

  /// Provides DimeScope that was last defined in the Widget tree.
  static DimeScope scopeOf(BuildContext context) {
    var dimeFlutter = (context.inheritFromWidgetOfExactType(DimeFlutter));
    if (dimeFlutter != null) {
      return (dimeFlutter as DimeFlutter).scope;
    } else {
      Fimber.i("No scope - will return root scope.");
      return dimeRootScope;
    }
  }

  /// will get a type [T] from DimeScope in widget tree.
  static T get<T>(BuildContext context, {String tag}) {
    return scopeOf(context).get(tag: tag);
  }
}
