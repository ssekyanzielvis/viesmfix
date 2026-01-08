import 'dart:convert';

/// Helper for normalizing and matching genres across content items.
class GenreHelper {
  /// Extract a clean genre name from a dynamic value.
  /// Supports plain strings and JSON strings like '{"id": "...", "name": "Action"}'.
  static String? extractGenreName(dynamic genre) {
    if (genre == null) return null;
    try {
      if (genre is String && genre.trim().startsWith('{')) {
        final obj = jsonDecode(genre) as Map<String, dynamic>;
        final name = obj['name']?.toString().trim();
        return (name != null && name.isNotEmpty) ? name : null;
      }
    } catch (_) {
      // fall through to string handling
    }
    final name = genre.toString().trim();
    return name.isNotEmpty ? name : null;
  }

  /// Extract list of clean genre names from a dynamic list.
  static List<String> extractGenreNames(List<dynamic>? genres) {
    if (genres == null) return const [];
    final out = <String>[];
    for (final g in genres) {
      final n = extractGenreName(g);
      if (n != null) out.add(n);
    }
    return out;
  }

  /// Check if content has a given genre (case-sensitive match on normalized names).
  static bool containsGenre(Map<String, dynamic> content, String targetGenre) {
    final raw = content['genre'] as List<dynamic>?;
    if (raw == null) return false;
    final names = extractGenreNames(raw);
    return names.contains(targetGenre);
  }
}
