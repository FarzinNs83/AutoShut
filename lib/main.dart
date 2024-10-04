import 'package:autoshut/component/system_tray.dart';
import 'package:autoshut/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

Future<void> main(List<String> arg) async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // final GetStorage storage = GetStorage();

  // DateTime? shutdownTime = storage.read('shutdownTime') != null
  //     ? DateTime.parse(storage.read('shutdownTime'))
  //     : null;

  // if (shutdownTime != null && shutdownTime.isBefore(DateTime.now())) {
  //   storage.remove('shutdownTime');
  //   storage.write('isShutdownScheduled', false);
  // }
  WindowOptions windowOptions = const WindowOptions(
    backgroundColor: Colors.transparent,
    size: Size(620, 480),
    center: true,
    title: "AutoShut",
  );
  await windowManager.waitUntilReadyToShow(windowOptions).then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.show();
    await windowManager.focus();
  });
  await WindowsSingleInstance.ensureSingleInstance(
    arg,
    "AutoShut_instance_checker",
    // ignore: avoid_print
    onSecondWindow: (arguments) => print(arguments),
  );

  await initTray();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final themeStorage = GetStorage();

  @override
  Widget build(BuildContext context) {
    ThemeMode initialThemeMode = themeStorage.read('isDarkMode') == true
        ? ThemeMode.dark
        : ThemeMode.light;
    return GetMaterialApp(
      title: 'AutoShut',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      themeMode: initialThemeMode,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
