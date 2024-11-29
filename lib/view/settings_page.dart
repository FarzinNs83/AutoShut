// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  final isDarkMode = true.obs;
  final GetStorage storage = GetStorage();

  SettingsPage({super.key}) {
    isDarkMode.value = storage.read('isDarkMode') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => SwitchListTile(
                    title: const Text("Dark Mode"),
                    value: isDarkMode.value,
                    onChanged: (value) {
                      isDarkMode.value = value;
                      Get.changeThemeMode(
                          isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
                      storage.write('isDarkMode', isDarkMode.value);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: ListTile(
                leading: const Icon(Icons.update),
                title: const Text("Check for Update"),
                onTap: () => _checkForUpdate(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text("Contact Us"),
                onTap: () => contactUs(context),
              ),
            ),
          ],
        ),
      ),
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
          "App is Up-To-Date",
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
              'Current Version : $currentVersion\n New Version : $latestVersion\n Do you want to download the new update?'),
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
Future<dynamic> contactUs(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: Get.height * 0.25,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: IconButton(
                      splashRadius: 6,
                      icon: const FaIcon(FontAwesomeIcons.telegram),
                      iconSize: 42,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        mylaunchUrl('https://t.me/flutterstuff');
                      },
                    ),
                  ),
                  Text("Telegram",
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              // const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: IconButton(
                      splashRadius: 6,
                      icon: const FaIcon(FontAwesomeIcons.github),
                      iconSize: 42,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        mylaunchUrl('https://github.com/FarzinNs83/AutoShut');
                      },
                    ),
                  ),
                  Text("GitHub",
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              // const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: IconButton(
                      splashRadius: 6,
                      icon: const Icon(Icons.support_agent),
                      iconSize: 42,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        mylaunchUrl('https://t.me/feri_ns83');
                      },
                    ),
                  ),
                  Text("Support",
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
    mylaunchUrl(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch");
    }
  }
}
