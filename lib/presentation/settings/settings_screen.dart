import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studentos/config/theme.dart';
import 'package:studentos/services/cloud_storage_service.dart';
import 'package:studentos/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final mockCloudService = MockCloudStorageService();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader(context, "Appearance"),
          SwitchListTile(
            secondary: Icon(Icons.dark_mode, color: colorScheme.primary),
            title: const Text("Dark Mode"),
            subtitle: const Text("Orange & Black Theme"),
            value: isDarkMode,
            activeColor: colorScheme.primary,
            onChanged: (val) {
              ref.read(themeProvider.notifier).state = val;
            },
          ),

          _buildSectionHeader(context, "Productivity"),
          SwitchListTile(
            secondary:
                Icon(Icons.notifications_active, color: colorScheme.primary),
            title: const Text("Focus Reminders"),
            subtitle: const Text("Remind me to focus every 30 mins"),
            value: true,
            activeColor: colorScheme.primary,
            onChanged: (val) {
              NotificationService.showNotification(
                title: "Settings Updated",
                body: val ? "Reminders Enabled" : "Reminders Disabled",
              );
            },
          ),

          _buildSectionHeader(context, "Google Integrations"),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text("Sync with Google Calendar"),
            subtitle: const Text("Add tasks to your calendar"),
            onTap: () async {
              _showLoadingDialog(context);
              try {
                await mockCloudService.syncWithGoogleCalendar();
                if (context.mounted) {
                  // Close dialog safely using rootNavigator
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Synced successfully!"),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sync failed"),
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.green),
            title: const Text("Google Drive Backup"),
            subtitle: const Text("Save your data to the cloud"),
            onTap: () async {
              _showLoadingDialog(context);
              try {
                await mockCloudService.backupDataToGoogleDrive();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Backup successful!"),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Backup failed"),
                    ),
                  );
                }
              }
            },
          ),

          _buildSectionHeader(context, "About"),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version"),
            subtitle: Text("1.0.0 (StudentOS)"),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  "Made with 💜 for Students",
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "by Aaryan Pathak",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
