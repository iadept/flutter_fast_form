import 'package:formaster/form.dart';
import 'package:flutter/material.dart';

class FormWrapLayout extends FormLayout {
  final List<FormItem> items;
  final double spacing;
  final double runSpacing;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAlignment;

  FormWrapLayout(
    this.items, {
    bool isActive = true,
    EdgeInsets? margin,
    FormItemWrapper? wrapper,
    EdgeInsets? fieldMargin,
    this.spacing = 0,
    this.runSpacing = 0,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAlignment = WrapCrossAlignment.start,
  }) : super(
          isActive: isActive,
          margin: margin,
          wrapper: wrapper,
          fieldMargin: fieldMargin,
        );

  @override
  Widget build(BuildContext context) {
    final result = items.map((e) {
      return buildItem(context, e);
    });
    return Container(
      padding: margin,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        direction: direction,
        alignment: alignment,
        runAlignment: runAlignment,
        crossAxisAlignment: crossAlignment,
        children: result.toList(),
      ),
    );
  }
}

class FormColumnLayout extends FormLayout {
  final List<FormItem> items;

  FormColumnLayout(
    this.items, {
    bool isActive = true,
    EdgeInsets? margin,
    FormItemWrapper? wrapper,
    EdgeInsets? fieldMargin,
  }) : super(
          isActive: isActive,
          margin: margin,
          wrapper: wrapper,
          fieldMargin: fieldMargin,
        );

  @override
  Widget build(BuildContext context) {
    final result = items.map((e) {
      return buildItem(context, e);
    });
    return Container(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: result.toList(),
      ),
    );
  }
}

class FormRowLayout extends FormLayout {
  final List<FormItem> items;
  final Widget? separator;
  final MainAxisSize mainAxisSize;

  FormRowLayout(
    this.items, {
    bool isActive = true,
    EdgeInsets? margin,
    FormItemWrapper? wrapper,
    EdgeInsets? fieldMargin,
    this.mainAxisSize = MainAxisSize.min,
    this.separator,
  }) : super(
          isActive: isActive,
          margin: margin,
          wrapper: wrapper,
          fieldMargin: fieldMargin,
        );

  FormRowLayout.expanded(
    this.items, {
    bool isActive = true,
    EdgeInsets? margin,
    FormItemWrapper? wrapper,
    EdgeInsets? fieldMargin,
    this.separator,
  })  : mainAxisSize = MainAxisSize.max,
        super(
          isActive: isActive,
          margin: margin,
          wrapper: (item, child) {
            if (wrapper != null) {
              return Expanded(child: wrapper(item, child));
            }
            return Expanded(child: child);
          },
          fieldMargin: fieldMargin,
        );

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> result = items.map<Widget>((e) {
      return buildItem(context, e);
    });

    if (separator != null) {
      result = result.intersperse(separator!);
    }

    return Container(
      padding: margin,
      child: Row(
        mainAxisSize: mainAxisSize,
        children: result.toList(),
      ),
    );
  }
}

extension _IterableExtension<E> on Iterable<E> {
  Iterable<E> intersperse(
    E element, {
    bool first = false,
    bool last = false,
  }) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      if (first) yield element;
      yield iterator.current;
      while (iterator.moveNext()) {
        yield element;
        yield iterator.current;
      }
      if (last) yield element;
    }
  }
}
