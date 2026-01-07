# Internationalization & Localization Guide

## Overview
ViesMFix is now fully internationalized and supports 8 languages with automatic RTL (Right-to-Left) support for Arabic.

## Supported Languages

| Language | Code | Flag | Text Direction |
|----------|------|------|----------------|
| English | en | 🇬🇧 | LTR |
| Spanish | es | 🇪🇸 | LTR |
| French | fr | 🇫🇷 | LTR |
| German | de | 🇩🇪 | LTR |
| Japanese | ja | 🇯🇵 | LTR |
| Arabic | ar | 🇸🇦 | RTL |
| Portuguese | pt | 🇧🇷 | LTR |
| Chinese (Simplified) | zh | 🇨🇳 | LTR |

## Implementation Details

### File Structure
```
lib/
├── src/
│   └── core/
│       └── l10n/
│           ├── app_en.arb          # English (template)
│           ├── app_es.arb          # Spanish
│           ├── app_fr.arb          # French
│           ├── app_de.arb          # German
│           ├── app_ja.arb          # Japanese
│           ├── app_ar.arb          # Arabic (RTL)
│           ├── app_pt.arb          # Portuguese
│           ├── app_zh.arb          # Chinese
│           ├── app_language.dart   # Language enum & utilities
│           └── locale_provider.dart # State management
└── l10n.yaml                       # Configuration file
```

### ARB Files (Application Resource Bundle)
Each `.arb` file contains translations for a specific language. The English file (`app_en.arb`) serves as the template.

**Key Features:**
- **100+ translated strings** covering all app features
- **Metadata for each string** (@description fields)
- **Placeholder support** for dynamic values (e.g., `{count}`)
- **Consistent structure** across all languages

### Language Management

#### AppLanguage Enum
```dart
enum AppLanguage {
  english, spanish, french, german, 
  japanese, arabic, portuguese, chinese
}
```

**Properties:**
- `code`: Language code (e.g., 'en', 'es')
- `nativeName`: Display name in native language
- `flag`: Emoji flag for UI
- `locale`: Flutter Locale object
- `textDirection`: Automatic RTL for Arabic
- `isRTL`: Boolean helper

#### LocaleProvider (Riverpod)
Manages app-wide locale state with persistence:
- Loads saved language preference on app start
- Saves preference to SharedPreferences
- Updates entire app when language changes
- Provides `currentLanguage` helper

### UI Components

#### Language Selector Bottom Sheet
Beautiful language picker accessible from Settings:
- Shows all 8 languages with flags
- Displays native language names
- Highlights currently selected language
- Instant language switching
- Smooth animations

**Usage:**
```dart
LanguageSelectorBottomSheet.show(context);
```

#### Settings Integration
Language option added to Settings screen:
- Icon: 🌐 (language globe)
- Shows flag + native name
- Opens language selector on tap
- Positioned at top of Appearance section

### App Configuration

#### pubspec.yaml
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  
flutter:
  generate: true
```

#### l10n.yaml
```yaml
arb-dir: lib/src/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

#### MaterialApp Setup
```dart
MaterialApp.router(
  locale: locale,
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLanguage.values.locales,
  builder: (context, child) {
    // Automatic RTL support
  },
)
```

## Using Translations in Code

### 1. Import AppLocalizations
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### 2. Access Translations
```dart
final l10n = AppLocalizations.of(context)!;

Text(l10n.home)           // "Home" in current language
Text(l10n.watchlist)      // "Watchlist" in current language
Text(l10n.settings)       // "Settings" in current language
```

### 3. Placeholders
```dart
// In ARB file:
"daysStreak": "{count} days"

// In code:
Text(l10n.daysStreak(7))  // "7 days" or "7 días" etc.
```

## RTL Support

### Automatic Direction
The app automatically switches to RTL mode when Arabic is selected:
- Layout mirrors (e.g., navigation drawer on right)
- Text alignment adjusts
- Icons flip appropriately

### Testing RTL
1. Open Settings
2. Select Language
3. Choose العربية (Arabic)
4. Entire app switches to RTL instantly

## Adding New Translations

### Step 1: Add to Template
Edit `app_en.arb`:
```json
{
  "newFeature": "New Feature",
  "@newFeature": {
    "description": "Label for new feature"
  }
}
```

### Step 2: Translate in All Languages
Add to `app_es.arb`, `app_fr.arb`, etc.:
```json
{
  "newFeature": "Nueva Función"  // Spanish
}
```

### Step 3: Generate Code
```bash
flutter pub get
flutter gen-l10n
```

### Step 4: Use in Code
```dart
Text(AppLocalizations.of(context)!.newFeature)
```

## Best Practices

