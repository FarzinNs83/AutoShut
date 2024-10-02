import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class CustomTitleBar extends StatelessWidget {
  CustomTitleBar({super.key});
  final GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WindowTitleBarBox(
      child: Container(
        color: theme.brightness == Brightness.dark
            ? theme.appBarTheme.backgroundColor ?? Colors.black
            : theme.appBarTheme.backgroundColor ?? Colors.white,
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(),
            ),
            const Row(
              children: [
                MinimizeWindow(),
                CloseWindowButton(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CloseWindowButton extends StatelessWidget {
  const CloseWindowButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
        onPressed: () {
          appWindow.close();
        },
        tooltip: 'Close',
        icon: Icon(
          Icons.close,
          color: theme.brightness == Brightness.dark
              ? theme.appBarTheme.backgroundColor ?? Colors.white
              : theme.appBarTheme.backgroundColor ?? Colors.black,
        ));
  }
}

class MinimizeWindow extends StatelessWidget {
  const MinimizeWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
        onPressed: () {
          appWindow.minimize();
        },
        tooltip: 'Minimize',
        icon: Icon(
          Icons.minimize,
          color: theme.brightness == Brightness.dark
              ? theme.appBarTheme.backgroundColor ?? Colors.white
              : theme.appBarTheme.backgroundColor ?? Colors.black,
        ));
  }
}
