library flutter_easy_form;

import 'package:formaster/form.dart';
import 'package:formaster/widget/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class InputField<T> extends FormFieldItem<T?> {
  final String placeholder;
  final String? helperText;

  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? inputAction;

  FormFieldValidator<T>? validator;
  List<TextInputFormatter>? formatters;
  final bool emitDirty;

  final bool enableSuggestions;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final VoidCallback? onSubmit;

  TextEditingController? _controller;
  bool _obscureText;
  Widget? _suffix;
  T? _value;

  bool get obscureText => _obscureText;
  set obscureText(bool value) {
    _obscureText = value;
    notifyListeners();
  }

  set suffix(Widget? value) {
    _suffix = value;
    notifyListeners();
  }

  T? get value => _value;

  set value(T? newValue) {
    final formattedValue = _format(convertTo(value) ?? '');
    _controller?.text = formattedValue;
    _onChanged(newValue);
  }

  InputField({
    Key? key,
    required this.placeholder,
    ValueChanged<T?>? onChanged,
    ValueChanged<T?>? onSaved,
    this.helperText,
    this.minLines = 1,
    this.maxLines = 1,
    this.onSubmit,
    this.validator,
    bool isRequired = true,
    String? requiredText,
    T? initialValue,
    this.formatters,
    this.keyboardType,
    this.inputAction,
    bool isActive = true,
    bool isDisabled = false,
    this.emitDirty = true,
    bool obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.autofillHints,
    Widget? suffix,
  })  : _value = initialValue,
        _obscureText = obscureText,
        _suffix = suffix,
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
  void disposeWidget() {
    _controller?.dispose();
    super.disposeWidget();
  }

  @override
  Widget build(BuildContext context) {
    _controller = TextEditingController(text: _format(convertTo(_value) ?? ''));

    final theme = FormThemeData.of(context);
    final child = TextFormField(
      key: key,
      focusNode: focusNode,
      controller: _controller,
      decoration: InputDecoration(
        label: PlaceholderWidget(
          label: placeholder,
          isRequired: isRequired && theme.showRequired,
        ),
        helperText: helperText,
        errorStyle: theme.requiredText?.isNotEmpty == true
            ? null
            : const TextStyle(height: 0),
        suffixIcon: _suffix,
      ),
      validator: (e) {
        final value = convertFrom(e);
        if (isRequired && value == null) {
          isValid = false;
          return requiredText ?? theme.requiredText;
        }
        final result = validator == null ? null : validator!(value);
        isValid = result == null;
        if (onChanged != null && !emitDirty) {
          onChanged!(_value);
        }
        return result;
      },
      onChanged: (value) {
        _onChanged(convertFrom(value));
      },
      onSaved: (value) {
        setHasChanged(false);
        if (onSaved != null) {
          onSaved!(_value);
        }
      },
      onFieldSubmitted: (_) {
        if (onSubmit != null) {
          onSubmit!();
        }
      },
      readOnly: isDisabled,
      inputFormatters: formatters ?? [],
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: inputAction,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      obscureText: _obscureText,
      autofillHints: autofillHints,
    );
    return child;
  }

  String? convertTo(T? value) => value?.toString();

  /// On empty string this function should return null
  T? convertFrom(String? value);

  String _format(String value) {
    String result = value;
    formatters?.forEach((formatter) {
      result = formatter
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: result),
          )
          .text;
    });

    return result;
  }

  void _onChanged(T? newValue) {
    setHasChanged(true);
    _value = newValue;
    if (onChanged != null && emitDirty) {
      onChanged!(_value);
    }
  }
}

class StringField extends InputField<String> {
  StringField({
    Key? key,
    required String placeholder,
    ValueChanged<String?>? onChanged,
    ValueChanged<String?>? onSaved,
    String? helperText,
    int minLines = 1,
    int maxLines = 1,
    VoidCallback? onSubmit,
    FormFieldValidator<String>? validator,
    bool isRequired = true,
    String? requiredText,
    String? initialValue,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    TextInputAction? inputAction,
    bool isActive = true,
    bool isDisabled = false,
    bool emitDirty = true,
    bool obscureText = false,
    bool enableSuggestions = true,
    bool autocorrect = true,
    Iterable<String>? autofillHints,
    Widget? suffix,
  }) : super(
          key: key,
          placeholder: placeholder,
          onChanged: onChanged,
          onSaved: onSaved,
          helperText: helperText,
          minLines: minLines,
          maxLines: maxLines,
          onSubmit: onSubmit,
          validator: validator,
          isRequired: isRequired,
          requiredText: requiredText,
          initialValue: initialValue,
          formatters: formatters,
          keyboardType: keyboardType,
          inputAction: inputAction,
          isActive: isActive,
          isDisabled: isDisabled,
          emitDirty: emitDirty,
          obscureText: obscureText,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          autofillHints: autofillHints,
          suffix: suffix,
        );

