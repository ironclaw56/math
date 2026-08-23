import 'package:flutter/material.dart';
import '../services/app_state.dart';

/// Settings page: dark mode toggle plus placeholders for future
/// preferences (notifications, download quality, etc.).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) {
          final isDark = AppState.instance.themeMode == ThemeMode.dark;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: isDark,
                onChanged: (value) => AppState.instance.toggleDarkMode(value),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Offline Support'),
                subtitle: const Text('All content is available offline'),
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              const ListTile(
                leading: Icon(Icons.notifications_outlined),
                title: Text('Notifications'),
                subtitle: Text('Coming soon'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.star_border_rounded),
                title: const Text('Rate App'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanks for your support!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded),
                title: const Text('Share App'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
