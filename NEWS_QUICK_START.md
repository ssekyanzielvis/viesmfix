# News Feature - Quick Start Guide

## 📋 Pre-Deployment Checklist

### 1. Environment Setup ✅
- [ ] Get NewsAPI.org API key from https://newsapi.org/
- [ ] Have Supabase project ready
- [ ] Have Supabase service role key

### 2. Backend Setup (5 minutes)

#### A. Database Migration
```bash
cd viesmfix
supabase db push
```

This creates:
- `news_cache` table for server-side caching
- Cache management functions
- RLS policies
- Monitoring views

Verify:
```sql
-- Check table exists
SELECT * FROM news_cache LIMIT 1;

-- Check cache stats function
SELECT * FROM get_news_cache_stats();
```

#### B. Edge Function Deployment
```bash
# Set your NewsAPI key
supabase secrets set NEWSAPI_KEY=your_newsapi_key_here

# Set Supabase service role key (found in Supabase Dashboard > Settings > API)
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# Deploy the function
supabase functions deploy news-proxy
```

Verify:
```bash
# Test the function
curl -X POST https://your-project.supabase.co/functions/v1/news-proxy \
  -H "Content-Type: application/json" \
  -d '{"endpoint":"top-headlines","category":"technology"}'
```

### 3. Flutter App Setup (2 minutes)

#### A. Install Dependencies
```bash
cd viesmfix
flutter pub get
```

#### B. Generate Localizations
```bash
flutter gen-l10n
```

This generates AppLocalizations from the .arb files.

#### C. Update Environment (if needed)
File: `lib/src/core/constants/environment.dart`
```dart
static const bool enableNews = true; // Already set ✅
```

### 4. Testing (5 minutes)

#### A. Run the App
```bash
flutter run
```

#### B. Test Checklist
- [ ] News feed loads with articles
- [ ] Category tabs switch correctly
- [ ] Pull-to-refresh works
- [ ] Infinite scroll loads more articles
- [ ] Search finds articles
- [ ] Filter by date/sort works
- [ ] Bookmark articles
- [ ] View bookmarked articles
- [ ] Share article
- [ ] Open article in browser
- [ ] Responsive layout on tablet/desktop

#### C. Test Responsive Design
- Mobile (360x800): `flutter run -d chrome --web-browser-flag "--window-size=360,800"`
- Tablet (768x1024): `flutter run -d chrome --web-browser-flag "--window-size=768,1024"`
- Desktop (1920x1080): `flutter run -d chrome --web-browser-flag "--window-size=1920,1080"`

#### D. Test Caching
1. Load news feed (should see X-Cache: MISS header)
2. Reload within 15 minutes (should see X-Cache: HIT header)
3. Wait 15+ minutes and reload (should refresh with X-Cache: MISS)

Check cache in database:
```sql
SELECT cache_key, 
       data->>'status' as status,
       to_timestamp(timestamp/1000) as cached_at,
       EXTRACT(EPOCH FROM (NOW() - to_timestamp(timestamp/1000)))/60 as age_minutes
FROM news_cache
ORDER BY timestamp DESC
LIMIT 10;
```

### 5. Monitoring (Ongoing)

#### A. Cache Performance
```sql
-- Get cache statistics
SELECT * FROM get_news_cache_stats();

-- View cache distribution
SELECT * FROM cache_key_distribution;

-- View cache age
SELECT * FROM cache_entries_by_age;
```

#### B. Clear Cache (if needed)
```sql
-- Clear all cache
SELECT cleanup_old_news_cache();

-- Clear specific pattern
SELECT clear_news_cache_by_pattern('headlines_technology%');
```

Via Edge Function:
```bash
curl -X POST https://your-project.supabase.co/functions/v1/news-proxy/clear-cache
```

#### C. Monitor API Usage
NewsAPI.org free tier: 100 requests/day
- With caching: ~10-20 requests/day (80-90% cache hit rate)
- Check dashboard: https://newsapi.org/account

## 🎯 Navigation Integration

### Add News to Bottom Navigation
```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'), // ← Add this
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

### Add News to Drawer
```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        leading: Icon(Icons.newspaper),
        title: Text('News'),
        onTap: () => Navigator.pushNamed(context, '/news'),
      ),
    ],
  ),
)
```

### Navigate Programmatically
```dart
import 'package:viesmfix/src/presentation/utils/news_navigation.dart';

// Navigate to news feed
NewsNavigation.toNewsFeed(context);

