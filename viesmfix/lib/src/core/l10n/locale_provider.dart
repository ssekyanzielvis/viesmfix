import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_language.dart';

/// Provider for managing app locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(AppLanguage.english.locale) {
    _loadSavedLocale();
  }

  static const _localeKey = 'app_locale';

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        final language = AppLanguage.fromCode(languageCode);
        state = language.locale;
      }
    } catch (e) {
      // Use default if loading fails
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Continue even if saving fails
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    await setLocale(language.locale);
  }

  AppLanguage get currentLanguage => AppLanguage.fromLocale(state);
}
