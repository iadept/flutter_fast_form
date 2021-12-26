import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool hasError;
  final TextStyle? textStyle;

  const PlaceholderWidget({
    Key? key,
    required this.label,
    this.isRequired = false,
    this.hasError = false,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 4),
        if (isRequired)
          Text(
            '*',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
