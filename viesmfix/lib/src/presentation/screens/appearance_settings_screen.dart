import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/settings/app_settings.dart';
import '../../core/settings/settings_provider.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Theme'),

          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme Style'),
            subtitle: Text(_getThemeVariantName(settings.themeVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeVariantDialog(context, ref, settings),
          ),

          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            subtitle: Text(_getThemeModeText(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeModeDialog(context, ref, settings),
          ),

          const Divider(),
          _SectionHeader(title: 'Typography'),

          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font Family'),
            subtitle: Text(_getFontFamilyName(settings.fontFamily)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontFamilyDialog(context, ref, settings),
          ),

          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Text Size'),
            subtitle: Text('${(settings.textScaleFactor * 100).toInt()}%'),
          ),
          Slider(
            value: settings.textScaleFactor,
            min: 0.8,
            max: 1.5,
            divisions: 14,
            label: '${(settings.textScaleFactor * 100).toInt()}%',
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateTextScaleFactor(value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.format_bold),
            title: const Text('Bold Text'),
            subtitle: const Text('Make all text bold'),
            value: settings.boldText,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(boldText: value));
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Animations & Effects'),

          SwitchListTile(
            secondary: const Icon(Icons.animation),
            title: const Text('Enable Animations'),
            subtitle: const Text('Show smooth transitions'),
            value: settings.enableAnimations,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateAnimationsEnabled(value);
            },
          ),

          if (settings.enableAnimations) ...[
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Animation Speed'),
              subtitle: Text(_getAnimationSpeedName(settings.animationSpeed)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAnimationSpeedDialog(context, ref, settings),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.blur_on),
              title: const Text('Blur Effects'),
              subtitle: const Text('Background blur on overlays'),
              value: settings.enableBlur,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings(settings.copyWith(enableBlur: value));
              },
            ),

            SwitchListTile(
              secondary: const Icon(Icons.gradient),
              title: const Text('Gradient Effects'),
              subtitle: const Text('Colorful gradient overlays'),
              value: settings.enableGradients,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings(settings.copyWith(enableGradients: value));
              },
            ),

            SwitchListTile(
              secondary: const Icon(Icons.auto_awesome),
              title: const Text('Glass Effect'),
              subtitle: const Text('Frosted glass appearance'),
              value: settings.enableGlassEffect,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings(
                      settings.copyWith(enableGlassEffect: value),
                    );
              },
            ),

            SwitchListTile(
              secondary: const Icon(Icons.view_in_ar),
              title: const Text('Parallax Effect'),
              subtitle: const Text('3D depth effect on cards'),
              value: settings.enableParallax,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings(settings.copyWith(enableParallax: value));
              },
            ),
          ],

          const Divider(),
          _SectionHeader(title: 'Card Design'),

          ListTile(
            leading: const Icon(Icons.rounded_corner),
            title: const Text('Corner Radius'),
            subtitle: Text('${settings.cornerRadius.toInt()}px'),
          ),
          Slider(
            value: settings.cornerRadius,
            min: 0,
            max: 32,
            divisions: 16,
            label: '${settings.cornerRadius.toInt()}px',
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateCornerRadius(value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.wallpaper),
            title: const Text('Background Style'),
            subtitle: Text(_getBackgroundStyleName(settings.backgroundStyle)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackgroundStyleDialog(context, ref, settings),
          ),

          const Divider(),
          _SectionHeader(title: 'Preview'),

          Padding(
            padding: const EdgeInsets.all(16),
            child: _PreviewCard(settings: settings),
          ),
        ],
      ),
    );
  }

  String _getThemeVariantName(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.netflix:
        return 'Netflix (Red & Dark)';
      case AppThemeVariant.hulu:
        return 'Hulu (Green)';
      case AppThemeVariant.disney:
        return 'Disney+ (Blue)';
      case AppThemeVariant.hbo:
        return 'HBO Max (Purple)';
      case AppThemeVariant.prime:
        return 'Prime Video (Teal)';
      case AppThemeVariant.custom:
        return 'Custom';
    }
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getFontFamilyName(FontFamily font) {
    switch (font) {
      case FontFamily.system:
        return 'System Default';
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.lato:
        return 'Lato';
      case FontFamily.montserrat:
        return 'Montserrat';
      case FontFamily.poppins:
        return 'Poppins';
      case FontFamily.raleway:
        return 'Raleway';
      case FontFamily.nunito:
        return 'Nunito';
    }
  }

  String _getAnimationSpeedName(AnimationSpeed speed) {
    switch (speed) {
      case AnimationSpeed.slow:
        return 'Slow';
      case AnimationSpeed.normal:
        return 'Normal';
      case AnimationSpeed.fast:
        return 'Fast';
      case AnimationSpeed.instant:
        return 'Instant';
    }
  }

  String _getBackgroundStyleName(BackgroundStyle style) {
    switch (style) {
      case BackgroundStyle.solid:
        return 'Solid Color';
      case BackgroundStyle.gradient:
        return 'Gradient';
      case BackgroundStyle.image:
        return 'Image';
      case BackgroundStyle.animated:
        return 'Animated';
    }
  }

  void _showThemeVariantDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Style'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeVariant.values.map((variant) {
              return RadioListTile<AppThemeVariant>(
                title: Text(_getThemeVariantName(variant)),
                value: variant,
                groupValue: settings.themeVariant,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateThemeVariant(value);
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

  void _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontFamilyDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Font'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: FontFamily.values.map((font) {
              return RadioListTile<FontFamily>(
                title: Text(
                  _getFontFamilyName(font),
                  style: TextStyle(
                    fontFamily: font == FontFamily.system ? null : font.name,
                  ),
                ),
                value: font,
                groupValue: settings.fontFamily,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateFontFamily(value);
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

  void _showAnimationSpeedDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Animation Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AnimationSpeed.values.map((speed) {
            return RadioListTile<AnimationSpeed>(
              title: Text(_getAnimationSpeedName(speed)),
              value: speed,
              groupValue: settings.animationSpeed,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateAnimationSpeed(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBackgroundStyleDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Background Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BackgroundStyle.values.map((style) {
            return RadioListTile<BackgroundStyle>(
              title: Text(_getBackgroundStyleName(style)),
              value: style,
              groupValue: settings.backgroundStyle,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateBackgroundStyle(value);
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

class _PreviewCard extends StatelessWidget {
  final AppSettings settings;

  const _PreviewCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(settings.cornerRadius),
        gradient: settings.enableGradients
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              )
            : null,
        color: settings.enableGradients
            ? null
            : Theme.of(context).colorScheme.surfaceVariant,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: settings.boldText
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 20 * settings.textScaleFactor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how text will appear with your current settings.',
            style: TextStyle(
              fontSize: 14 * settings.textScaleFactor,
              fontWeight: settings.boldText
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
