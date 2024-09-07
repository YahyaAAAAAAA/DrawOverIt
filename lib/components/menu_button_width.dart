import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MenuButtonWidth extends StatelessWidget {
  MenuButtonWidth({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.size,
    required this.widthValue,
    required this.onTap1,
    required this.onTap2,
    required this.onTap3,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;
  final double widthValue;
  void Function()? onTap1;
  void Function()? onTap2;
  void Function()? onTap3;

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
      initialValue: widthValue.toInt(),
      tooltip: '',
      popUpAnimationStyle:
          AnimationStyle(duration: const Duration(milliseconds: 200)),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 2,
            onTap: onTap1,
            child: Center(
              child: Divider(
                thickness: 2,
                color: color,
              ),
            ),
          ),
          PopupMenuItem(
            value: 4,
            onTap: onTap2,
            child: Center(
              child: Divider(
                thickness: 4,
                color: color,
              ),
            ),
          ),
          PopupMenuItem(
            onTap: onTap3,
            value: 10,
            child: Center(
              child: Divider(
                thickness: 10,
                color: color,
              ),
            ),
          ),
        ];
      },
    );
  }
}
