import 'package:DrawOverIt/components/draggable.dart';
import 'package:contactus/contactus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:DrawOverIt/components/custom_checkbox.dart';
import 'package:DrawOverIt/components/menu_button_color.dart';
import 'package:DrawOverIt/components/menu_button_width.dart';
import 'package:DrawOverIt/components/panel_icon.dart';
import 'package:DrawOverIt/utils/custom_colors.dart';
import 'package:DrawOverIt/utils/custom_icons_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  late WhiteBoardController whiteBoardController;
  late WhiteBoardController floatingBoardController;
  late SharedPreferences prefs;
  late HotKey callKey;
  late HotKey undoKey;
  late HotKey redoKey;
  late HotKey eraseKey;
  late HotKey clearKey;
  late HotKey floatKey;
  late HotKey blurKey;
  late HotKey solidKey;
  Menu? _menu;

  CustomColors c = CustomColors();
  Color strokeC = Colors.blue;

  String colorValue = "blue";

  double gapWidth = 15;
  double strokeW = 4;
  double initStrokeW = 4;

  bool erase = false;
  bool panelSwitch = false;
  bool floatingSwitch = true;
  bool slidePanel = true;
  bool slideBoard = true;

  @override
  void initState() {
    //tray listener, icon and menu setup
    trayManager.addListener(this);

    //white board controller
    whiteBoardController = WhiteBoardController();
    floatingBoardController = WhiteBoardController();

    //register hotkey (ALT+Q)
    callKey = HotKey(
      key: PhysicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );

    //undo hotkey
    undoKey = HotKey(
      key: PhysicalKeyboardKey.keyZ,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //redo hotkey
    redoKey = HotKey(
      key: PhysicalKeyboardKey.keyU,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //erase hotkey
    eraseKey = HotKey(
      key: PhysicalKeyboardKey.keyE,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //erase hotkey
    clearKey = HotKey(
      key: PhysicalKeyboardKey.keyX,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //erase hotkey
    floatKey = HotKey(
      key: PhysicalKeyboardKey.keyF,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //blur background hotkey
    blurKey = HotKey(
      key: PhysicalKeyboardKey.keyB,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //solid background hotkey
    solidKey = HotKey(
      key: PhysicalKeyboardKey.keyS,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );

    //maximize screen
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        //make sure window fill the screen
        await windowManager.maximize();

        //set tray icon
        await trayManager.setIcon('assets/images/draw_icon.ico');

        await _setContextMenu();

        //shared pref
        prefs = await SharedPreferences.getInstance();

        //check if data already exists
        if (!prefs.containsKey('clear')) {
          await prefs.setBool('clear', true);
        }

        if (!prefs.containsKey('blur')) {
          await prefs.setBool('blur', false);
        }
        if (!prefs.containsKey('solid')) {
          await prefs.setBool('solid', false);
        }

        //make window blur or solid (default trans)
        if (prefs.getBool('blur')!) {
          Window.setEffect(effect: WindowEffect.aero);
        } else if (prefs.getBool('solid')!) {
          Window.setEffect(effect: WindowEffect.solid);
        } else {
          Window.setEffect(effect: WindowEffect.transparent);
        }

        //hotkeys functionalities
        registerHotKyes();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  //minimize first so it doesn't look ugly to just exit the app
  void hideWindow() async {
    await windowManager.minimize();
    await windowManager.hide();

    if (prefs.getBool('clear')!) {
      whiteBoardController.clear();
    }
  }

  //register hotkeys
  void registerHotKyes() async {
    //call app
    await hotKeyManager.register(
      callKey,
      keyDownHandler: (hotKey) async {
        if (await windowManager.isVisible() &&
            !await windowManager.isMinimized()) {
          if (!await windowManager.isFocused()) {
            await windowManager.focus();
          } else {
            hideWindow();
          }
        } else {
          await windowManager.show();
        }
      },
    );

    //undo stroke
    await hotKeyManager.register(
      undoKey,
      keyDownHandler: (hotKey) {
        whiteBoardController.undo();
      },
    );

    //redo stroke
    await hotKeyManager.register(
      redoKey,
      keyDownHandler: (hotKey) {
        whiteBoardController.redo();
      },
    );

    //enable eraser
    await hotKeyManager.register(
      eraseKey,
      keyDownHandler: (hotKey) {
        setState(() {
          erase = !erase;
          strokeW = erase ? 100 : initStrokeW;
        });
      },
    );

    //clear board
    await hotKeyManager.register(
      clearKey,
      keyDownHandler: (hotKey) {
        setState(() {
          whiteBoardController.clear();
        });
      },
    );

    //clear board
    await hotKeyManager.register(
      floatKey,
      keyDownHandler: (hotKey) {
        setState(() {
          floatingSwitch = !floatingSwitch;
        });
      },
    );

    //blur background
    await hotKeyManager.register(
      blurKey,
      keyDownHandler: (hotKey) {
        setState(() {
          prefs.setBool('blur', !prefs.getBool('blur')!);
          prefs.setBool('solid', false);

          if (prefs.getBool('blur')!) {
            Window.setEffect(effect: WindowEffect.aero);
          } else {
            Window.setEffect(effect: WindowEffect.transparent);
          }
        });
      },
    );

    //solid background
    await hotKeyManager.register(
      solidKey,
      keyDownHandler: (hotKey) {
        setState(() {
          prefs.setBool('solid', !prefs.getBool('solid')!);
          prefs.setBool('blur', false);

          if (prefs.getBool('solid')!) {
            Window.setEffect(effect: WindowEffect.solid);
          } else {
            Window.setEffect(effect: WindowEffect.transparent);
          }
        });
      },
    );
  }

  //handles context menu (for now only Exit App)
  Future _setContextMenu() async {
    _menu ??= Menu(
      items: [
        MenuItem(
          label: 'Exit Draw Over It',
          onClick: (menuItem) async {
            await windowManager.close();
          },
        ),
      ],
    );
    await trayManager.setContextMenu(_menu!);
  }

  //method to show Contact Me dialog
  void showConatctDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: c.black.withOpacity(1),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ContactUs(
                logo: const AssetImage('assets/images/pfp12313.PNG'),
                email: 'yahya.amarneh73@gmail.com',
                companyName: 'Yahya',
                phoneNumber: null,
                dividerThickness: 2,
                githubUserName: 'YahyaAAAAAAA',
                linkedinURL:
                    'https://www.linkedin.com/in/yahya-amarneh-315528229/',
                tagLine: 'Software Engineer',
                twitterHandle: null,
                textColor: c.black,
                cardColor: c.gray,
                companyColor: c.gray,
                taglineColor: c.gray,
                dividerColor: c.gray,
              ),
            ),
          ],
        );
      },
    );
  }

  //show dialog for shortcuts
  void showShortcutsDialg() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              color: c.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                settingsTopRow(
                    context, "Shortcuts", Icons.keyboard_rounded, 22),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open/Close : ALT+Q (System Wise)',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Undo : CTRL+Z',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Redo : CTRL+U',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Eraser : CTRL+E',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Clear All : CTRL+X',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Floating Board : CTRL+F',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Blur Background : CTRL+B',
                        style: getTextStyle(),
                      ),
                      Divider(thickness: 0.2, color: c.gray),
                      Text(
                        'Solid Background : CTRL+S',
                        style: getTextStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextStyle getTextStyle() {
    return TextStyle(
      color: c.gray,
      fontSize: 18,
      fontFamily: 'Abel',
      fontWeight: FontWeight.bold,
    );
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
                : DraggableWidget(
                    left: 100,
                    top: 200,
                    isSlidable: slidePanel,
                    floatingBuilder: (context, constraints) => Container(
                      width: 450,
                      decoration: BoxDecoration(
                        color: c.black,
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
                                SizedBox(width: gapWidth),
                                widthStrokeSelect(),
                                SizedBox(width: gapWidth),
                                eraseButton(),
                                SizedBox(width: gapWidth),
                                undoButton(),
                                SizedBox(width: gapWidth),
                                clearAllButton(),
                                SizedBox(width: gapWidth),
                                floatingBoardButton(),
                                SizedBox(width: gapWidth),
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

  PanelIcon clearAllButton() {
    return PanelIcon(
      icon: CustomIcons.trash,
      onPressed: () {
        whiteBoardController.clear();
      },
      color: c.gray,
      bgColor: c.shadowColor,
      size: 18,
    );
  }

  PanelIcon floatingBoardButton() {
    return PanelIcon(
      icon: floatingSwitch ? CustomIcons.add_board : CustomIcons.active_board,
      onPressed: () {
        setState(() {
          floatingSwitch = !floatingSwitch;
        });
      },
      color: floatingSwitch ? c.gray : c.white,
      bgColor: c.shadowColor,
      size: 17,
    );
  }

  Widget floatingBoard() {
    return DraggableWidget(
      left: floatingSwitch ? 3000 : 1000,
      top: 50,
      speed: 10000,
      isSlidable: slideBoard,
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
                    color: c.gray,
                    width: 0.6,
                  ),
                ),
                color: c.topRowColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    CustomIcons.active_board,
                    color: c.gray,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Floating Board',
                    style: TextStyle(
                      color: c.gray,
                      fontFamily: 'Play',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 220),
                  IconButton(
                    onPressed: () => setState(() => slideBoard = !slideBoard),
                    tooltip: slideBoard
                        ? 'Make Board Not Slide'
                        : 'Make Board Slide',
                    icon: Icon(
                      slideBoard
                          ? Icons.motion_photos_on
                          : Icons.motion_photos_off,
                      size: 20,
                      color: c.gray,
                    ),
                  ),
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
                      color: c.gray,
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
                      color: c.gray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 500,
              height: 400,
              decoration: BoxDecoration(
                color: c.black,
                borderRadius: BorderRadius.circular(50),
              ),
              child: WhiteBoard(
                controller: floatingBoardController,
                backgroundColor: c.black,
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
            backgroundColor: WidgetStatePropertyAll(c.black),
            elevation: const WidgetStatePropertyAll(1),
            shadowColor:
                const WidgetStatePropertyAll(Color.fromARGB(255, 26, 27, 32)),
          ),
          padding: const EdgeInsets.all(10),
          icon: Icon(
            CustomIcons.draw_icon,
            color: c.gray,
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
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: Container(
                  decoration: BoxDecoration(
                    color: c.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      settingsTopRow(
                          context, "Settings", CustomIcons.settings, 17),
                      CustomCheckbox(
                        value: prefs.getBool('clear')!,
                        title: 'Clear board on close',
                        textStyle: getTextStyle(),
                        onChanged: (p0) {
                          setState(
                            () {
                              prefs.setBool('clear', !prefs.getBool('clear')!);
                            },
                          );
                        },
                      ),
                      Divider(
                        color: c.gray,
                        thickness: 0.2,
                      ),
                      CustomCheckbox(
                        value: prefs.getBool('blur')!,
                        title: 'Blur Background',
                        textStyle: getTextStyle(),
                        onChanged: (p0) {
                          setState(
                            () {
                              prefs.setBool('blur', !prefs.getBool('blur')!);
                              prefs.setBool('solid', false);

                              if (prefs.getBool('blur')!) {
                                Window.setEffect(effect: WindowEffect.aero);
                              } else {
                                Window.setEffect(
                                    effect: WindowEffect.transparent);
                              }
                            },
                          );
                        },
                      ),
                      CustomCheckbox(
                        value: prefs.getBool('solid')!,
                        title: 'Solid Background',
                        textStyle: getTextStyle(),
                        onChanged: (p0) {
                          setState(
                            () {
                              prefs.setBool('solid', !prefs.getBool('solid')!);
                              prefs.setBool('blur', false);

                              if (prefs.getBool('solid')!) {
                                Window.setEffect(effect: WindowEffect.solid);
                              } else {
                                Window.setEffect(
                                    effect: WindowEffect.transparent);
                              }
                            },
                          );
                        },
                      ),
                      Divider(
                        color: c.gray,
                        thickness: 0.2,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showShortcutsDialg();
                              },
                              label: Text(
                                'Keyboard Shortcuts',
                                textAlign: TextAlign.left,
                                style: getTextStyle(),
                              ),
                              icon: Icon(
                                Icons.keyboard_rounded,
                                color: c.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: c.gray,
                        thickness: 0.2,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showConatctDialog();
                              },
                              label: Text(
                                'About Me',
                                textAlign: TextAlign.left,
                                style: getTextStyle(),
                              ),
                              icon: Icon(
                                Icons.info_outline,
                                color: c.gray,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
      color: c.gray,
      bgColor: c.shadowColor,
      size: 15,
    );
  }

  Container settingsTopRow(
      BuildContext context, String title, IconData icon, double iconSize) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        border: Border(
          bottom: BorderSide(
            color: c.gray,
            width: 0.3,
          ),
        ),
        color: c.topRowColor,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Icon(
            icon,
            color: c.gray,
            size: iconSize,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: TextStyle(
              color: c.gray,
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
                Navigator.of(context).pop();
              });
            },
            tooltip: 'Close',
            icon: Icon(
              Icons.close,
              size: 20,
              color: c.gray,
            ),
          ),
        ],
      ),
    );
  }

  PanelIcon undoButton() {
    return PanelIcon(
      icon: CustomIcons.undo,
      onPressed: () {
        whiteBoardController.undo();
      },
      color: c.gray,
      bgColor: c.shadowColor,
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
      color: erase ? c.white : c.gray,
      bgColor: c.shadowColor,
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
      bgColor: c.shadowColor,
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
          strokeW = 10;
          initStrokeW = 10;
        });
      },
      color: c.gray,
      bgColor: c.shadowColor,
      size: 15,
    );
  }

  Widget topRow() {
    return Container(
      width: 450,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        border: Border(
          bottom: BorderSide(
            color: c.gray,
            width: 0.3,
          ),
        ),
        color: c.topRowColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          Icon(
            CustomIcons.draw_icon,
            color: c.gray,
            // size: 30,
          ),
          const SizedBox(
            width: 2,
          ),
          Text(
            'Draw Over It',
            style: TextStyle(
              color: c.gray,
              fontFamily: 'Play',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 145,
          ),
          IconButton(
            onPressed: () async => setState(() => slidePanel = !slidePanel),
            tooltip: slidePanel ? 'Make Panel Not Slide' : 'Make Panel Slide',
            icon: Icon(
              slidePanel ? Icons.motion_photos_on : Icons.motion_photos_off,
              size: 20,
              color: c.gray,
            ),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                panelSwitch = true;
              });
            },
            tooltip: 'Hide',
            icon: Icon(
              CustomIcons.eye_crossed,
              size: 15,
              color: c.gray,
            ),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                windowManager.minimize();
              });
            },
            tooltip: 'Minimize',
            icon: Icon(
              Icons.horizontal_rule,
              size: 20,
              color: c.gray,
            ),
          ),
          IconButton(
            onPressed: hideWindow,
            tooltip: 'Close To Background',
            icon: Icon(
              Icons.close,
              size: 20,
              color: c.gray,
            ),
          )
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() async {
    if (await windowManager.isVisible() && !await windowManager.isMinimized()) {
      hideWindow();
    } else {
      windowManager.show();
    }
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
    print('object');
    super.onTrayIconRightMouseDown();
  }
}
