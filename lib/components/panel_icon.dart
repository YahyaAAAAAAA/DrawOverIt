import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PanelIcon extends StatelessWidget {
  PanelIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.bgColor,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;
  void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        iconSize: size,
        color: color,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(bgColor),
          elevation: const WidgetStatePropertyAll(1),
          shadowColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 26, 27, 32)),
        ),
        icon: Icon(icon));
  }
}
