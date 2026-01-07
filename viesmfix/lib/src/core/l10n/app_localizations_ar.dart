// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ViesMFix';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get watchlist => 'قائمتي';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get systemDefault => 'افتراضي النظام';

  @override
  String get trending => 'الشائع';

  @override
  String get popular => 'الأكثر شعبية';

  @override
  String get topRated => 'الأعلى تقييماً';

  @override
  String get upcomingMovies => 'قريباً';

  @override
  String get nowPlaying => 'يُعرض الآن';

  @override
  String get searchMovies => 'ابحث عن الأفلام...';

  @override
  String get noResults => 'لم يتم العثور على نتائج';

  @override
  String get tryDifferentSearch => 'جرب كلمة بحث مختلفة';

  @override
  String get addToWatchlist => 'أضف إلى قائمتي';

  @override
  String get removeFromWatchlist => 'إزالة من قائمتي';

  @override
  String get rateMovie => 'قيم الفيلم';

  @override
  String get writeReview => 'اكتب مراجعة';

  @override
  String get share => 'مشاركة';

  @override
  String get watchTrailer => 'شاهد الإعلان';

  @override
  String get moodMatcher => 'كاشف المزاج';

  @override
  String get howAreYouFeeling => 'كيف تشعر؟';

  @override
  String get watchParties => 'حفلات المشاهدة';

  @override
  String get createParty => 'إنشاء حفلة';

  @override
  String get joinParty => 'انضم إلى حفلة';

  @override
  String get trivia => 'معلومات عامة';

  @override
  String get startQuiz => 'ابدأ الاختبار';

  @override
  String get yourScore => 'نقاطك';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get level => 'المستوى';

  @override
  String get streak => 'السلسلة';

  @override
  String daysStreak(int count) {
    return '$count أيام';
  }

  @override
  String get movieDNA => 'الحمض النووي للأفلام';

  @override
  String get yourTasteProfile => 'ملف تعريف ذوقك';

  @override
  String get journal => 'اليوميات';

  @override
  String get addEntry => 'أضف إدخالاً';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'التسجيل';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get continueWithGoogle => 'متابعة مع Google';

  @override
  String get continueWithApple => 'متابعة مع Apple';

  @override
  String get genres => 'الأنواع';

  @override
  String get cast => 'الممثلون';

  @override
  String get director => 'المخرج';

  @override
  String get releaseDate => 'تاريخ الإصدار';

  @override
  String get runtime => 'المدة';

  @override
  String minutesShort(int count) {
    return '$countد';
  }

  @override
  String get rating => 'التقييم';

  @override
  String get reviews => 'المراجعات';

  @override
  String get similarMovies => 'أفلام مشابهة';

  @override
  String get recommendations => 'التوصيات';

  @override
  String get favorites => 'المفضلة';

  @override
  String get filters => 'الفلاتر';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get apply => 'تطبيق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get news => 'News';

  @override
  String get newsHeadlines => 'Headlines';

  @override
  String get newsSearch => 'Search News';

  @override
  String get newsBookmarks => 'Bookmarked Articles';

  @override
  String get newsGeneral => 'General';

  @override
  String get newsTechnology => 'Technology';

  @override
  String get newsSports => 'Sports';

  @override
  String get newsBusiness => 'Business';

  @override
  String get newsEntertainment => 'Entertainment';

  @override
  String get newsScience => 'Science';

  @override
  String get newsHealth => 'Health';

  @override
  String get newsNoArticles => 'No news articles found';

  @override
  String get newsLoadFailed => 'Failed to load news';

  @override
  String get newsSearchPlaceholder => 'Search news...';

  @override
  String get newsNoBookmarks => 'No bookmarks yet';

  @override
  String get newsBookmarkHint => 'Bookmark articles to read later';

  @override
  String get newsReadFullArticle => 'Read Full Article';

  @override
  String get newsShare => 'Share Article';

  @override
  String get newsRemoveBookmark => 'Remove Bookmark';

  @override
  String get newsRemoveBookmarkMessage => 'Remove this article from bookmarks?';

  @override
  String get newsRateLimitError => 'Rate Limit Exceeded';

  @override
  String get newsConnectionError => 'Connection Error';

  @override
  String get newsAuthError => 'Authentication Error';
}
