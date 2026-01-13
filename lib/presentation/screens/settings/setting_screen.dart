import 'package:flutter/material.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:provider/provider.dart';
import 'package:medibot/presentation/screens/settings/widgets/proifle_header.dart';
import 'package:medibot/presentation/screens/settings/widgets/setting_card.dart';
import 'package:medibot/presentation/screens/settings/widgets/setting_tile.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Settings',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Center(
            child: Container(
              margin: const EdgeInsets.only(left: 10, top: 10),
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 193, 193, 193),
                  width: 0.15,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return ListView(
            children: [
              ProfileHeader(
                name: user?.displayName ?? 'User',
                email: user?.email ?? 'No email',
                photoUrl: user?.photoUrl,
              ),
              const SizedBox(height: 8),
              SettingCard(
                children: [
                  SettingTile(
                    icon: Icons.brightness_7_rounded,
                    title: 'Appearance',
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Icons.private_connectivity,
                    title: 'Data Control',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SettingCard(
                children: [
                  SettingTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    textColor: const Color.fromARGB(255, 246, 94, 94),
                    onTap: () => _handleLogout(context, authProvider),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Perform logout
        await authProvider.signOut();

        if (context.mounted) {
          // Close loading dialog
          Navigator.pop(context);

          // Navigate to login screen and clear navigation stack using named route
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signIn,
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog
          Navigator.pop(context);

          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
