import 'dart:async';

import 'package:example/fields.dart';
import 'package:formaster/field/bool.dart';
import 'package:formaster/field/input.dart';
import 'package:formaster/form.dart';
import 'package:formaster/layout.dart';
import 'package:flutter/material.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State createState() => _ExampleState();
}

class _ExampleState extends State<ExampleScreen> {
  final _controller = StreamController<String>();
  final _formController = FormController();
  final _form = ExampleForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormWidget(
                controller: _formController,
                body: _form._formLayout,
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _form.reset();
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _formController.save();
                      _controller.sink.add(_form.model.toString());
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _form.add();
                      });
                    },
                    child: const Text('Add'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      _form.fromField.value = 3;
                    },
                    child: const Text('Test'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<String>(
                  stream: _controller.stream,
                  builder: (_, data) {
                    return Text(data.data ?? '');
                  })
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class ExampleModel {
  String? stringValue;
  bool boolValue = false;
  DateTime? dateValue;

  @override
  String toString() {
    return '$stringValue $boolValue $dateValue';
  }
}

class ExampleForm {
  final model = ExampleModel();

  late final StringField stringField;
  late final BoolField boolMainField;
  late final BoolField boolField;
  late final DateField dateField;
  late final DoubleField fromField;
  late final DoubleField toField;
  late final ColorField colorField;

  late FormLayout _formLayout;
  final _fields = <FormItem>[];

  ExampleForm() {
    stringField = StringField(
      placeholder: 'String field',
      initialValue: '123',
      onSaved: (value) {
        model.stringValue = value;
      },
      requiredText: "Custom required text",
      inputAction: TextInputAction.next,
      obscureText: true,
      suffix: _ShowPasswordButton(
        onTap: () {
          stringField.obscureText = !stringField.obscureText;
          return stringField.obscureText;
        },
      ),
    );

    boolField = BoolField.checkbox(
      placeholder: 'Boolean field',
      onChanged: (value) {
        stringField.obscureText = value;
      },
      onSaved: (value) {
        model.boolValue = value;
      },
      isActive: false,
    );

    final valueItem = ValueItem('Choice date');

    dateField = DateField(
        placeholder: 'Choice date',
        onChanged: (value) {
          valueItem.value = value.toString();
        },
        onSaved: (value) {
          model.dateValue = value;
        });

    boolMainField = BoolField.switchbox(
        placeholder: 'Test',
        onChanged: (value) {
          // stringField.isActive = value;
          boolField.isActive = value;
        },
        onSaved: (value) {});

    fromField = DoubleField(
      placeholder: 'From',
      onChanged: (value) {
        toField.constraint?.minValue = value;
      },
    );

    toField = DoubleField(
      placeholder: 'To',
      onChanged: (value) {
        fromField.constraint?.maxValue = value;
      },
    );

    colorField = ColorField(placeholder: 'Choice color');

    _formLayout = FormColumnLayout([
      boolMainField,
      stringField,
      boolField,
      dateField,
      FormRowLayout.expanded([
        fromField,
        toField,
      ], separator: const Text('-')),
      colorField,
      valueItem,
      FormColumnLayout(_fields),
    ]);
  }

  void add() {
    _fields.add(
      BoolField.switchbox(
        placeholder: 'Test',
        onChanged: (value) {},
        onSaved: (value) {},
      ),
    );
  }

  void reset() {
    boolMainField.value = false;
    stringField.value = '';
    boolField.value = false;
    dateField.value = null;
  }
}

class _ShowPasswordButton extends StatefulWidget {
  final bool Function() onTap;

  const _ShowPasswordButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  _ShowPasswordButtonState createState() => _ShowPasswordButtonState();
}

class _ShowPasswordButtonState extends State<_ShowPasswordButton> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
          _isVisible ? Icons.remove_red_eye_rounded : Icons.security_outlined),
      onTap: () {
        setState(() {
          _isVisible = widget.onTap();
        });
      },
    );
  }
}
