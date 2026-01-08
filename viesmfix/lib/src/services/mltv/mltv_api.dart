import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'genre_helper.dart';

/// Minimal reusable API wrapper for MLegacyTV content.
///
/// Pass an initialized `SupabaseClient` from `supabase_flutter`.
class MLTVApi {
  final SupabaseClient supabase;
  MLTVApi(this.supabase);

  Future<T> _withPublishedFallback<T>(
    Future<T> Function(bool usePublished) run,
  ) async {
    try {
      return await run(true);
    } on PostgrestException catch (e) {
      if (e.code == '42703' || (e.message).toString().contains('published')) {
        return await run(false);
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _tryOrderColumns(
    List<String> columns,
    Future<List<dynamic>> Function(String column, bool ascending) run, {
    bool ascending = false,
  }) async {
    for (final col in columns) {
      try {
        final res = await run(col, ascending);
        return List<Map<String, dynamic>>.from(res);
      } on PostgrestException catch (e) {
        if (e.code == '42703') {
          // Try next column
          continue;
        }
        rethrow;
      }
    }
    // As a last resort, run without ordering
    try {
      final res = await run('', ascending);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      rethrow;
    }
  }

  // Movies: paged list with optional title query
  Future<List<Map<String, dynamic>>> getMoviesPaged({
    int page = 1,
    int limit = 30,
    String query = '',
  }) async {
    return _withPublishedFallback((usePublished) async {
      var qb = supabase.from('movies').select('*');
      if (usePublished) qb = qb.eq('published', true);
      if (query.isNotEmpty) qb = qb.ilike('title', '%$query%');
      return _tryOrderColumns(['created_at', 'date', 'updated_at', 'id'], (
        col,
        asc,
      ) async {
        final base = (col.isNotEmpty) ? qb.order(col, ascending: false) : qb;
        final res = await base.range((page - 1) * limit, page * limit - 1);
        return res;
      });
    });
  }

  // Series: paged list with optional title query
  Future<List<Map<String, dynamic>>> getSeriesPaged({
    int page = 1,
    int limit = 30,
    String query = '',
  }) async {
    return _withPublishedFallback((usePublished) async {
      var qb = supabase.from('series').select('*');
      if (usePublished) qb = qb.eq('published', true);
      if (query.isNotEmpty) qb = qb.ilike('title', '%$query%');
      return _tryOrderColumns(['created_at', 'date', 'updated_at', 'id'], (
        col,
        asc,
      ) async {
        final base = (col.isNotEmpty) ? qb.order(col, ascending: false) : qb;
        final res = await base.range((page - 1) * limit, page * limit - 1);
        return res;
      });
    });
  }

  // Detail: try movie, then series (with seasons and episodes)
  Future<Map<String, dynamic>?> getDetail(String id) async {
    final movie = await _withPublishedFallback((usePublished) async {
      var q = supabase.from('movies').select('*').eq('id', id);
      if (usePublished) q = q.eq('published', true);
      return await q.maybeSingle();
    });
    if (movie != null) return Map<String, dynamic>.from(movie);

    final series = await _withPublishedFallback((usePublished) async {
      // Apply filters first, then ordering to avoid builder type changes
      var q = supabase
          .from('series')
          .select('*, seasons(*, episodes(*))')
          .eq('id', id);
      if (usePublished) {
        q = q
            .eq('seasons.published', true)
            .eq('seasons.episodes.published', true);
      }
      final ordered = q
          .order('order', referencedTable: 'seasons')
          .order('order', referencedTable: 'seasons.episodes', ascending: true);
      return await ordered.maybeSingle();
    });
    if (series != null) return Map<String, dynamic>.from(series);
    return null;
  }

  // Similar by genre: client-side filter fallback
  Future<List<Map<String, dynamic>>> getSimilar(String id) async {
    Map<String, dynamic>? original = await supabase
        .from('movies')
        .select('id, genre, type')
        .eq('id', id)
        .maybeSingle();

    original ??= await supabase
        .from('series')
        .select('id, genre, type')
        .eq('id', id)
        .maybeSingle();

    if (original == null) return const [];

    final isSeries =
        (original['type']?.toString() ?? '').toLowerCase() == 'serie';
    final table = isSeries ? 'series' : 'movies';

    final genres = GenreHelper.extractGenreNames(
      original['genre'] as List<dynamic>?,
    );

    final results = await _withPublishedFallback((usePublished) async {
      var qb = supabase.from(table).select('*').neq('id', id);
      if (usePublished) qb = qb.eq('published', true);
      return _tryOrderColumns(['created_at', 'date', 'updated_at', 'id'], (
        col,
        asc,
      ) async {
        final base = (col.isNotEmpty) ? qb.order(col, ascending: false) : qb;
        final res = await base.limit(100);
        return res;
      });
    });

    if (genres.isEmpty) return results.take(25).toList();
    var list = results
        .where((m) => GenreHelper.containsGenre(m, genres.first))
        .toList();
    if (list.length < 25) {
      for (final g in genres.skip(1)) {
        list.addAll(results.where((m) => GenreHelper.containsGenre(m, g)));
        if (list.length >= 25) break;
      }
    }
    if (list.length > 25) list = list.take(25).toList();
    return list;
  }

  Future<List<String>> getMovieGenres() async {
    final res = await _withPublishedFallback((usePublished) async {
      var q = supabase.from('movies').select('genre').not('genre', 'is', null);
      if (usePublished) q = q.eq('published', true);
      return await q;
    });
    final set = <String>{};
    for (final item in res) {
      final names = GenreHelper.extractGenreNames(
        item['genre'] as List<dynamic>?,
      );
      set.addAll(names);
    }
    final out = set.toList()..sort();
    return out;
  }

  // Movies by genre: fetch extra and filter client-side to ensure enough results
  Future<List<Map<String, dynamic>>> getMoviesByGenre({
    String? genre,
    int page = 1,
    int limit = 30,
  }) async {
    final fetchLimit = (genre == null || genre.isEmpty) ? limit : limit * 3;
    final res = await _withPublishedFallback((usePublished) async {
      var qb = supabase.from('movies').select('*');
      if (usePublished) qb = qb.eq('published', true);
      return await _tryOrderColumns(
        ['created_at', 'date', 'updated_at', 'id'],
        (col, asc) async {
          final base = (col.isNotEmpty) ? qb.order(col, ascending: false) : qb;
          final res = await base.range(
            (page - 1) * fetchLimit,
            page * fetchLimit - 1,
          );
          return res;
        },
      );
    });
    var list = List<Map<String, dynamic>>.from(res);
    if (genre != null && genre.isNotEmpty) {
      list = list.where((m) => GenreHelper.containsGenre(m, genre)).toList();
    }
    if (list.length > limit) list = list.take(limit).toList();
    return list;
  }

  // Mixed search across movies and series (simple title + optional filters)
  Future<List<Map<String, dynamic>>> search({
    String query = '',
    String? contentType, // 'movies' | 'series' | null for both
    String? genre,
    String? year, // YYYY
    String? vjId,
    String sortBy = 'date', // 'date' | 'views' | 'rating' | 'relevance'
    int limit = 30,
  }) async {
    final out = <Map<String, dynamic>>[];

    Future<List<Map<String, dynamic>>> _searchTable(String table) async {
      return _withPublishedFallback((usePublished) async {
        var qb = supabase.from(table).select('*');
        if (usePublished) qb = qb.eq('published', true);
        if (query.isNotEmpty) qb = qb.ilike('title', '%$query%');
        if (genre != null && genre.isNotEmpty) {
          qb = qb.contains('genre', [genre]);
        }
        if (year != null && year.isNotEmpty) {
          qb = qb
              .gte('date', '$year-01-01')
              .lt('date', '${int.parse(year) + 1}-01-01');
        }
        if (vjId != null && vjId.isNotEmpty) qb = qb.eq('vj', vjId);

        String orderCol = 'created_at';
        bool asc = false;
        switch (sortBy) {
          case 'views':
            orderCol = 'views';
            asc = false;
            break;
          case 'rating':
            orderCol = 'rating';
            asc = false;
            break;
          case 'date':
          default:
            orderCol = 'created_at';
            asc = false;
        }
        final fallbackCols = <String>{orderCol};
        // Add sensible fallbacks if selected column is missing
        if (orderCol == 'created_at' || orderCol == 'date') {
          fallbackCols.addAll(['date', 'updated_at', 'id']);
        } else if (orderCol == 'views' || orderCol == 'rating') {
          fallbackCols.addAll(['updated_at', 'created_at', 'id']);
        }

        return _tryOrderColumns(fallbackCols.toList(), (col, ascending) async {
          final base = (col.isNotEmpty) ? qb.order(col, ascending: asc) : qb;
          final res = await base.limit(limit);
          return res;
        }, ascending: asc);
      });
    }

    if (contentType != 'series') {
      out.addAll(await _searchTable('movies'));
    }
    if (contentType != 'movies') {
      out.addAll(await _searchTable('series'));
    }

    if (sortBy == 'relevance' && query.isNotEmpty) {
      final q = query.toLowerCase();
      out.sort((a, b) {
        final at = (a['title'] ?? '').toString().toLowerCase();
        final bt = (b['title'] ?? '').toString().toLowerCase();
        if (at == q && bt != q) return -1;
        if (bt == q && at != q) return 1;
        if (at.startsWith(q) && !bt.startsWith(q)) return -1;
        if (bt.startsWith(q) && !at.startsWith(q)) return 1;
        return at.compareTo(bt);
      });
    }
    return out.take(limit).toList();
  }

  // Search suggestions: titles, VJs, years, common genres
  Future<List<String>> getSearchSuggestions(String query) async {
    final suggestions = <String>[];
    if (query.trim().length < 2) return suggestions;

    final movieTitles = await _withPublishedFallback((usePublished) async {
      var qb = supabase
          .from('movies')
          .select('title')
          .ilike('title', '%$query%');
      if (usePublished) qb = qb.eq('published', true);
      return await qb.limit(5);
    });
    final seriesTitles = await _withPublishedFallback((usePublished) async {
      var qb = supabase
          .from('series')
          .select('title')
          .ilike('title', '%$query%');
      if (usePublished) qb = qb.eq('published', true);
      return await qb.limit(5);
    });
    final vjNames = await supabase
        .from('vjs')
        .select('name')
        .ilike('name', '%$query%')
        .limit(3);

    for (final m in movieTitles) {
      final t = m['title'];
      if (t != null) suggestions.add(t as String);
    }
    for (final s in seriesTitles) {
      final t = s['title'];
      if (t != null) suggestions.add(t as String);
    }
    for (final v in vjNames) {
      final n = v['name'];
      if (n != null) {
        final name = n as String;
        suggestions.add(name);
        suggestions.add('VJ $name');
      }
    }

    // Add year-like suggestions if applicable
    if (RegExp(r'^\d{1,4}\n?$').hasMatch(query)) {
      final years = <String>{};
      final recent = await supabase
          .from('movies')
          .select('date')
          .not('date', 'is', null)
          .order('date', ascending: false)
          .limit(20);
      for (final r in recent) {
        final d = r['date'];
        if (d != null) {
          final y = DateTime.parse(d as String).year.toString();
          if (y.contains(query)) years.add(y);
        }
      }
      suggestions.addAll(years.take(3));
    }

    // Add some common genres matching query
    const common = [
      'Action',
      'Comedy',
      'Drama',
      'Horror',
      'Romance',
      'Thriller',
      'Adventure',
      'Animation',
      'Documentary',
      'Fantasy',
    ];
    for (final g in common) {
      if (g.toLowerCase().contains(query.toLowerCase())) suggestions.add(g);
    }

    return suggestions.toSet().take(8).toList();
  }

  // Latest content: prefer movies, fallback to series if empty
  Future<List<Map<String, dynamic>>> getLatest({
    int page = 1,
    int limit = 30,
  }) async {
    final movies = await getMoviesPaged(page: page, limit: limit);
    if (movies.isNotEmpty) return movies;
    final series = await getSeriesPaged(page: page, limit: limit);
    return series;
  }
}
