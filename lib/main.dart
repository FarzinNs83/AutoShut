import 'package:autoshut/view/home_screen.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  // final GetStorage storage = GetStorage();

  // DateTime? shutdownTime = storage.read('shutdownTime') != null
  //     ? DateTime.parse(storage.read('shutdownTime'))
  //     : null;

  // if (shutdownTime != null && shutdownTime.isBefore(DateTime.now())) {
  //   storage.remove('shutdownTime');
  //   storage.write('isShutdownScheduled', false);
  // }

  runApp(MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(600, 500);
    appWindow.size = initialSize;
    appWindow.minSize = initialSize;
    appWindow.show();
  });
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
