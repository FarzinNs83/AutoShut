// ignore_for_file: use_build_context_synchronously, unused_element

import 'dart:convert';

import 'package:autoshut/component/custom_title_bar.dart';
import 'package:autoshut/controller/shutdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ShutdownController shutdownController = Get.put(ShutdownController());
  final GetStorage storage = GetStorage();
  final isDarkMode = false.obs;

  @override
  Widget build(BuildContext context) {
    isDarkMode.value = storage.read('isDarkMode') ?? false;
    // shutdownController.isShutdownScheduled.value =
    //     storage.read('isShutdownScheduled') ?? false;

    // final storedTime = storage.read('selectedTime');
    // if (storedTime != null) {
    //   shutdownController.selectedTime.value = DateTime.parse(storedTime);
    // } else {
    //   shutdownController.resetShutdown();
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    });

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
              actions: [
                Obx(() => IconButton(
                      icon: Icon(isDarkMode.value
                          ? Icons.wb_sunny
                          : Icons.nights_stay),
                      onPressed: () {
                        isDarkMode.value = !isDarkMode.value;
                        Get.changeThemeMode(isDarkMode.value
                            ? ThemeMode.dark
                            : ThemeMode.light);
                        storage.write('isDarkMode', isDarkMode.value);
                      },
                    )),
              ],
              leading: IconButton(
                  onPressed: () => _checkForUpdate(context),
                  icon: const Icon(Icons.update)),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
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

  Future<void> _checkForUpdate(BuildContext context) async {
    const String repoOwner = 'FarzinNs83';
    const String repoName = 'AutoShut';
    const String currentVersion = 'V.1.0.0';

    const url =
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final latestRelease = json.decode(response.body);
      final latestVersion = latestRelease['tag_name'].replaceAll('v', '');
      final releaseUrl = latestRelease['html_url'];

      if (isNewVersionAvailable(currentVersion, latestVersion)) {
        showUpdateDialog(context, currentVersion, latestVersion, releaseUrl);
      } else {
        Get.snackbar(
          "Update",
          "App is Up-To_Date",
          backgroundColor: Colors.greenAccent,
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color.fromARGB(230, 255, 255, 255),
        );
      }
    } else {
      Get.snackbar(
        "Error",
        "Checking for update failed!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: const Color.fromARGB(230, 255, 255, 255),
      );
    }
  }

  bool isNewVersionAvailable(String current, String latest) {
    return latest.compareTo(current) > 0;
  }

  void showUpdateDialog(BuildContext context, String currentVersion,
      String latestVersion, String releaseUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Update : $latestVersion'),
          content: Text(
              'Current Version : $currentVersion\n New Version : $latestVersion\n Do you want to download the new update ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final Uri uri = Uri.parse(releaseUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $releaseUrl';
                }
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }
}
