import '../../core/constants/environment.dart';

class ImageUtils {
  // Get TMDB image URL
  static String getTmdbImageUrl(
    String? path, {
    String size = 'w500',
    bool isOriginal = false,
  }) {
    if (path == null || path.isEmpty) return '';

    final imageSize = isOriginal ? 'original' : size;
    return '${Environment.tmdbImageBaseUrl}/$imageSize$path';
  }

  // Get poster URL
  static String getPosterUrl(String? posterPath, {bool highQuality = false}) {
    final size = highQuality
        ? Environment.imageSizes['original']!
        : Environment.imageSizes['poster']!;
    return getTmdbImageUrl(posterPath, size: size);
  }

  // Get backdrop URL
  static String getBackdropUrl(
    String? backdropPath, {
    bool highQuality = false,
  }) {
    final size = highQuality
        ? Environment.imageSizes['original']!
        : Environment.imageSizes['backdrop']!;
    return getTmdbImageUrl(backdropPath, size: size);
  }

  // Get profile image URL
  static String getProfileUrl(String? profilePath) {
    return getTmdbImageUrl(
      profilePath,
      size: Environment.imageSizes['profile']!,
    );
  }

  // Get logo URL
  static String getLogoUrl(String? logoPath) {
    return getTmdbImageUrl(logoPath, size: Environment.imageSizes['logo']!);
  }

  // Generate placeholder avatar URL
  static String getAvatarPlaceholder(String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=0F0F0F&color=fff&size=200';
  }

  // Check if image URL is valid
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }
}
