part of '../form.dart';

class _FormScope extends InheritedWidget {
  final FormController controller;

  const _FormScope(
    this.controller, {
    required Widget child,
  }) : super(child: child);

  static _FormScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FormScope>();
  }

  @override
  bool updateShouldNotify(_FormScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
