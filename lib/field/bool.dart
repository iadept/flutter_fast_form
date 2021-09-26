library flutter_easy_form;

import 'package:formaster/form.dart';
import 'package:flutter/material.dart';

class BoolField extends FormFieldItem<bool> {
  final String placeholder;

  BoolFieldContentBuilder builder;

  bool _value;
  FormFieldState<bool>? _state;

  bool get value => _value;
  set value(bool value) => _onChanged(value);

  BoolField({
    Key? key,
    required this.placeholder,
    required this.builder,
    bool initialValue = false,
    ValueChanged<bool>? onChanged,
    ValueChanged<bool>? onSaved,
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

  BoolField.checkbox({
    Key? key,
    required this.placeholder,
    bool initialValue = false,
    ValueChanged<bool>? onChanged,
    ValueChanged<bool>? onSaved,
    bool isActive = true,
    bool isDisabled = false,
  })  : builder = _buildCheckbox,
        _value = initialValue,
        super(
          key: key,
          onChanged: onChanged,
          onSaved: onSaved,
          isActive: isActive,
          isRequired: false,
          isDisabled: isDisabled,
          isValid: true,
        );

  BoolField.switchbox({
    Key? key,
    required this.placeholder,
    bool initialValue = false,
    ValueChanged<bool>? onChanged,
    ValueChanged<bool>? onSaved,
    bool isActive = true,
    bool isDisabled = false,
  })  : builder = _buildSwitch,
        _value = initialValue,
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
    return FormField<bool>(
      initialValue: _value,
      builder: (FormFieldState<bool> state) {
        _state = state;
        return GestureDetector(
          key: key,
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _onChanged(!_value);
          },
          child: builder(placeholder, _value, _onChanged),
        );
      },
      onSaved: (dynamic value) {
        setHasChanged(false);
        if (onSaved != null) {
          onSaved!(value);
        }
      },
    );
  }

  void _onChanged(bool value) {
    if (isDisabled) return;
    setHasChanged(true);
    _value = value;
    _state?.didChange(value);
    if (onChanged != null) {
      onChanged!(value);
    }
  }
}

typedef BoolFieldContentBuilder = Widget Function(
  String placeholder,
  bool value,
  ValueChanged<bool> onChanged,
);

Widget _buildCheckbox(
    String placeholder, bool value, ValueChanged<bool> onChanged) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
              value: value,
              onChanged: (_) {
                onChanged(!value);
              }),
        ),
      ),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(placeholder, maxLines: 1),
      )),
    ],
  );
}

Widget _buildSwitch(
    String placeholder, bool value, ValueChanged<bool> onChanged) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(placeholder, maxLines: 1),
      )),
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: Switch(
              value: value,
              onChanged: (_) {
                onChanged(!value);
              }),
        ),
      ),
    ],
  );
}
