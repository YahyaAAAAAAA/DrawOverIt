import 'package:easy_draggable/easy_draggable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:test_1/components/menu_button_color.dart';
import 'package:test_1/components/menu_button_width.dart';
import 'package:test_1/components/panel_icon.dart';
import 'package:test_1/utils/custom_icons_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  Menu? _menu;
  late WhiteBoardController whiteBoardController;
  late WhiteBoardController floatingBoardController;
  late HotKey hotKey;
  double buttonWidth = 40;
  double buttonHeight = 40;
  double gapWidth = 10;
  double strokeW = 4;
  double initStrokeW = 4;
  Color strokeC = Colors.blue;
  String colorValue = "blue";
  bool erase = false;
  bool panelSwitch = false;
  bool floatingSwitch = true;
  Color black = const Color(0xFF30333A);
  Color topRowColor = const Color(0xFF2B2E34);
  Color shadowColor = const Color.fromARGB(255, 38, 40, 46);
  Color gray = const Color(0xFF8C8C8E); //#1a1a1a
  Color white = const Color(0xFFFFFFFF);

  @override
  void initState() {
    //tray listener, icon and menu setup
    trayManager.addListener(this);
    _setContextMenu();

    //make window transparent
    Window.setEffect(effect: WindowEffect.transparent);

    //white board controller
    whiteBoardController = WhiteBoardController();
    floatingBoardController = WhiteBoardController();

    //register hotkey (ALT+Q)
    hotKey = HotKey(
      key: PhysicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );

    //maximize screen
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        //make sure window fill the screen
        await windowManager.maximize();

        //set tray icon
        await trayManager.setIcon('assets/images/draw_icon.ico');

        //show/hide app when (ALT+Q) is pressed system wide .
        await hotKeyManager.register(
          hotKey,
          keyDownHandler: (hotKey) async {
            if (await windowManager.isVisible()) {
              await windowManager.minimize();
              await windowManager.hide();
              whiteBoardController.clear();
            } else {
              await windowManager.show();
            }
          },
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
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
        children: [
          //whiteboard
          WhiteBoard(
            backgroundColor: Colors.transparent,
            controller: whiteBoardController,
            strokeWidth: strokeW,
            isErasing: erase,
            strokeColor: strokeC,
          ),
          //floating board
          floatingBoard(),
          //controlling panel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: panelSwitch
                ? minimizedButton()
                : EasyDraggableWidget(
                    left: 100,
                    top: 200,
                    floatingBuilder: (context, constraints) => Container(
                      width: 400,
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
                                colorStrokeSelect(),
                                const SizedBox(width: 10),
                                widthStrokeSelect(),
                                const SizedBox(width: 10),
                                eraseButton(),
                                const SizedBox(width: 10),
                                undoButton(),
                                const SizedBox(width: 10),
                                floatingBoardButton(),
                                const SizedBox(width: 10),
                                settingsButton(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PanelIcon floatingBoardButton() {
    return PanelIcon(
      icon: Icons.border_color_rounded,
      onPressed: () {
        setState(() {
          floatingSwitch = !floatingSwitch;
        });
      },
      color: floatingSwitch ? gray : white,
      bgColor: shadowColor,
      size: 20,
    );
  }

  Widget floatingBoard() {
    return EasyDraggableWidget(
      left: floatingSwitch ? 3000 : 1000,
      top: 50,
      floatingBuilder: (context, constraints) {
        return Column(
          children: [
            Container(
              width: 500,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: gray,
                    width: 0.6,
                  ),
                ),
                color: topRowColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5),
                  Icon(
                    Icons.border_color_rounded,
                    color: gray,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Floating Board',
                    style: TextStyle(
                      color: gray,
                      fontFamily: 'Play',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 260),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        floatingBoardController.undo();
                      });
                    },
                    tooltip: 'Undo',
                    icon: Icon(
                      CustomIcons.undo,
                      size: 15,
                      color: gray,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        floatingSwitch = !floatingSwitch;
                      });
                    },
                    tooltip: 'Close Floating Board',
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: gray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 500,
              height: 400,
              decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(50),
              ),
              child: WhiteBoard(
                controller: floatingBoardController,
                backgroundColor: black,
                isErasing: erase,
                strokeColor: strokeC,
                strokeWidth: strokeW,
              ),
            ),
          ],
        );
      },
    );
  }

  Align minimizedButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 30),
        child: IconButton(
          onPressed: () {
            setState(() {
              panelSwitch = false;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(black),
            elevation: const WidgetStatePropertyAll(1),
            shadowColor:
                const WidgetStatePropertyAll(Color.fromARGB(255, 26, 27, 32)),
          ),
          padding: const EdgeInsets.all(10),
          icon: Icon(
            CustomIcons.draw_icon,
            color: gray,
            size: 45,
          ),
        ),
      ),
    );
  }

  PanelIcon settingsButton(BuildContext context) {
    return PanelIcon(
      icon: CustomIcons.settings,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: black,
              content: const Column(
                children: [
                  //TODO:
                  //1-add (remove stroke on close)
                  //2-add hotkey
                  //3-add show redo
                ],
              ),
            );
          },
        );
      },
      color: gray,
      bgColor: shadowColor,
      size: 15,
    );
  }

  PanelIcon undoButton() {
    return PanelIcon(
      icon: CustomIcons.undo,
      onPressed: () {
        whiteBoardController.undo();
      },
      color: gray,
      bgColor: shadowColor,
      size: 15,
    );
  }

  PanelIcon eraseButton() {
    return PanelIcon(
      icon: CustomIcons.eraser,
      onPressed: () {
        setState(() {
          erase = !erase;
          strokeW = erase ? 100 : initStrokeW;
        });
      },
      color: erase ? white : gray,
      bgColor: shadowColor,
      size: 15,
    );
  }

  MenuColorButton colorStrokeSelect() {
    return MenuColorButton(
      icon: Icons.circle,
      colorValue: colorValue,
      onTap1: () {
        setState(() {
          strokeC = Colors.blue;
          colorValue = "blue";
        });
      },
      onTap2: () {
        setState(() {
          strokeC = Colors.yellow;
          colorValue = "yellow";
        });
      },
      onTap3: () {
        setState(() {
          strokeC = Colors.red;
          colorValue = "red";
        });
      },
      onTap4: () {
        setState(() {
          strokeC = Colors.green;
          colorValue = "green";
        });
      },
      onTap5: () {
        setState(() {
          strokeC = Colors.white;
          colorValue = "white";
        });
      },
      color: strokeC,
      bgColor: shadowColor,
      size: 20,
    );
  }

  MenuButtonWidth widthStrokeSelect() {
    return MenuButtonWidth(
      icon: CustomIcons.line_width,
      widthValue: strokeW,
      onTap1: () {
        setState(() {
          strokeW = 2;
          initStrokeW = 2;
        });
      },
      onTap2: () {
        setState(() {
          strokeW = 4;
          initStrokeW = 4;
        });
      },
      onTap3: () {
        setState(() {
          strokeW = 6;
          initStrokeW = 6;
        });
      },
      color: gray,
      bgColor: shadowColor,
      size: 15,
    );
  }

  Widget topRow() {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        border: Border(
          bottom: BorderSide(
            color: gray,
            width: 0.3,
          ),
        ),
        color: topRowColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          Icon(
            CustomIcons.draw_icon,
            color: gray,
            // size: 30,
          ),
          const SizedBox(
            width: 2,
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
            width: 175,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                panelSwitch = true;
              });
            },
            tooltip: 'Minimize',
            icon: Icon(
              Icons.horizontal_rule,
              size: 20,
              color: gray,
            ),
          ),
          IconButton(
            onPressed: () async {
              await windowManager.minimize();
              await windowManager.hide();
              whiteBoardController.clear();
            },
            tooltip: 'Close To Background',
            icon: Icon(
              Icons.close,
              size: 20,
              color: gray,
            ),
          )
        ],
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
