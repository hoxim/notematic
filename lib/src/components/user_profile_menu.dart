import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class UserProfileMenu extends ConsumerWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onAboutTap;
  final VoidCallback onLogoutTap;

  const UserProfileMenu({
    super.key,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onAboutTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userEmail = userState.email;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                userEmail != null && userEmail.isNotEmpty
                    ? userEmail[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (MediaQuery.of(context).size.width > 400)
              Text(
                userEmail ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userEmail ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Signed in',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 12),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings, size: 20),
              const SizedBox(width: 12),
              const Text('Settings'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'about',
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 12),
              const Text('About'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              const Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'profile':
            onProfileTap();
            break;
          case 'settings':
            onSettingsTap();
            break;
          case 'about':
            onAboutTap();
            break;
          case 'logout':
            onLogoutTap();
            break;
        }
      },
    );
  }
}
