import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/core/themes/app_theme.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/core/router/app_router.dart';
import 'src/core/l10n/app_language.dart';
import 'src/core/l10n/locale_provider.dart';
// TODO: Fix localization generation
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViesMFixApp extends ConsumerWidget {
  const ViesMFixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'ViesMFix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,

      // Internationalization configuration
      locale: locale,
      localizationsDelegates: const [
        // TODO: Re-enable when localization is fixed
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLanguage.values.locales,

      // Automatically determine text direction based on locale
      builder: (context, child) {
        final language = AppLanguage.fromLocale(locale);
        return Directionality(
          textDirection: language.textDirection,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
