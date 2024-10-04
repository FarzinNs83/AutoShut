import 'package:autoshut/service/shutdown_command.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ShutdownController extends GetxController {
  var selectedTime = Rxn<DateTime>();
  var isShutdownScheduled = false.obs;

  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();

    String? storedTime = storage.read('shutdownTime');
    if (storedTime != null) {
      selectedTime.value = DateTime.parse(storedTime);
    }

    isShutdownScheduled.value = storage.read('isShutdownScheduled') ?? false;

    updateConfirmButtonStatus();
  }

  void updateConfirmButtonStatus() {
    if (selectedTime.value != null &&
        selectedTime.value!.isAfter(DateTime.now())) {
      isShutdownScheduled.value = true;
    } else {
      isShutdownScheduled.value = false;
      selectedTime.value = null;
      storage.remove('shutdownTime');
    }
  }

  void resetShutdown() {
    selectedTime.value = null;
    isShutdownScheduled.value = false;
    storage.remove('shutdownTime');
    storage.remove('isShutdownScheduled');
  }

  Future<void> pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      selectedTime.value = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      if (selectedTime.value!.isBefore(now)) {
        selectedTime.value = selectedTime.value!.add(const Duration(days: 1));
      }

      storage.write('shutdownTime', selectedTime.value!.toIso8601String());

      update();
    }
  }

  Future<void> scheduleShutdown(BuildContext context) async {
    if (selectedTime.value == null) return;

    final now = DateTime.now();
    final shutdownTime = selectedTime.value!;
    final duration = shutdownTime.difference(now);

    if (duration.inSeconds > 0) {
      await ShutdownManager.scheduleShutdown(duration.inSeconds);
      isShutdownScheduled.value = true;
      storage.write('isShutdownScheduled', true);

      storage.write('shutdownInProgress', true);

      Get.snackbar(
        'Shutdown Scheduled',
        'System will shutdown at ${DateFormat('hh:mm a').format(shutdownTime)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Please Select a New Time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> cancelShutdown() async {
    await ShutdownManager.cancelShutdown();
    resetState();

    Get.snackbar(
      'Shutdown Cancelled',
      'Shutdown schedule has been cancelled successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void resetState() {
    selectedTime.value = null;
    isShutdownScheduled.value = false;

    storage.remove('shutdownTime');
    storage.write('isShutdownScheduled', false);
    storage.write('shutdownInProgress', false);
  }
}
