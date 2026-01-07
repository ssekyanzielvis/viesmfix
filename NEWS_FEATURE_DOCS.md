# News Feature Documentation

## Overview

The Viesmfix News feature provides a comprehensive news streaming experience integrated seamlessly with the existing movie entertainment app. Users can browse, search, bookmark, and share news articles from various categories.

## Architecture

### Security-First Design

```
Flutter App → Supabase Edge Function → NewsAPI.org
```

The architecture ensures:
- ✅ API key is never exposed to the client
- ✅ Secure server-side proxy pattern
- ✅ CORS properly configured
- ✅ Rate limiting handled server-side
- ✅ Caching to minimize API calls

### Components

#### 1. Domain Layer
- **Entities**: `NewsArticleEntity`, `NewsSourceEntity`, `BookmarkedArticleEntity`
- **Repository Interface**: `NewsRepository` - defines all news operations
- **Use Cases**: `GetTopHeadlines`, `SearchNews`, `BookmarkArticle`, `RemoveBookmark`, `GetBookmarkedArticles`

#### 2. Data Layer
- **Models**: `NewsArticleModel`, `NewsSourceModel` - JSON serialization
- **Data Sources**:
  - `NewsRemoteDataSource` - communicates with Supabase Edge Functions
  - `NewsLocalDataSource` - handles caching and bookmarks
- **Repository Implementation**: `NewsRepositoryImpl` - coordinates data sources

#### 3. Presentation Layer
- **Providers**: Riverpod state management
  - `newsProvider` - manages news state
  - `bookmarkedArticlesProvider` - manages bookmarks
- **Screens**:
  - `NewsScreen` - main news feed with categories
  - `NewsSearchScreen` - search with filters
  - `NewsBookmarksScreen` - saved articles
  - `NewsArticleDetailScreen` - full article view

#### 4. Backend
- **Edge Function**: `news-proxy` - secure NewsAPI.org proxy
- **CORS Configuration**: enables client-server communication
- **Environment Secrets**: NEWS_API_KEY stored securely

## Features

### 📰 Browse News by Category
- General
- Business
- Entertainment
- Health
- Science
- Sports
- Technology

### 🔍 Advanced Search
- Full-text search across all articles
- Date range filtering (from/to dates)
- Sort options:
  - Published Date (newest first)
  - Relevancy
  - Popularity
- Pagination with infinite scroll

### 🔖 Bookmarks
- Save articles for offline reading
- Local storage with SharedPreferences
- Quick access to saved articles
- Remove bookmarks with confirmation

### 🔗 Share
- Share article title and URL
- Native share sheet integration
- Copy link functionality

### 📱 UI/UX Features
- Tab-based category navigation
- Pull-to-refresh
- Infinite scroll pagination
- Loading states
- Empty states
- Error handling with retry
- Image caching
- Responsive design

### ⚡ Performance
- 15-minute cache for headlines
- Automatic cache expiration
- Image lazy loading
- Pagination (20 articles per page)
- Optimized network calls

## File Structure

```
lib/src/
├── domain/
│   ├── entities/
│   │   └── news_article_entity.dart       # Core entities
│   ├── repositories/
│   │   └── news_repository.dart           # Repository interface
│   └── usecases/
│       └── news_usecases.dart             # Business logic
├── data/
│   ├── models/
│   │   └── news_article_model.dart        # JSON models
│   ├── datasources/
│   │   ├── news_remote_datasource.dart    # API calls
│   │   └── news_local_datasource.dart     # Cache & bookmarks
│   └── repositories/
│       └── news_repository_impl.dart      # Repository implementation
├── presentation/
│   ├── providers/
│   │   └── news_providers.dart            # Riverpod providers
│   └── screens/
│       ├── news_screen.dart               # Main feed
│       ├── news_search_screen.dart        # Search
│       ├── news_bookmarks_screen.dart     # Bookmarks
│       └── news_article_detail_screen.dart # Article detail
└── core/
    └── constants/
        └── environment.dart               # Configuration

supabase/
└── functions/
    ├── _shared/
    │   └── cors.ts                        # CORS config
    └── news-proxy/
        └── index.ts                       # Edge Function
```

