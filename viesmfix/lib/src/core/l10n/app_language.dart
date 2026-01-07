import 'package:flutter/material.dart';

/// Supported languages in the app
enum AppLanguage {
  english('en', 'English', '🇬🇧'),
  spanish('es', 'Español', '🇪🇸'),
  french('fr', 'Français', '🇫🇷'),
  german('de', 'Deutsch', '🇩🇪'),
  japanese('ja', '日本語', '🇯🇵'),
  arabic('ar', 'العربية', '🇸🇦'),
  portuguese('pt', 'Português', '🇧🇷'),
  chinese('zh', '中文', '🇨🇳');

  final String code;
  final String nativeName;
  final String flag;

  const AppLanguage(this.code, this.nativeName, this.flag);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  static AppLanguage fromLocale(Locale locale) {
    return fromCode(locale.languageCode);
  }

  /// Get text direction for the language
  TextDirection get textDirection {
    return this == AppLanguage.arabic ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Check if language is RTL
  bool get isRTL => textDirection == TextDirection.rtl;
}

/// Extension to get supported locales
extension AppLanguageList on List<AppLanguage> {
  List<Locale> get locales => map((lang) => lang.locale).toList();
}