// Navigate to search
NewsNavigation.toNewsSearch(context);

// Navigate to bookmarks
NewsNavigation.toNewsBookmarks(context);
```

## 🌍 Localization

News feature is localized in 8 languages:
- 🇬🇧 English (en)
- 🇪🇸 Spanish (es)
- 🇫🇷 French (fr)
- 🇩🇪 German (de)
- 🇧🇷 Portuguese (pt)
- 🇨🇳 Chinese (zh)
- 🇯🇵 Japanese (ja)
- 🇸🇦 Arabic (ar)

Strings available in AppLocalizations:
- `news`, `newsHeadlines`, `newsSearch`, `newsBookmarks`
- `newsGeneral`, `newsTechnology`, `newsSports`, etc.
- See `NEWS_LOCALIZATION_STRINGS.json` for complete list

## 📊 Analytics Integration (Optional)

File: `lib/src/presentation/utils/news_analytics.dart`

### Track Events
```dart
// Track article view
await NewsAnalytics.logArticleView(article.id, article.title);

// Track bookmark
await NewsAnalytics.logArticleBookmarked(article.id);

// Track search
await NewsAnalytics.logSearchPerformed(query, results.length);
```

### Integrate with Your Service
Update `_logEvent()` in `news_analytics.dart`:
```dart
static Future<void> _logEvent(String eventName, Map<String, dynamic> parameters) async {
  // Example: Firebase Analytics
  await FirebaseAnalytics.instance.logEvent(
    name: eventName,
    parameters: parameters,
  );
  
  // Example: Mixpanel
  // await Mixpanel.track(eventName, properties: parameters);
}
```

## 🚨 Troubleshooting

### Issue: "Failed to load news"
**Check:**
1. Edge Function deployed correctly: `supabase functions list`
2. Secrets set: `supabase secrets list`
3. NewsAPI key valid: Test at https://newsapi.org/v2/top-headlines?apiKey=YOUR_KEY&category=technology
4. Internet connection on device

### Issue: "Rate Limit Exceeded"
**Solution:**
- Check cache is working (should prevent this)
- Verify cache table exists: `SELECT * FROM news_cache;`
- Check X-Cache headers (should show HIT for cached requests)
- Clear old cache: `SELECT cleanup_old_news_cache();`

### Issue: Localization strings not showing
**Solution:**
```bash
flutter gen-l10n
flutter clean
flutter pub get
flutter run
```

### Issue: Responsive layout not working
**Check:**
1. `news_responsive_widgets.dart` imported
2. Using `ResponsiveNewsBuilder` instead of `ListView.builder`
3. Test on different screen sizes

## 🔧 Configuration

### Change Cache Duration
**Edge Function:** `supabase/functions/news-proxy/index.ts`
```typescript
const CACHE_DURATION_MS = 15 * 60 * 1000; // 15 minutes (change here)
```

**Client:** `lib/src/data/datasources/news_local_datasource.dart`
```dart
static const int cacheDurationMinutes = 15; // Change here
```

### Change Page Size
**File:** `lib/src/core/constants/environment.dart`
```dart
static const int defaultPageSize = 20; // Change here
```

### Disable News Feature
**File:** `lib/src/core/constants/environment.dart`
```dart
static const bool enableNews = false; // Set to false
```

## 📈 Performance Expectations

### Load Times
- Initial feed load: 500-800ms (cache miss)
- Cached feed load: 50-150ms (cache hit)
- Article detail: Instant (local data)
- Search: 300-600ms

### Cache Hit Rate
- Expected: 60-80%
- Monitor with: `SELECT * FROM get_news_cache_stats();`

### API Usage
- Without caching: 5-10 requests/minute
- With caching: 0.5-1 requests/minute
- Daily: 10-20 NewsAPI requests (well under 100 limit)

## ✅ Deployment Complete!

Your news feature is now live with:
- ✅ Server-side database caching (15-min duration)
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ 8-language localization
- ✅ Error handling with retry
- ✅ Bookmarking functionality
- ✅ Search with filters
- ✅ Share integration
- ✅ Category browsing
- ✅ Infinite scroll pagination

**Next Steps:**
1. Add news icon to your navigation
2. Set up analytics (optional)
3. Monitor cache performance
4. Collect user feedback

**Support:**
- News.txt: Original requirements
- NEWS_SETUP_GUIDE.md: Detailed setup
- NEWS_FEATURE_DOCS.md: Complete documentation
- COMPLETE_NEWS_IMPLEMENTATION.md: Feature summary