### ✅ Do's
1. **Always use localized strings** - Never hardcode UI text
2. **Use meaningful keys** - `addToWatchlist` not `button1`
3. **Add descriptions** - Help translators understand context
4. **Test all languages** - Verify layout doesn't break
5. **Consider text expansion** - German/French are ~30% longer than English
6. **Use placeholders** - For dynamic content like counts, dates

### ❌ Don'ts
1. **Don't concatenate strings** - Use placeholders instead
2. **Don't assume LTR** - Test with RTL languages
3. **Don't hardcode dates/times** - Use intl package formatters
4. **Don't skip context** - Add @description for translators
5. **Don't forget plurals** - Use ICU message format for counts

## Advanced Features

### Date Formatting
```dart
import 'package:intl/intl.dart';

final locale = Localizations.localeOf(context);
final dateFormat = DateFormat.yMMMd(locale.toString());
Text(dateFormat.format(DateTime.now()));
```

### Number Formatting
```dart
import 'package:intl/intl.dart';

final locale = Localizations.localeOf(context);
final numberFormat = NumberFormat.decimalPattern(locale.toString());
Text(numberFormat.format(1234567.89));
```

### Plural Forms
In ARB file:
```json
{
  "movieCount": "{count, plural, =0{No movies} =1{1 movie} other{{count} movies}}",
  "@movieCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

## Regional Considerations

### Spanish (es)
- Used in Spain and Latin America
- Consider regional variations (es_ES, es_MX)

### Portuguese (pt)
- Brazilian Portuguese (pt_BR) vs European (pt_PT)
- Current implementation uses pt_BR

### Chinese (zh)
- Simplified Chinese (zh_CN) implemented
- Consider Traditional Chinese (zh_TW) for Taiwan/Hong Kong

### Arabic (ar)
- Modern Standard Arabic implemented
- Consider dialects (ar_EG, ar_SA) for specific regions

## Performance

### Code Generation
- Translations compiled at build time
- Zero runtime overhead
- Type-safe access to all strings

### Lazy Loading
- Only active locale loaded in memory
- Instant switching between languages

### Persistence
- Language preference saved to SharedPreferences
- Restored on app launch
- Survives app restarts

## Testing

### Manual Testing
1. Change language in Settings
2. Navigate through all screens
3. Verify:
   - Text displays correctly
   - Layout doesn't break
   - RTL works for Arabic
   - Icons/images are appropriate

### Automated Testing
```dart
testWidgets('Language switching works', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: ViesMFixApp(),
    ),
  );
  
  // Test language switching
  final container = ProviderContainer();
  await container.read(localeProvider.notifier)
    .setLanguage(AppLanguage.spanish);
  
  expect(container.read(localeProvider).languageCode, 'es');
});
```

## Future Enhancements

### Additional Languages
Consider adding:
- Korean (ko) 🇰🇷
- Italian (it) 🇮🇹
- Russian (ru) 🇷🇺
- Hindi (hi) 🇮🇳
- Turkish (tr) 🇹🇷

### Professional Translation
- Current translations are machine-generated
- Recommend professional translation service
- Platforms: Lokalise, Crowdin, POEditor

### Regional Content
- Country-specific movie ratings (MPAA, FSK, BBFC)
- Regional release dates
- Local currency for pricing

### Accessibility
- Screen reader support in all languages
- Voice-over testing
- High-contrast mode compatibility

## Troubleshooting

### "AppLocalizations not found"
Run:
```bash
flutter pub get
flutter gen-l10n
```

### Translations not updating
1. Clean build: `flutter clean`
2. Regenerate: `flutter gen-l10n`
3. Restart app

### RTL layout issues
- Check Directionality widget wraps content
- Use EdgeInsetsDirectional instead of EdgeInsets
- Use AlignmentDirectional instead of Alignment

### Missing translations
- Check all ARB files have same keys
- Run `flutter gen-l10n` to see errors
- Verify JSON syntax is valid

## Resources

### Documentation
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [ICU Message Format](https://unicode-org.github.io/icu/userguide/format_parse/messages/)

### Tools
- [Flutter Intl VS Code Extension](https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl)
- [ARB Editor Online](https://arb-editor.netlify.app/)
- [Google Translate API](https://cloud.google.com/translate)

## Summary

ViesMFix now offers a **world-class internationalization system** with:
- ✅ 8 languages supported
- ✅ Automatic RTL for Arabic
- ✅ Beautiful language selector
- ✅ Persistent language preference
- ✅ Type-safe translations
- ✅ 100+ translated strings
- ✅ Zero runtime overhead
- ✅ Easy to extend

The app is ready to reach a **global audience** with proper localization for each supported region! 🌍
