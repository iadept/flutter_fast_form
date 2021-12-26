library flutter_easy_form;

import 'package:formaster/form.dart';
import 'package:flutter/material.dart';

class DropdownField<T extends Object> extends FormFieldItem<T?> {
  final String placeholder;
  final List<T> items;
  final Widget Function(T value) itemBuilder;

  T? _value;

  T? get value => _value;
  set value(T? value) => _onChanged(value);

  DropdownField({
    Key? key,
    required this.items,
    required this.placeholder,
    required this.itemBuilder,
    T? initialValue,
    ValueChanged<T?>? onChanged,
    ValueChanged<T?>? onSaved,
    bool isActive = true,
    bool isDisabled = false,
  })  : _value = initialValue,
        super(
          key: key,
          onChanged: onChanged,
          onSaved: onSaved,
          isActive: isActive,
          isRequired: false,
          isDisabled: isDisabled,
          isValid: true,
        );
  @override
  Widget build(BuildContext context) {
    final theme = FormThemeData.of(context);
    return DropdownButtonFormField(
      key: key,
      value: _value,
      items: items
          .map((e) => DropdownMenuItem(
                child: itemBuilder(e),
                value: e,
              ))
          .toList(),
      onSaved: onSaved,
      onChanged: isDisabled ? null : onChanged ?? (_) {},
      validator: (value) {
        if (isRequired && value == null) {
          isValid = false;
          return theme.requiredText;
        }
        isValid = true;
        return null;
      },
      hint: Text(placeholder),
    );
  }

  void _onChanged(T? value) {
    if (isDisabled) return;
    setHasChanged(true);
    _value = value;
    if (onChanged != null) {
      onChanged!(value);
    }
    notifyListeners();
  }
}
