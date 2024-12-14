import 'package:flutter/material.dart';

class MenuColorButton extends StatelessWidget {
  const MenuColorButton({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.size,
    required this.value,
    this.onSelected,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;
  final int value;
  final void Function(int)? onSelected;

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
      initialValue: value,
      tooltip: '',
      popUpAnimationStyle:
          AnimationStyle(duration: const Duration(milliseconds: 200)),
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 0,
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.blue,
              ),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.yellow,
              ),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.red,
              ),
            ),
          ),
          PopupMenuItem(
            value: 3,
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.green,
              ),
            ),
          ),
          PopupMenuItem(
            value: 4,
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.white,
              ),
            ),
          ),
        ];
      },
    );
  }
}