## Setup

### 1. Get NewsAPI.org Key
```bash
# Sign up at https://newsapi.org/
# Copy your API key
```

### 2. Deploy Edge Function
```bash
cd supabase/functions
supabase functions deploy news-proxy --project-ref YOUR_PROJECT_REF
```

### 3. Set Secrets
```bash
supabase secrets set NEWS_API_KEY=your_api_key --project-ref YOUR_PROJECT_REF
```

### 4. Configure Flutter
Update `environment.dart` or use dart-define:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Add to Navigation
```dart
// In your router
'/news': (context) => const NewsScreen(),
'/news/search': (context) => const NewsSearchScreen(),
'/news/bookmarks': (context) => const NewsBookmarksScreen(),
'/news/article': (context) {
  final article = ModalRoute.of(context)!.settings.arguments as NewsArticleEntity;
  return NewsArticleDetailScreen(article: article);
},
```

## Usage Examples

### Browse Headlines
```dart
// Automatically loads on screen mount
// Users can swipe between category tabs
// Pull to refresh
// Infinite scroll for more articles
```

### Search Articles
```dart
// 1. Tap search icon in AppBar
// 2. Enter search query
// 3. Optional: Apply filters (date range, sort)
// 4. View results with pagination
```

### Bookmark Article
```dart
// On any article card or detail screen
// Tap bookmark icon
// Article saved locally
// Access from bookmarks screen
```

### Share Article
```dart
// On article detail screen
// Tap share icon
// Native share sheet opens
// Share title + URL
```

## API Reference

### NewsRepository

#### `getTopHeadlines`
Fetches top headlines by category.

```dart
Future<Either<Failure, List<NewsArticleEntity>>> getTopHeadlines({
  NewsCategory? category,
  String? country,
  int page = 1,
  int pageSize = 20,
});
```

#### `searchNews`
Searches for articles matching query.

```dart
Future<Either<Failure, List<NewsArticleEntity>>> searchNews({
  required String query,
  DateTime? from,
  DateTime? to,
  String? sortBy,
  int page = 1,
  int pageSize = 20,
});
```

#### `bookmarkArticle`
Saves article to bookmarks.

```dart
Future<Either<Failure, void>> bookmarkArticle(NewsArticleEntity article);
```

#### `removeBookmark`
Removes article from bookmarks.

```dart
Future<Either<Failure, void>> removeBookmark(String articleId);
```

#### `getBookmarkedArticles`
Retrieves all bookmarked articles.

```dart
Future<Either<Failure, List<BookmarkedArticleEntity>>> getBookmarkedArticles();
```

## Customization

### Change Cache Duration
In `news_local_datasource.dart`:
```dart
static const int _cacheDurationMinutes = 15; // Change this
```

### Change Page Size
In any screen:
```dart
ref.read(newsProvider.notifier).fetchTopHeadlines(
  category: category,
  page: page,
  pageSize: 30, // Default is 20
);
```

### Add New Categories
In `news_article_entity.dart`:
```dart
enum NewsCategory {
  // ... existing categories
  yourCategory('your-key', 'Your Display Name'),
}
```

### Customize UI
All screens are customizable:
- Card designs in `NewsArticleCard`
- Colors follow app theme
- Layouts responsive
- Font sizes adjustable

## Rate Limits

### NewsAPI.org Free Tier
- **100 requests/day**
- Last 30 days of articles only
- 250 articles per request max

### Mitigation Strategies
1. **Caching**: Headlines cached 15 minutes
2. **Pagination**: 20 articles per page
3. **User Throttling**: Debounce search
4. **Production**: Upgrade to paid tier ($449/month)

### Monitoring Usage
```bash
# Check Edge Function logs
supabase functions logs news-proxy
```

## Error Handling

### Common Errors

