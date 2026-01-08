import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants/environment.dart';
import '../../../../services/api/tmdb_service.dart';
import '../../../../data/models/remote/tmdb_movie_model.dart';

final _tmdbServiceProvider = Provider<TMDBService>((ref) => TMDBService());

class WhereToWatchScreen extends ConsumerStatefulWidget {
  final int movieId;
  final String countryCode;

  const WhereToWatchScreen({
    super.key,
    required this.movieId,
    this.countryCode = 'US',
  });

  @override
  ConsumerState<WhereToWatchScreen> createState() => _WhereToWatchScreenState();
}

class _WhereToWatchScreenState extends ConsumerState<WhereToWatchScreen> {
  late final YoutubePlayerController _ytController;

  TMDBMovieDetailModel? _details;
  Map<String, dynamic>? _providersRaw;
  String? _youtubeKey;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        enableCaption: true,
        strictRelatedVideos: true,
        playsInline: true,
      ),
    );
    _load();
  }

  Future<void> _load() async {
    try {
      final tmdb = ref.read(_tmdbServiceProvider);
      final details = await tmdb.getMovieDetails(widget.movieId);
      final providers = await tmdb.getWatchProviders(widget.movieId);

      // Pick first YouTube trailer if available
      final ytKey = details.videos?.results
          ?.where((v) => v.site.toLowerCase() == 'youtube')
          .where((v) => v.type.toLowerCase() == 'trailer')
          .map((v) => v.key)
          .cast<String>()
          .firstOrNull;

      setState(() {
        _details = details;
        _providersRaw = providers;
        _youtubeKey = ytKey;
        _loading = false;
      });

      if (ytKey != null) {
        _ytController.loadVideoById(videoId: ytKey);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ytController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Where to watch')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            )
          : _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final movie = _details!;
    final providers = _providersForCountry(_providersRaw, widget.countryCode);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Movie header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.posterPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  imageUrl:
                      '${Environment.tmdbImageBaseUrl}/w185${movie.posterPath}',
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: theme.textTheme.titleLarge),
                  if (movie.tagline != null && movie.tagline!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        movie.tagline!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  if (movie.releaseDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Release: ${movie.releaseDate!}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // YouTube trailer embed
        if (_youtubeKey != null) ...[
          Text('Trailer', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: _ytController),
          ),
          const SizedBox(height: 16),
        ] else ...[
          Text('No trailer available', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
        ],

        // Where to watch section
        Text(
          'Available in ${widget.countryCode}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (providers == null)
          Text('No availability info', style: theme.textTheme.bodyMedium)
        else ...[
          if (providers['link'] is String)
            _ProviderLinkTile(
              label: 'Open on TMDB',
              url: providers['link'] as String,
              leading: const Icon(Icons.open_in_new),
            ),
          if (providers['flatrate'] is List &&
              (providers['flatrate'] as List).isNotEmpty)
            _ProviderGroup(
              title: 'Stream',
              providers: (providers['flatrate'] as List)
                  .cast<Map<String, dynamic>>(),
            ),
          if (providers['ads'] is List && (providers['ads'] as List).isNotEmpty)
            _ProviderGroup(
              title: 'Ad-supported',
              providers: (providers['ads'] as List)
                  .cast<Map<String, dynamic>>(),
            ),
          if (providers['free'] is List &&
              (providers['free'] as List).isNotEmpty)
            _ProviderGroup(
              title: 'Free',
              providers: (providers['free'] as List)
                  .cast<Map<String, dynamic>>(),
            ),
          if (providers['rent'] is List &&
              (providers['rent'] as List).isNotEmpty)
            _ProviderGroup(
              title: 'Rent',
              providers: (providers['rent'] as List)
                  .cast<Map<String, dynamic>>(),
            ),
          if (providers['buy'] is List && (providers['buy'] as List).isNotEmpty)
            _ProviderGroup(
              title: 'Buy',
              providers: (providers['buy'] as List)
                  .cast<Map<String, dynamic>>(),
            ),
        ],
      ],
    );
  }

  Map<String, dynamic>? _providersForCountry(
    Map<String, dynamic>? data,
    String countryCode,
  ) {
    if (data == null) return null;
    final results = data['results'];
    if (results is! Map<String, dynamic>) return null;
    final country = results[countryCode] as Map<String, dynamic>?;
    return country;
  }
}

class _ProviderGroup extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> providers;

  const _ProviderGroup({required this.title, required this.providers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: providers.map((p) => _ProviderChip(provider: p)).toList(),
        ),
      ],
    );
  }
}

class _ProviderChip extends StatelessWidget {
  final Map<String, dynamic> provider;
  const _ProviderChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final name = provider['provider_name']?.toString() ?? 'Provider';
    final logoPath = provider['logo_path']?.toString();
    final url = provider['display_priorities'] != null
        ? null
        : null; // Placeholder; TMDB doesn't give direct deeplinks

    return InkWell(
      onTap: url != null ? () => _launchUrl(url) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: '${Environment.tmdbImageBaseUrl}/w92$logoPath',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 8),
            Text(name),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ProviderLinkTile extends StatelessWidget {
  final String label;
  final String url;
  final Widget? leading;

  const _ProviderLinkTile({
    required this.label,
    required this.url,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: Text(label),
      subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
