// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:autoshut/component/custom_title_bar.dart';
import 'package:autoshut/controller/shutdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'settings_page.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ShutdownController shutdownController = Get.put(ShutdownController());
  final GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          children: [
            CustomTitleBar(),
            AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text("AutoShut"),
              leading: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Get.to(() => SettingsPage());
                },
              ),
            ),
          ],
        ),
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
                      ? "Your Device Will Shutdown at : ${DateFormat('hh:mm a').format(shutdownController.selectedTime.value!)}"
                      : "Please Select a Time",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
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
                            shutdownController.resetShutdown();
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
