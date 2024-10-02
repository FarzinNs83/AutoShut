import 'package:process_run/shell.dart';

class ShutdownManager {
  static Future<void> scheduleShutdown(int seconds) async {
    final shell = Shell();
    await shell.run('shutdown /s /t $seconds');
  }

  static Future<void> cancelShutdown() async {
    final shell = Shell();

    await shell.run('shutdown /a');
  }
}
