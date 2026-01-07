import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/settings/app_settings.dart';
import '../../core/settings/settings_provider.dart';

class ContentDisplaySettingsScreen extends ConsumerWidget {
  const ContentDisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Content Display')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Movie Cards'),

          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Card Style'),
            subtitle: Text(_getCardStyleName(settings.movieCardStyle)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCardStyleDialog(context, ref, settings),
          ),

          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Grid Density'),
            subtitle: Text(_getGridDensityName(settings.gridDensity)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showGridDensityDialog(context, ref, settings),
          ),

          const Divider(),
          _SectionHeader(title: 'Card Information'),

          SwitchListTile(
            secondary: const Icon(Icons.star),
            title: const Text('Show Ratings'),
            subtitle: const Text('Display movie ratings on cards'),
            value: settings.showMovieRatings,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(showMovieRatings: value));
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.calendar_today),
            title: const Text('Show Release Year'),
            subtitle: const Text('Display release year on cards'),
            value: settings.showMovieYear,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(showMovieYear: value));
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.access_time),
            title: const Text('Show Duration'),
            subtitle: const Text('Display runtime on cards'),
            value: settings.showMovieDuration,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(showMovieDuration: value));
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.category),
            title: const Text('Show Genres'),
            subtitle: const Text('Display genre tags on cards'),
            value: settings.showGenresOnCard,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(showGenresOnCard: value));
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Images'),

          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Image Quality'),
            subtitle: Text(_getImageQualityName(settings.imageQuality)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showImageQualityDialog(context, ref, settings),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.zoom_in),
            title: const Text('Enable Image Zoom'),
            subtitle: const Text('Pinch to zoom on movie posters'),
            value: settings.enableImageZoom,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(enableImageZoom: value));
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.save),
            title: const Text('Cache Images'),
            subtitle: const Text('Save images for faster loading'),
            value: settings.enableImageCaching,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(enableImageCaching: value));
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Content Filtering'),

          ListTile(
            leading: const Icon(Icons.supervised_user_circle),
            title: const Text('Maximum Content Rating'),
            subtitle: Text(_getContentRatingName(settings.maxContentRating)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showContentRatingDialog(context, ref, settings),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.no_adult_content),
            title: const Text('Show Adult Content'),
            subtitle: const Text('Include adult/mature content'),
            value: settings.showAdultContent,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateShowAdultContent(value);
            },
          ),

          const Divider(),
          _SectionHeader(title: 'Spoiler Protection'),

          SwitchListTile(
            secondary: const Icon(Icons.warning_amber),
            title: const Text('Show Spoiler Warnings'),
            subtitle: const Text('Warn before showing spoilers'),
            value: settings.showSpoilerWarnings,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(showSpoilerWarnings: value),
                  );
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.blur_on),
            title: const Text('Blur Spoilers'),
            subtitle: const Text('Blur spoiler content by default'),
            value: settings.blurSpoilers,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(blurSpoilers: value));
            },
          ),
        ],
      ),
    );
  }

  String _getCardStyleName(MovieCardStyle style) {
    switch (style) {
      case MovieCardStyle.poster:
        return 'Poster (Vertical)';
      case MovieCardStyle.backdrop:
        return 'Backdrop (Horizontal)';
      case MovieCardStyle.compact:
        return 'Compact';
      case MovieCardStyle.detailed:
        return 'Detailed';
      case MovieCardStyle.minimal:
        return 'Minimal';
    }
  }

  String _getGridDensityName(GridDensity density) {
    switch (density) {
      case GridDensity.comfortable:
        return 'Comfortable (2 columns)';
      case GridDensity.normal:
        return 'Normal (3 columns)';
      case GridDensity.compact:
        return 'Compact (4 columns)';
      case GridDensity.dense:
        return 'Dense (5 columns)';
    }
  }

  String _getImageQualityName(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 'Low (Saves Data)';
      case ImageQuality.medium:
        return 'Medium';
      case ImageQuality.high:
        return 'High';
      case ImageQuality.original:
        return 'Original (Best Quality)';
      case ImageQuality.auto:
        return 'Auto (Based on Connection)';
    }
  }

  String _getContentRatingName(ContentRating rating) {
    switch (rating) {
      case ContentRating.g:
        return 'G - General Audiences';
      case ContentRating.pg:
        return 'PG - Parental Guidance';
      case ContentRating.pg13:
        return 'PG-13 - Parents Strongly Cautioned';
      case ContentRating.r:
        return 'R - Restricted';
      case ContentRating.nc17:
        return 'NC-17 - Adults Only';
      case ContentRating.unrated:
        return 'Unrated - All Content';
    }
  }

  void _showCardStyleDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Card Style'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: MovieCardStyle.values.map((style) {
              return RadioListTile<MovieCardStyle>(
                title: Text(_getCardStyleName(style)),
                value: style,
                groupValue: settings.movieCardStyle,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateMovieCardStyle(value);
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

  void _showGridDensityDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grid Density'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GridDensity.values.map((density) {
            return RadioListTile<GridDensity>(
              title: Text(_getGridDensityName(density)),
              value: density,
              groupValue: settings.gridDensity,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateGridDensity(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showImageQualityDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Quality'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ImageQuality.values.map((quality) {
              return RadioListTile<ImageQuality>(
                title: Text(_getImageQualityName(quality)),
                value: quality,
                groupValue: settings.imageQuality,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateImageQuality(value);
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

  void _showContentRatingDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Content Rating'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ContentRating.values.map((rating) {
              return RadioListTile<ContentRating>(
                title: Text(_getContentRatingName(rating)),
                value: rating,
                groupValue: settings.maxContentRating,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateSettings(
                          settings.copyWith(maxContentRating: value),
                        );
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
