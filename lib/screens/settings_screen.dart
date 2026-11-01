import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            color: colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isDarkMode ? 'Dark theme is enabled' : 'Light theme is enabled',
              ),
              value: isDarkMode,
              activeThumbColor: colorScheme.primary,
              onChanged: (value) {
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            color: colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.task_alt, color: colorScheme.primary),
                  title: const Text('TaskFlow'),
                  subtitle: const Text('Task management application'),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
