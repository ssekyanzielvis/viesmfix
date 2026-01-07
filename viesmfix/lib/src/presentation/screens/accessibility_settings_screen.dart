import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/settings/app_settings.dart';
import '../../core/settings/settings_provider.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Vision'),

          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Increase contrast for better visibility'),
            value: settings.highContrastMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateHighContrastMode(value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Color Blind Mode'),
            subtitle: Text(_getColorBlindModeName(settings.colorBlindMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showColorBlindModeDialog(context, ref, settings),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.invert_colors),
            title: const Text('Monochrome Mode'),
            subtitle: const Text('Display in grayscale'),
            value: settings.monochromeMode,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(monochromeMode: value));
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Motion'),

          SwitchListTile(
            secondary: const Icon(Icons.accessibility_new),
            title: const Text('Reduce Motion'),
            subtitle: const Text('Minimize animations and transitions'),
            value: settings.reduceMotion,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateReduceMotion(value);
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Interaction'),

          SwitchListTile(
            secondary: const Icon(Icons.touch_app),
            title: const Text('Larger Touch Targets'),
            subtitle: const Text('Make buttons easier to tap'),
            value: settings.largerTouchTargets,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(largerTouchTargets: value));
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Audio'),

          SwitchListTile(
            secondary: const Icon(Icons.hearing),
            title: const Text('Screen Reader Support'),
            subtitle: const Text('Enable TalkBack/VoiceOver support'),
            value: settings.enableScreenReader,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(enableScreenReader: value));
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.closed_caption),
            title: const Text('Always Show Closed Captions'),
            subtitle: const Text('Display captions when available'),
            value: settings.enableClosedCaptions,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(enableClosedCaptions: value),
                  );
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.announcement),
            title: const Text('Announce UI Changes'),
            subtitle: const Text('Announce screen and content updates'),
            value: settings.announceUIChanges,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(announceUIChanges: value));
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Accessibility Tip',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These settings work alongside your device\'s accessibility features. '
                      'For best results, also configure your system accessibility settings.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getColorBlindModeName(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return 'None';
      case ColorBlindMode.protanopia:
        return 'Protanopia (Red-Blind)';
      case ColorBlindMode.deuteranopia:
        return 'Deuteranopia (Green-Blind)';
      case ColorBlindMode.tritanopia:
        return 'Tritanopia (Blue-Blind)';
      case ColorBlindMode.achromatopsia:
        return 'Achromatopsia (Total Color Blindness)';
    }
  }

  void _showColorBlindModeDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Blind Mode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ColorBlindMode.values.map((mode) {
              return RadioListTile<ColorBlindMode>(
                title: Text(_getColorBlindModeName(mode)),
                value: mode,
                groupValue: settings.colorBlindMode,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateColorBlindMode(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ),
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
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
