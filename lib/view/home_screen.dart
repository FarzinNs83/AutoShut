import 'package:autoshut/controller/shutdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ShutdownController shutdownController = Get.put(ShutdownController());
  final GetStorage storage = GetStorage();
  final isDarkMode = false.obs;

  @override
  Widget build(BuildContext context) {
    isDarkMode.value = storage.read('isDarkMode') ?? false;
    shutdownController.isShutdownScheduled.value =
        storage.read('isShutdownScheduled') ?? false;

    final storedTime = storage.read('selectedTime');
    if (storedTime != null) {
      shutdownController.selectedTime.value = DateTime.parse(storedTime);
    } else {
    
      shutdownController.resetShutdown();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("AutoShut"),
        actions: [
          Obx(() => IconButton(
                icon:
                    Icon(isDarkMode.value ? Icons.wb_sunny : Icons.nights_stay),
                onPressed: () {
                  isDarkMode.value = !isDarkMode.value;
                  Get.changeThemeMode(
                      isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
                  storage.write('isDarkMode', isDarkMode.value);
                },
              )),
        ],
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.update)),
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  shutdownController.selectedTime.value != null
                      ? "Your Last Shutdown Schedule Was Set at ${DateFormat('hh:mm a').format(shutdownController.selectedTime.value!)}"
                      : "Please Select a Time",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      color: Colors.greenAccent,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "The Latest Schedule Is Shown To The User",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => shutdownController.pickTime(context),
                  icon: const Icon(Icons.access_time),
                  label: const Text("Select Shutdown Time"),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: shutdownController.selectedTime.value != null &&
                          !shutdownController.isShutdownScheduled.value
                      ? () {
                          shutdownController.scheduleShutdown(context);
                          storage.write('isShutdownScheduled', true);
                          storage.write(
                              'selectedTime',
                              shutdownController.selectedTime.value!
                                  .toIso8601String());
                        }
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text("Confirm Schedule"),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  return shutdownController.isShutdownScheduled.value
                      ? ElevatedButton.icon(
                          onPressed: () {
                            shutdownController.cancelShutdown();
                            shutdownController
                                .resetShutdown(); 
                            storage.write('isShutdownScheduled', false);
                            storage.remove('selectedTime');
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text("Cancel Schedule"),
                        )
                      : Container();
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
