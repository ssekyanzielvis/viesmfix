import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'src/services/supabase_service.dart';
import 'src/core/constants/environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if configured
  if (Environment.supabaseUrl.isNotEmpty &&
      Environment.supabaseAnonKey.isNotEmpty) {
    try {
      await SupabaseService.initialize();
      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Supabase initialization failed: $e');
        print('App will run with limited functionality (TMDB only)');
      }
    }
  } else {
    if (kDebugMode) {
      print(
        'ℹ️ Supabase not configured. Authentication and social features will be unavailable.',
      );
      print(
        'To enable: Add SUPABASE_URL and SUPABASE_ANON_KEY to environment.dart',
      );
    }
  }

  // Error handling
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  runApp(const ProviderScope(child: ViesMFixApp()));
}
