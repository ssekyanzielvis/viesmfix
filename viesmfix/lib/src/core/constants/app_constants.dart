class AppConstants {
  static const String appTitle = 'ViesMFix';

  // Navigation
  static const String homeRoute = '/';
  static const String movieDetailRoute = '/movie/:id';
  static const String searchRoute = '/search';
  static const String watchlistRoute = '/watchlist';
  static const String profileRoute = '/profile';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String settingsRoute = '/settings';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // Default values
  static const int maxWatchlistItems = 1000;
  static const int maxRatingValue = 10;
  static const int minRatingValue = 1;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
  static const String authErrorMessage =
      'Authentication failed. Please login again.';
}
