Create form easy and fast. Create fields once and use their many times

### Why field is not widget
Often, the application uses a single design forms, you once set up the topic and / or create your fields
And then you write only logic in the controller

## Getting started
To use this plugin, add `formaster` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

## Usage
```dart
    final product = Product(); // Abstract model

    final titleField = StringField(
      placeholder: 'Title',
      onSaved: (value) => product.title = value,
    );
    final priceField = DoubleField(
      placeholder: 'Price',
      onSaved: (value) => product.price = value,
    );

    final controller = FromController;
    
    FormWidget(
        controller: controller,
        body: FormColumnLayout([
            titleField,
            priceField,
        ]);,
    ),

    if(controller.save()) {
        // Great, you model filled!
    }

```

see `/example` for more case.

## Components 
Basic components that will suit most users

### Layout
- FormColumnLayout
- FormRowLayout
- FormWrapLayout

### Fields
- BoolField
- ChoiceField
- DoubleField
- IntField
- StringField

Fields used standart `ThemeData` and `FormThemeData` for additional data
In `/example/lib/fields` you will see example of custom fields