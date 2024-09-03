import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MenuColorButton extends StatelessWidget {
  MenuColorButton({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.size,
    required this.colorValue,
    required this.onTap1,
    required this.onTap2,
    required this.onTap3,
    required this.onTap4,
    required this.onTap5,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;
  final String colorValue;
  void Function()? onTap1;
  void Function()? onTap2;
  void Function()? onTap3;
  void Function()? onTap4;
  void Function()? onTap5;

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
      initialValue: colorValue,
      tooltip: '',
      popUpAnimationStyle:
          AnimationStyle(duration: const Duration(milliseconds: 200)),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: "blue",
            onTap: onTap1,
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.blue,
              ),
            ),
          ),
          PopupMenuItem(
            onTap: onTap2,
            value: "yellow",
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.yellow,
              ),
            ),
          ),
          PopupMenuItem(
            onTap: onTap3,
            value: "red",
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.red,
              ),
            ),
          ),
          PopupMenuItem(
            onTap: onTap4,
            value: "green",
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.green,
              ),
            ),
          ),
          PopupMenuItem(
            onTap: onTap5,
            value: "white",
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
