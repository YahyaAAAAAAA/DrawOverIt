import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:DrawOverIt/pages/home.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();

  //unregister hotkeys
  await hotKeyManager.unregisterAll();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(500, 500),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setResizable(false);
      await windowManager.maximize();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      )),
    );
  }
}
