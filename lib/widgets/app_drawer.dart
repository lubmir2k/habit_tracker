import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Navigation drawer for the app with menu items.
class AppDrawer extends StatelessWidget {
  /// Optional callback to refresh data when returning from profile.
  final VoidCallback? onProfileReturn;

  const AppDrawer({super.key, this.onProfileReturn});

  /// Logs out the user and navigates to login screen.
  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    navigator.pop(); // Close drawer first
    try {
      final storageService = await StorageService.getInstance();
      await storageService.clearSession();
      if (!context.mounted) return;
      navigator.pushReplacementNamed('/login');
    } catch (e) {
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  /// Navigates to a route, optionally replacing current route.
  ///
  /// Closes the drawer first, then navigates if not already on that route.
  void _navigateTo(
    BuildContext context,
    String route, {
    bool replace = false,
    void Function()? onReturn,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final navigator = Navigator.of(context);

    // Close drawer first
    navigator.pop();

    if (currentRoute != route) {
      if (replace) {
        navigator.pushReplacementNamed(route);
      } else {
        navigator.pushNamed(route).then((_) {
          onReturn?.call();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Habit Tracker',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => _navigateTo(context, '/home', replace: true),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => _navigateTo(
              context,
              '/profile',
              onReturn: onProfileReturn,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => _navigateTo(context, '/reports'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () => _navigateTo(context, '/notifications'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
