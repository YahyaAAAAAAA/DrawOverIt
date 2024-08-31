import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  MenuButton({
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
    return PopupMenuButton(
      icon: Icon(
        icon,
        size: size,
        color: color,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(bgColor),
      ),
      color: bgColor,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 20),
      constraints: const BoxConstraints.tightFor(width: 50),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: color,
              ),
            ),
          ),
          PopupMenuItem(
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: color,
              ),
            ),
          ),
          PopupMenuItem(
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: color,
              ),
            ),
          ),
        ];
      },
    );
  }
}
