library flutter_easy_form;

import 'dart:async';

import 'package:formaster/form.dart';
import 'package:formaster/widget/placeholder.dart';
import 'package:flutter/material.dart';

typedef ChoiceCallback<T> = FutureOr<T> Function(
  BuildContext context,
  T value,
);

class ChoiceAction<T> {
  final Widget child;
  final ChoiceCallback<T> onTap;

  ChoiceAction({required this.child, required this.onTap});
}

class ChoiceField<T> extends FormFieldItem<T?> {
  final String placeholder;
  final ChoiceCallback<T?> onTap;
  final Widget Function(T value) builder;
  final ChoiceAction<T>? action;
  final bool? hasClearIcon;

  set value(T? value) => _onChanged(value);
  T? get value => _value;

  T? _value;
  FormFieldState<T>? _state;

  /// Base for create choice field
  /// [hasClearIcon] show clear button from [FormThemeData.clearIcon]
  /// [requiredText] replace default value from [FormThemeData.requiredText]
  ChoiceField({
    Key? key,
    required this.placeholder,
    T? initialValue,
    required this.onTap,
    required this.builder,
    ValueChanged<T?>? onChanged,
    ValueChanged<T?>? onSaved,
    bool isActive = true,
    bool isRequired = true,
    String? requiredText,
    bool isDisabled = false,
    this.hasClearIcon = true,
    this.action,
  })  : _value = initialValue,
        super(
          key: key,
          onChanged: onChanged,
          onSaved: onSaved,
          isActive: isActive,
          isRequired: isRequired,
          requiredText: requiredText,
          isDisabled: isDisabled,
        );

  @override
  Widget build(BuildContext context) {
    final theme = FormThemeData.of(context);
    return FormField<T>(
      builder: (state) {
        _state = state;
        return _buildField(context, state, theme.clearIcon);
      },
      onSaved: (value) {
        setHasChanged(false);
        if (onSaved != null) {
          onSaved!(value);
        }
      },
      validator: (value) {
        if (isRequired && value == null) {
          isValid = false;
          return theme.requiredText;
        }
        isValid = true;
        return null;
      },
      initialValue: _value,
      enabled: !isDisabled,
    );
  }

  Widget _buildField(
    BuildContext context,
    FormFieldState<T> state,
    Widget? clearIcon,
  ) {
    final field = GestureDetector(
      onTap: () => _onTap(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 58),
        child: Container(
            key: key,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InputDecorator(
              decoration: InputDecoration(
                errorText: state.errorText,
                label: PlaceholderWidget(
                  label: placeholder,
                  isRequired: isRequired,
                  textStyle:
                      Theme.of(context).inputDecorationTheme.floatingLabelStyle,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              child: _buildValue(state.value, clearIcon),
              isEmpty: state.value == null,
            )
            //       child: _buildFieldContent(context, state),
            ),
      ),
    );

    return Focus(
      focusNode: focusNode,
      onFocusChange: (focus) async {
        if (focus && state.value == null) {
          await _onTap(context);
        } else {
          FocusScope.of(state.context).nextFocus();
        }
      },
      child: field,
    );
  }

  Widget _buildValue(T? value, Widget? clearIcon) {
    if (value != null) {
      return Row(
        children: [
          Expanded(child: builder(value)),
          if (clearIcon != null)
            GestureDetector(
              onTap: () {
                _onChanged(null);
              },
              child: clearIcon,
            )
        ],
      );
    }
    return const Text('');
  }

  Future<void> _onTap(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final value = await onTap(context, _value);
    _onChanged(value);
  }

  void _onChanged(T? newValue) {
    if (_value == newValue) return;
    setHasChanged(true);

    _value = newValue;
    if (_state?.mounted == true) {
      _state?.didChange(_value);
    }
    if (onChanged != null) {
      onChanged!(_value);
    }
  }
}
