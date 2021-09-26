library formaster;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

part 'widget/helper.dart';

abstract class FormItem extends ChangeNotifier {
  final EdgeInsets? margin;

  bool get isActive => _isActive;
  set isActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  bool _isActive;

  /// [isActive] show item on form
  FormItem({
    bool isActive = true,
    this.margin,
  }) : _isActive = isActive;

  Widget build(BuildContext context);

  void disposeWidget() {}
}

class FormCustomItem extends FormItem {
  final Widget child;

  FormCustomItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

typedef FormItemWrapper = Widget Function(FormItem item, Widget child);

abstract class FormLayout extends FormItem {

  final FormItemWrapper? wrapper;
  final EdgeInsets? fieldMargin;

  FormLayout({
    bool isActive = true,
    EdgeInsets? margin,
    this.wrapper,
    this.fieldMargin,
  }) : super(
          isActive: isActive,
          margin: margin,
        );

  @nonVirtual
  Widget buildItem(BuildContext context, FormItem item) {
    return ChangeNotifierProvider<FormItem>(
      create: (_) => item,
      builder: (context, _) => context.select((FormItem item) {
        _FormScope.of(context)?.controller._register(item);
        if (item._isActive) {
          Widget child = item.build(context);
          if (wrapper != null) {
            child = wrapper!(item, item.build(context));
          }
          final margin = item.margin ?? fieldMargin;
          if (margin != null) {
            child = Padding(
              padding: margin,
              child: child,
            );
          }
          return child;
        }
        return Container();
      }),
    );
  }
}

abstract class FormFieldItem<T> extends FormItem {
  final focusNode = FocusNode();
  final Key? key;

  ValueChanged<T>? onChanged;
  ValueChanged<T>? onSaved;

  final bool isRequired;

  /// Custom required text, by default [FormThemeData.requiredText]
  final String? requiredText;

  @protected
  bool isValid;
  bool get hasChanges => _hasChanges;
  bool get isDisabled => _isDisabled;

  bool _isDisabled;
  bool _hasChanges = false;

  /// Base for create form field
  FormFieldItem({
    this.key,
    required this.onChanged,
    required this.onSaved,
    bool isActive = true,
    required this.isRequired,
    this.requiredText,
    bool isDisabled = false,
    this.isValid = true,
  })  : _isDisabled = isDisabled,
        super(isActive: isActive);

  @nonVirtual
  void setHasChanged(bool value) {
    _hasChanges = value;
  }

  @nonVirtual
  void setDisabled(bool value) {
    _isDisabled = value;
    notifyListeners();
  }

  @override
  @mustCallSuper
  void disposeWidget() {
    focusNode.dispose();
    super.disposeWidget();
  }
}

class FormController {
  final _formKey = GlobalKey<FormState>();
  final _items = <FormItem>{};

  Iterable<FormFieldItem> get _fields => _items.whereType<FormFieldItem>();

  bool get hasChanges => _fields.any((e) => e._hasChanges);

  FormFieldItem? get firstInvalid => _fields.firstWhereOrNull(
        (e) => !e.isValid && e.isActive,
      );

  bool validate() => _formKey.currentState?.validate() == true;

  /// [scrollToInvalid] scroll to invalid field on error
  bool save({bool scrollToInvalid = true}) {
    if (validate()) {
      _formKey.currentState?.save();
      return true;
    }
    if (scrollToInvalid) {
      final invalidField = _items
          .whereType<FormFieldItem>()
          .firstWhereOrNull((e) => !e.isValid)
          ?.focusNode;
      if (invalidField != null) {
        invalidField.requestFocus();
      }
    }
    return false;
  }

  void _register(FormItem item) {
    _items.add(item);
  }

  void dispose() {
    for (var e in _items) {
      e.disposeWidget();
    }
  }
}

class FormThemeData {
  final String? requiredText;
  final bool showRequired;
  final Widget? clearIcon;

  FormThemeData({
    this.requiredText = 'This field is required',
    this.showRequired = true,
    this.clearIcon,
  });

  static FormThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FormTheme>()?.data ??
        FormThemeData();
  }

  FormThemeData copyWith({
    String? requiredText,
    bool? showRequired,
    Widget? clearIcon,
  }) =>
      FormThemeData(
        requiredText: requiredText ?? this.requiredText,
        showRequired: showRequired ?? this.showRequired,
        clearIcon: clearIcon ?? this.clearIcon,
      );
}

class FormTheme extends InheritedWidget {
  final FormThemeData data;

  const FormTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant FormTheme oldWidget) {
    return data.hashCode != oldWidget.data.hashCode;
  }
}

class FormWidget extends StatelessWidget {
  final FormController controller;
  final FormLayout body;

  const FormWidget({
    Key? key,
    required this.controller,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _FormScope(
      controller,
      child: Form(
        key: controller._formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: body.build(context),
      ),
    );
  }
}