  @override
  String? convertFrom(String? value) => value;
}

class NumberFieldConstraint<T extends num> {
  T? minValue;
  T? maxValue;

  NumberFieldConstraint({
    this.minValue,
    this.maxValue,
  });

  String? validate(T? value) {
    if (value == null) return null;
    if (minValue != null && value < minValue!) {
      return 'Min value: $minValue';
    }
    if (maxValue != null && value > maxValue!) {
      return 'Max value: $maxValue';
    }
  }
}

class IntField extends InputField<int> {
  final NumberFieldConstraint<int>? constraint;

  IntField({
    Key? key,
    required String placeholder,
    ValueChanged<int?>? onChanged,
    ValueChanged<int?>? onSaved,
    String? helperText,
    VoidCallback? onSubmit,
    this.constraint,
    bool isRequired = true,
    String? requiredText,
    int? initialValue,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    TextInputAction? inputAction,
    bool isActive = true,
    bool isDisabled = false,
    bool emitDirty = true,
    bool obscureText = false,
    bool enableSuggestions = true,
    bool autocorrect = true,
    Iterable<String>? autofillHints,
    Widget? suffix,
  }) : super(
          key: key,
          placeholder: placeholder,
          onChanged: onChanged,
          onSaved: onSaved,
          helperText: helperText,
          onSubmit: onSubmit,
          validator: constraint?.validate,
          isRequired: isRequired,
          requiredText: requiredText,
          initialValue: initialValue,
          formatters: formatters = <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'\d')),
            ...(formatters ?? []),
          ],
          keyboardType: TextInputType.numberWithOptions(
            signed: constraint?.minValue?.sign == -1,
            decimal: false,
          ),
          inputAction: inputAction,
          isActive: isActive,
          isDisabled: isDisabled,
          emitDirty: emitDirty,
          obscureText: obscureText,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          autofillHints: autofillHints,
          suffix: suffix,
        );

  @override
  int? convertFrom(String? value) => int.tryParse(value ?? '');

  @override
  String? convertTo(int? value) => value?.toString();
}

class DoubleField extends InputField<double> {
  final NumberFieldConstraint<double>? constraint;

  DoubleField({
    Key? key,
    required String placeholder,
    ValueChanged<double?>? onChanged,
    ValueChanged<double?>? onSaved,
    String? helperText,
    VoidCallback? onSubmit,
    this.constraint,
    bool isRequired = true,
    String? requiredText,
    double? initialValue,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    TextInputAction? inputAction,
    bool isActive = true,
    bool isDisabled = false,
    bool emitDirty = true,
    bool obscureText = false,
    bool enableSuggestions = true,
    bool autocorrect = true,
    Iterable<String>? autofillHints,
    Widget? suffix,
  }) : super(
          key: key,
          placeholder: placeholder,
          onChanged: onChanged,
          onSaved: onSaved,
          helperText: helperText,
          onSubmit: onSubmit,
          validator: constraint?.validate,
          isRequired: isRequired,
          requiredText: requiredText,
          initialValue: initialValue,
          formatters: formatters = <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
            ...(formatters ?? []),
          ],
          keyboardType: TextInputType.numberWithOptions(
            signed: constraint?.minValue?.sign == -1,
            decimal: false,
          ),
          inputAction: inputAction,
          isActive: isActive,
          isDisabled: isDisabled,
          emitDirty: emitDirty,
          obscureText: obscureText,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          autofillHints: autofillHints,
          suffix: suffix,
        );

  @override
  double? convertFrom(String? value) => double.tryParse(value ?? '');

  @override
  String? convertTo(double? value) => value?.toString();
}
