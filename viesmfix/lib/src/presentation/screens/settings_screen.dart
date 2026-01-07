import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_language.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/settings/settings_provider.dart';
import '../widgets/language_selector_bottom_sheet.dart';
import 'appearance_settings_screen.dart';
import 'content_display_settings_screen.dart';
import 'interaction_settings_screen.dart';
import 'accessibility_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentLanguage = AppLanguage.fromLocale(currentLocale);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Customization Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ultimate Customization',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '100+ settings to make this app truly yours',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Customization Categories
          _SectionHeader(title: 'Personalization'),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.palette, color: Colors.purple),
            ),
            title: const Text('Appearance'),
            subtitle: const Text('Themes, colors, fonts & animations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceSettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard, color: Colors.blue),
            ),
            title: const Text('Content Display'),
            subtitle: const Text('Cards, grids, images & information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContentDisplaySettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.touch_app, color: Colors.green),
            ),
            title: const Text('Interaction & Feedback'),
            subtitle: const Text('Gestures, haptics, sounds & navigation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InteractionSettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.accessibility_new, color: Colors.orange),
            ),
            title: const Text('Accessibility'),
            subtitle: const Text('Vision, motion, audio & interaction aids'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccessibilitySettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Language & Region'),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Row(
              children: [
                Text(
                  currentLanguage.flag,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(currentLanguage.nativeName),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              LanguageSelectorBottomSheet.show(context);
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Quick Toggles'),

          SwitchListTile(
            secondary: const Icon(Icons.celebration),
            title: const Text('Gamification'),
            subtitle: const Text('XP, levels, achievements & streaks'),
            value: settings.enableGamification,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableGamification(value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.visibility_off),
            title: const Text('Show Adult Content'),
            subtitle: const Text('Include mature/adult content'),
            value: settings.showAdultContent,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateShowAdultContent(value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.play_circle),
            title: const Text('Auto-play Trailers'),
            subtitle: const Text('Automatically play on movie details'),
            value: settings.autoPlayTrailers,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateAutoPlayTrailers(value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Push notifications for updates'),
            value: settings.enablePushNotifications,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateNotifications(value);
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Account'),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          const Divider(),

          // About Section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open terms of service
            },
          ),
          const Divider(),

          // Danger Zone
          _SectionHeader(title: 'Account Actions'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Logout', style: TextStyle(color: Colors.orange)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ViesmFix',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 ViesmFix. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('A beautiful movie discovery app built with Flutter.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform account deletion
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Helper function for reset dialog
void _showResetDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset Settings'),
      content: const Text(
        'Are you sure you want to reset all settings to defaults?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).resetToDefaults();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings reset to defaults')),
            );
          },
          child: const Text('Reset'),
        ),
      ],
    ),
  );
}
