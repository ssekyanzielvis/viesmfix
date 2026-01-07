/// Route constants for navigation
class Routes {
  Routes._();

  // Auth routes
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';

  // Main app routes
  static const String home = '/';
  static const String movieDetail = '/movie';
  static const String search = '/search';
  static const String watchlist = '/watchlist';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Movie related
  static String getMovieDetailPath(int movieId) => '/movie/$movieId';

  // Social routes
  static const String userProfile = '/user';
  static String getUserProfilePath(String userId) => '/user/$userId';

  // Collections
  static const String lists = '/lists';
  static String getListPath(String listId) => '/lists/$listId';

  // News routes
  static const String news = '/news';
  static const String newsSearch = '/news/search';
  static const String newsBookmarks = '/news/bookmarks';
  static const String newsArticle = '/news/article';
}
