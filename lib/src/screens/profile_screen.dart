import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final api = ref.read(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.email.isEmpty ? 'User' : user.email),
                subtitle: const Text('Signed in user'),
              ),
              const Divider(),
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