#### "Failed to fetch news"
- **Cause**: Network error, Edge Function down, API key invalid
- **Solution**: Check logs, verify secrets, test Edge Function

#### "Rate limit exceeded"
- **Cause**: > 100 requests in 24 hours
- **Solution**: Wait 24 hours, check cache, upgrade tier

#### "No articles found"
- **Cause**: Query too specific, category empty
- **Solution**: Try broader search, different category

#### CORS errors
- **Cause**: CORS not configured, wrong headers
- **Solution**: Verify cors.ts, redeploy function

## Testing

### Unit Tests
```dart
// Test use cases
test('should fetch top headlines', () async {
  final result = await getTopHeadlines(category: NewsCategory.technology);
  expect(result.isRight(), true);
});

// Test repository
test('should cache articles', () async {
  await repository.getTopHeadlines(category: NewsCategory.sports);
  final cached = await localDataSource.getCachedArticles('headlines_sports_us_1');
  expect(cached, isNotNull);
});
```

### Widget Tests
```dart
// Test news screen
testWidgets('displays articles', (tester) async {
  await tester.pumpWidget(ProviderScope(child: NewsScreen()));
  await tester.pumpAndSettle();
  expect(find.byType(NewsArticleCard), findsWidgets);
});
```

### Integration Tests
```dart
// Test full flow
testWidgets('bookmark flow', (tester) async {
  // 1. Open article
  // 2. Tap bookmark
  // 3. Navigate to bookmarks
  // 4. Verify article appears
});
```

## Performance Optimization

### Image Loading
- Uses `Image.network` with error handling
- Consider switching to `CachedNetworkImage`
- Lazy loading in lists
- Placeholder for broken images

### Memory Management
- Dispose controllers in `dispose()`
- Cancel subscriptions
- Clear cache periodically

### Network Optimization
- Cache aggressively
- Batch requests when possible
- Use compression
- Implement retry logic

## Security Considerations

### ✅ Implemented
- API key in Edge Functions (never in client)
- CORS configured properly
- Input validation on Edge Function
- HTTPS only

### 🔒 Recommended
- Rate limit per user (if auth enabled)
- Sanitize article content
- Validate URLs before opening
- Monitor for abuse

## Roadmap

### Phase 1 (Current)
- ✅ Basic news feed
- ✅ Category browsing
- ✅ Search
- ✅ Bookmarks
- ✅ Share

### Phase 2 (Future)
- [ ] Personalized feed based on reading history
- [ ] Push notifications for breaking news
- [ ] Offline mode with full article caching
- [ ] Reading time estimates
- [ ] Text-to-speech

### Phase 3 (Advanced)
- [ ] Sentiment analysis
- [ ] Related articles
- [ ] Topic clustering
- [ ] Save to collections
- [ ] Social sharing stats

## Troubleshooting

### Enable Debug Logs
```dart
// In news_remote_datasource.dart
dio.interceptors.add(LogInterceptor(
  request: true,
  requestBody: true,
  responseBody: true,
));
```

### Check Cache
```dart
// In news_local_datasource.dart
Future<void> debugCache() async {
  final keys = prefs.getKeys();
  print('Cached keys: $keys');
}
```

### Test Edge Function
```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/news-proxy/top-headlines' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"category": "technology", "country": "us"}'
```

## Contributing

### Adding Features
1. Create branch: `feature/news-your-feature`
2. Implement with tests
3. Update documentation
4. Submit PR

### Reporting Bugs
1. Check existing issues
2. Provide reproduction steps
3. Include logs and screenshots
4. Mention device/OS

## License

Part of the Viesmfix project. See root LICENSE file.

## Credits

- **NewsAPI.org**: News data provider
- **Supabase**: Backend infrastructure
- **Flutter**: UI framework
- **Riverpod**: State management

## Support

For issues or questions:
1. Check documentation
2. Review setup guide
3. Search existing issues
4. Create new issue with details

---

**Last Updated**: 2024
**Version**: 1.0.0
**Status**: Production Ready
