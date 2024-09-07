import 'package:flutter/material.dart';
import 'package:test_1/utils/custom_colors.dart';

// ignore: must_be_immutable
class CustomCheckbox extends StatelessWidget {
  CustomCheckbox({
    super.key,
    required this.value,
    required this.title,
    required this.textStyle,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final TextStyle textStyle;
  void Function(bool?)? onChanged;
  CustomColors c = CustomColors();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(
            title,
            style: textStyle,
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: c.gray,
            checkColor: c.black,
            hoverColor: c.gray.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
