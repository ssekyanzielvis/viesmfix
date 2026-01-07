import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'ViesMFix'**
  String get appName;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Search navigation label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Watchlist navigation label
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System default theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Trending movies section
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// Popular movies section
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Top rated movies section
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// Upcoming movies section
  ///
  /// In en, this message translates to:
  /// **'Upcoming Movies'**
  String get upcomingMovies;

  /// Now playing movies section
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search movies...'**
  String get searchMovies;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Suggestion when no results found
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// Add to watchlist action
  ///
  /// In en, this message translates to:
  /// **'Add to Watchlist'**
  String get addToWatchlist;

  /// Remove from watchlist action
  ///
  /// In en, this message translates to:
  /// **'Remove from Watchlist'**
  String get removeFromWatchlist;

  /// Rate movie action
  ///
  /// In en, this message translates to:
  /// **'Rate Movie'**
  String get rateMovie;

  /// Write review action
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// Share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Watch trailer action
  ///
  /// In en, this message translates to:
  /// **'Watch Trailer'**
  String get watchTrailer;

  /// Mood matcher feature
  ///
  /// In en, this message translates to:
  /// **'Mood Matcher'**
  String get moodMatcher;

  /// Mood matcher question
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// Watch parties feature
  ///
  /// In en, this message translates to:
  /// **'Watch Parties'**
  String get watchParties;

  /// Create party action
  ///
  /// In en, this message translates to:
  /// **'Create Party'**
  String get createParty;

  /// Join party action
  ///
  /// In en, this message translates to:
  /// **'Join Party'**
  String get joinParty;

  /// Trivia feature
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get trivia;

  /// Start quiz action
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// Quiz score label
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Achievements label
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// User level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Watch streak label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Days in streak
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysStreak(int count);

  /// Movie DNA feature
  ///
  /// In en, this message translates to:
  /// **'Movie DNA'**
  String get movieDNA;

  /// Taste profile label
  ///
  /// In en, this message translates to:
  /// **'Your Taste Profile'**
  String get yourTasteProfile;

  /// Cinematic journal feature
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// Add journal entry action
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// Sign in action
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up action
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Apple sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Genres label
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// Movie cast label
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// Movie director label
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get director;

  /// Release date label
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// Movie runtime label
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get runtime;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutesShort(int count);

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Reviews label
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Similar movies section
  ///
  /// In en, this message translates to:
  /// **'Similar Movies'**
  String get similarMovies;

  /// Recommendations section
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Favorites label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Filters label
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Sort by label
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Apply action
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Privacy label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// About label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Logout action
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Confirm action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// News navigation label
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// News headlines label
  ///
  /// In en, this message translates to:
  /// **'Headlines'**
  String get newsHeadlines;

  /// News search label
  ///
  /// In en, this message translates to:
  /// **'Search News'**
  String get newsSearch;

  /// Bookmarked news articles label
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Articles'**
  String get newsBookmarks;

  /// General news category
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get newsGeneral;

  /// Technology news category
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get newsTechnology;

  /// Sports news category
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get newsSports;

  /// Business news category
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get newsBusiness;

  /// Entertainment news category
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get newsEntertainment;

  /// Science news category
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get newsScience;

  /// Health news category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get newsHealth;

  /// Empty news state message
  ///
  /// In en, this message translates to:
  /// **'No news articles found'**
  String get newsNoArticles;

  /// News loading error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load news'**
  String get newsLoadFailed;

  /// News search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search news...'**
  String get newsSearchPlaceholder;

  /// Empty bookmarks message
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get newsNoBookmarks;

  /// Bookmark hint message
  ///
  /// In en, this message translates to:
  /// **'Bookmark articles to read later'**
  String get newsBookmarkHint;

  /// Read full article button
  ///
  /// In en, this message translates to:
  /// **'Read Full Article'**
  String get newsReadFullArticle;

  /// Share article action
  ///
  /// In en, this message translates to:
  /// **'Share Article'**
  String get newsShare;

  /// Remove bookmark dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Bookmark'**
  String get newsRemoveBookmark;

  /// Remove bookmark confirmation message
  ///
  /// In en, this message translates to:
  /// **'Remove this article from bookmarks?'**
  String get newsRemoveBookmarkMessage;

  /// Rate limit error message
  ///
  /// In en, this message translates to:
  /// **'Rate Limit Exceeded'**
  String get newsRateLimitError;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get newsConnectionError;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get newsAuthError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
