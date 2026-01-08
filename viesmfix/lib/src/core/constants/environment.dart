abstract class Environment {
  // These values should be set via --dart-define flags or environment variables
  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isDebug = !isProduction;

  // TMDB Configuration
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // App Configuration
  static const String appName = 'ViesMFix';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Feature Flags
  static const bool enableSocialFeatures = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false;
  static const bool enableNews = true;
  static const bool enableSports = true;
  static const bool enableGamification = true;
  static const bool enableWatchParties = true;

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiConnectTimeout = Duration(seconds: 10);
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  // Cache Configuration
  static const Duration cacheDuration = Duration(hours: 6);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int trendingPageSize = 10;
  static const int searchPageSize = 20;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;

  // Images
  static const Map<String, String> imageSizes = {
    'poster': 'w342',
    'backdrop': 'w780',
    'profile': 'w185',
    'logo': 'w300',
    'original': 'original',
  };

  // Localization
  static const String defaultLanguage = 'en-US';

  // Performance
  static const double scrollThreshold = 0.8;
  static const int preloadItems = 3;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // UI Constants
  static const double cardAspectRatio = 0.67; // 2:3
  static const double desktopBreakpoint = 1024;
  static const double tabletBreakpoint = 768;
  static const double mobileBreakpoint = 480;

  // Default values
  static const String defaultAvatarUrl =
      'https://ui-avatars.com/api/?name=User&background=0F0F0F&color=fff';

  // Edge Function names (override via --dart-define if your deployment differs)
  static const String newsFunctionName = String.fromEnvironment(
    'NEWS_FUNCTION_NAME',
    defaultValue: 'news-proxy',
  );
  static const String sportsFunctionName = String.fromEnvironment(
    'SPORTS_FUNCTION_NAME',
    defaultValue: 'sports-api',
  );
}
