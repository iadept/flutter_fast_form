import 'package:flutter/foundation.dart';
import 'package:formaster/field/choice.dart';
import 'package:formaster/form.dart';
import 'package:flutter/material.dart';

/// Examples of custom field

class ValueItem extends FormItem {
  String _value;

  set value(String value) {
    _value = value;
    notifyListeners();
  }

  ValueItem(String initialValue)
      : _value = initialValue,
        super(isActive: true);

  @override
  Widget build(BuildContext context) {
    return Text(_value);
  }
}

class DateField extends ChoiceField<DateTime?> {
  DateField({
    required String placeholder,
    ValueChanged<DateTime?>? onChanged,
    ValueChanged<DateTime?>? onSaved,
  }) : super(
          placeholder: placeholder,
          initialValue: null,
          onTap: (context, lastValue) async {
            final result = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            return result ?? lastValue;
          },
          builder: (date) => Text(date.toString()),
          onChanged: onChanged,
          onSaved: onSaved,
        );
}

enum ColorVariant { red, green, blue }

extension _ColorVariantExtension on ColorVariant {
  String get title => describeEnum(this);

  Color get color {
    switch (this) {
      case ColorVariant.blue:
        return Colors.blue;
      case ColorVariant.green:
        return Colors.green;
      case ColorVariant.red:
        return Colors.red;
    }
  }

  Widget get widget => Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      );
}

class ColorField extends ChoiceField<ColorVariant> {
  ColorField({
    required String placeholder,
    ValueChanged<ColorVariant?>? onChanged,
    ValueChanged<ColorVariant?>? onSaved,
  }) : super(
          placeholder: placeholder,
          initialValue: ColorVariant.red,
          onTap: (context, lastValue) async {
            final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ColorVariant.values.map((e) {
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pop(e),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: e.widget,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                });
            return result ?? lastValue;
          },
          builder: (color) => color.widget,
          onChanged: onChanged,
          onSaved: onSaved,
        );
}
