import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/environment.dart';

/// Provides a SupabaseClient for the video URL database
final videoSupabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final url = Environment.supabaseVideoUrl.trim();
  final key = Environment.supabaseVideoAnonKey.trim();
  if (url.isNotEmpty && key.isNotEmpty) {
    return SupabaseClient(url, key);
  }
  return null;
});
