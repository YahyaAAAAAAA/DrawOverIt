import 'dart:async';
import 'dart:io';
import 'package:easy_draggable/easy_draggable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:test_1/components/menu_button.dart';
import 'package:test_1/components/panel_icon.dart';
import 'package:test_1/utils/custom_icons_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:window_manager/window_manager.dart';

const _kIconTypeOriginal = 'original';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  String _iconType = _kIconTypeOriginal;
  Menu? _menu;
  late WhiteBoardController whiteBoardController;
  double buttonWidth = 40;
  double buttonHeight = 40;
  double gapWidth = 10;
  double strokeW = 4;
  Color strokeC = Colors.yellow;
  bool erase = false;
  Color black = const Color(0xFF30333A);
  Color black2 = const Color.fromARGB(255, 38, 40, 46);
  Color gray = const Color(0xFF8C8C8E);
  Color white = const Color(0xFFFFFFFF);

  @override
  void initState() {
    //tray listener, icon and menu setup
    trayManager.addListener(this);
    _handleSetIcon(_iconType);
    _setContextMenu();

    //make window transparent
    Window.setEffect(effect: WindowEffect.transparent);

    //white board controller
    whiteBoardController = WhiteBoardController();

    //maximize screen
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await windowManager.maximize();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  Future<void> _handleSetIcon(String iconType) async {
    _iconType = iconType;
    String iconPath =
        Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png';

    if (_iconType == 'original') {
      iconPath = Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png';
    }

    await trayManager.setIcon(iconPath);
  }

  void _setContextMenu() async {
    _menu ??= Menu(
      items: [
        MenuItem(
          label: 'Look Up "LeanFlutter"',
        ),
        MenuItem(
          label: 'Search with Google',
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Cut',
        ),
        MenuItem(
          label: 'Copy',
        ),
        MenuItem(
          label: 'Paste',
          disabled: true,
        ),
        MenuItem.submenu(
          label: 'Share',
          submenu: Menu(
            items: [
              MenuItem.checkbox(
                label: 'Item 1',
                checked: true,
                onClick: (menuItem) {
                  if (kDebugMode) {
                    print('click item 1');
                  }
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
              MenuItem.checkbox(
                label: 'Item 2',
                checked: false,
                onClick: (menuItem) {
                  if (kDebugMode) {
                    print('click item 2');
                  }
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
            ],
          ),
        ),
        MenuItem.separator(),
        MenuItem.submenu(
          label: 'Font',
          submenu: Menu(
            items: [
              MenuItem.checkbox(
                label: 'Item 1',
                checked: true,
                onClick: (menuItem) {
                  if (kDebugMode) {
                    print('click item 1');
                  }
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
              MenuItem.checkbox(
                label: 'Item 2',
                checked: false,
                onClick: (menuItem) {
                  if (kDebugMode) {
                    print('click item 2');
                  }
                  menuItem.checked = !(menuItem.checked == true);
                },
              ),
              MenuItem.separator(),
              MenuItem(
                label: 'Item 3',
                checked: false,
              ),
              MenuItem(
                label: 'Item 4',
                checked: false,
              ),
              MenuItem(
                label: 'Item 5',
                checked: false,
              ),
            ],
          ),
        ),
        MenuItem.submenu(
          label: 'Speech',
          submenu: Menu(
            items: [
              MenuItem(
                label: 'Item 1',
              ),
              MenuItem(
                label: 'Item 2',
              ),
            ],
          ),
        ),
      ],
    );
    await trayManager.setContextMenu(_menu!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          //whiteboard
          WhiteBoard(
            backgroundColor: Colors.transparent,
            controller: whiteBoardController,
            strokeWidth: strokeW,
            isErasing: erase,
            strokeColor: strokeC,
          ),
          //controlling panel
          EasyDraggableWidget(
            floatingBuilder: (context, constraints) => Container(
              width: 400,
              // height: 220,
              decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  topRow(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuButton(
                          icon: Icons.circle,
                          onPressed: () {},
                          color: strokeC,
                          bgColor: black2,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        PanelIcon(
                          icon: CustomIcons.line_width,
                          onPressed: () {},
                          color: gray,
                          bgColor: black2,
                          size: 15,
                        ),
                        const SizedBox(width: 10),
                        PanelIcon(
                          icon: CustomIcons.eraser,
                          onPressed: () {
                            setState(() {
                              erase = !erase;
                            });
                          },
                          color: gray,
                          bgColor: black2,
                          size: 15,
                        ),
                        const SizedBox(width: 10),
                        PanelIcon(
                          icon: CustomIcons.undo,
                          onPressed: () {
                            whiteBoardController.undo();
                          },
                          color: gray,
                          bgColor: black2,
                          size: 15,
                        ),
                        const SizedBox(width: 10),
                        PanelIcon(
                          icon: CustomIcons.settings,
                          onPressed: () {},
                          color: gray,
                          bgColor: black2,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topRow() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 400,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gray,
            width: 0.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text(
              'Draw Over It',
              style: TextStyle(
                color: gray,
                fontFamily: 'Play',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 190,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.horizontal_rule,
                size: 20,
                color: gray,
              ),
            ),
            IconButton(
              onPressed: () {
                windowManager.hide();
                whiteBoardController.clear();
              },
              icon: Icon(
                Icons.close,
                size: 20,
                color: gray,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    if (kDebugMode) {
      print('onTrayIconMouseDown');
    }
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    if (kDebugMode) {
      print('onTrayIconRightMouseDown');
    }
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (kDebugMode) {
      print(menuItem.toJson());
    }
  }
}
