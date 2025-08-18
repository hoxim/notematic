import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
// import '../providers/logger_provider.dart';
import '../services/api_service.dart';
// import '../services/google_auth_service.dart';
import '../providers/theme_provider.dart';
import '../components/sync_toggle.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    // final logger = ref.read(loggerServiceProvider);
    final api = ref.read(apiServiceProvider);
    // final google = ref.read(googleAuthServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: api.getAccountProviders(),
        builder: (context, snapshot) {
          final providers = snapshot.data != null
              ? (snapshot.data!['providers'] as Map<String, dynamic>?)
              : null;
          final hasLocal = providers?['local'] == true;
          final hasGoogle = providers?['google'] == true;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Global settings
              const SizedBox(height: 8),
              const Text('General',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Sync toggle (global)j
              const SyncToggle(),
              const Divider(),
              // Theme selection
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: const Text('Light / Dark / System'),
                onTap: () async {
                  final notifier = ref.read(themeModeProvider.notifier);
                  await showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.wb_sunny_outlined),
                          title: const Text('Light'),
                          onTap: () {
                            notifier.setThemeMode(ThemeMode.light);
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.nightlight_outlined),
                          title: const Text('Dark'),
                          onTap: () {
                            notifier.setThemeMode(ThemeMode.dark);
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings_suggest_outlined),
                          title: const Text('System'),
                          onTap: () {
                            notifier.setThemeMode(ThemeMode.system);
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Formatting'),
                subtitle: const Text('Placeholder – coming soon'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('Placeholder – coming soon'),
                onTap: () {},
              ),
              const Divider(),
              // Profile/account moved to Profile screen; below remains only link button if needed
              if (snapshot.connectionState == ConnectionState.waiting)
                const ListTile(
                    leading: CircularProgressIndicator(strokeWidth: 2),
                    title: Text('Loading account status...')),
              if (snapshot.hasError)
                const ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text('Failed to load account status')),
              if (providers != null)
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Linked providers'),
                  subtitle: Text(
                      'Email/Password: ${hasLocal ? 'Yes' : 'No'}\nGoogle: ${hasGoogle ? 'Yes' : 'No'}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
