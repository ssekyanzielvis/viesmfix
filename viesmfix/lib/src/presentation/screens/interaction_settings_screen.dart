import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/settings/app_settings.dart';
import '../../core/settings/settings_provider.dart';

class InteractionSettingsScreen extends ConsumerWidget {
  const InteractionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Interaction & Feedback')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Navigation'),

          ListTile(
            leading: const Icon(Icons.navigation),
            title: const Text('Navigation Style'),
            subtitle: Text(_getNavigationStyleName(settings.navigationStyle)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNavigationStyleDialog(context, ref, settings),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.swipe),
            title: const Text('Swipe Gestures'),
            subtitle: const Text('Navigate with swipe gestures'),
            value: settings.enableSwipeGestures,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(enableSwipeGestures: value),
                  );
            },
          ),

          if (settings.enableSwipeGestures)
            ListTile(
              leading: const Icon(Icons.touch_app),
              title: const Text('Swipe Sensitivity'),
              subtitle: Text(
                _getSwipeSensitivityName(settings.swipeSensitivity),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSwipeSensitivityDialog(context, ref, settings),
            ),

          SwitchListTile(
            secondary: const Icon(Icons.refresh),
            title: const Text('Pull to Refresh'),
            subtitle: const Text('Swipe down to refresh content'),
            value: settings.enablePullToRefresh,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(enablePullToRefresh: value),
                  );
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Quick Actions'),

          SwitchListTile(
            secondary: const Icon(Icons.favorite),
            title: const Text('Double Tap to Like'),
            subtitle: const Text('Double tap movie cards to favorite'),
            value: settings.enableDoubleTapToLike,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(enableDoubleTapToLike: value),
                  );
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Haptic Feedback'),

          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on interactions'),
            value: settings.enableHapticFeedback,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateHapticFeedback(value);
            },
          ),

          if (settings.enableHapticFeedback)
            ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Haptic Intensity'),
              subtitle: Text(_getHapticIntensityName(settings.hapticIntensity)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHapticIntensityDialog(context, ref, settings),
            ),

          const Divider(),
          _SectionHeader(title: 'Sound Effects'),

          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds on interactions'),
            value: settings.enableSoundEffects,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableSoundEffects(value);
            },
          ),

          if (settings.enableSoundEffects) ...[
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Effect Volume'),
              subtitle: Text('${(settings.soundEffectVolume * 100).toInt()}%'),
            ),
            Slider(
              value: settings.soundEffectVolume,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(settings.soundEffectVolume * 100).toInt()}%',
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSoundEffectVolume(value);
              },
            ),
          ],
        ],
      ),
    );
  }

  String _getNavigationStyleName(NavigationStyle style) {
    switch (style) {
      case NavigationStyle.bottomBar:
        return 'Bottom Navigation Bar';
      case NavigationStyle.drawer:
        return 'Side Drawer';
      case NavigationStyle.rail:
        return 'Navigation Rail';
      case NavigationStyle.tabs:
        return 'Top Tabs';
    }
  }

  String _getSwipeSensitivityName(SwipeSensitivity sensitivity) {
    switch (sensitivity) {
      case SwipeSensitivity.low:
        return 'Low';
      case SwipeSensitivity.medium:
        return 'Medium';
      case SwipeSensitivity.high:
        return 'High';
    }
  }

  String _getHapticIntensityName(HapticIntensity intensity) {
    switch (intensity) {
      case HapticIntensity.off:
        return 'Off';
      case HapticIntensity.light:
        return 'Light';
      case HapticIntensity.medium:
        return 'Medium';
      case HapticIntensity.strong:
        return 'Strong';
    }
  }

  void _showNavigationStyleDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NavigationStyle.values.map((style) {
            return RadioListTile<NavigationStyle>(
              title: Text(_getNavigationStyleName(style)),
              value: style,
              groupValue: settings.navigationStyle,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateNavigationStyle(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSwipeSensitivityDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Swipe Sensitivity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SwipeSensitivity.values.map((sensitivity) {
            return RadioListTile<SwipeSensitivity>(
              title: Text(_getSwipeSensitivityName(sensitivity)),
              value: sensitivity,
              groupValue: settings.swipeSensitivity,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSettings(
                        settings.copyWith(swipeSensitivity: value),
                      );
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHapticIntensityDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Haptic Intensity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: HapticIntensity.values.map((intensity) {
            return RadioListTile<HapticIntensity>(
              title: Text(_getHapticIntensityName(intensity)),
              value: intensity,
              groupValue: settings.hapticIntensity,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateHapticIntensity(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
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
