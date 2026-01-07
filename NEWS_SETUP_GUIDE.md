# News Feature Setup Guide

This guide explains how to set up and deploy the NewsAPI.org integration for the Viesmfix app.

## Overview

The news feature uses a secure architecture where:
- Flutter app → Supabase Edge Function → NewsAPI.org
- API key is stored securely in Supabase Edge Functions
- Client never has direct access to NewsAPI.org

## Prerequisites

1. **NewsAPI.org Account**
   - Sign up at https://newsapi.org/
   - Get your free API key (up to 100 requests/day)
   - Note: Free tier has limitations (last 30 days of articles, 100 requests/day)

2. **Supabase Project**
   - Create a project at https://supabase.com/
   - Note your project URL and anon key

3. **Supabase CLI**
   - Install: `npm install -g supabase`
   - Login: `supabase login`

## Setup Steps

### 1. Deploy the Edge Function

Navigate to the Supabase functions directory:
```bash
cd supabase/functions
```

Deploy the news-proxy function:
```bash
supabase functions deploy news-proxy --project-ref YOUR_PROJECT_REF
```

### 2. Set Environment Variables

Set the NewsAPI key as a secret:
```bash
supabase secrets set NEWS_API_KEY=your_newsapi_key_here --project-ref YOUR_PROJECT_REF
```

Verify the secret is set:
```bash
supabase secrets list --project-ref YOUR_PROJECT_REF
```

### 3. Configure Flutter App

Update `lib/src/core/constants/environment.dart` with your Supabase credentials:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

Or set them as environment variables when building:
```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### 4. Initialize Providers

Update your main.dart to initialize SharedPreferences for the news provider:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        newsLocalDataSourceProvider.overrideWithValue(
          NewsLocalDataSource(prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 5. Add Navigation Routes

Add news routes to your app router:

```dart
'/news': (context) => const NewsScreen(),
'/news/search': (context) => const NewsSearchScreen(),
'/news/bookmarks': (context) => const NewsBookmarksScreen(),
'/news/article': (context) {
  final article = ModalRoute.of(context)!.settings.arguments as NewsArticleEntity;
  return NewsArticleDetailScreen(article: article);
},
```

### 6. Add to Navigation

Add a news tab or menu item to your main navigation:

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.newspaper),
  label: 'News',
),
```

## Testing

### Test the Edge Function

Test locally using curl:
```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/news-proxy/top-headlines' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"category": "technology", "country": "us", "page": 1, "pageSize": 10}'
```

### Test in Flutter

1. Run the app: `flutter run`
2. Navigate to the News screen
3. Browse different categories
4. Try searching for articles
5. Bookmark articles
6. Share articles

## Features

### Categories
- General
- Business
- Entertainment
- Health
- Science
- Sports
- Technology

### Search
- Full-text search
- Date range filtering
- Sort by: publishedAt, relevancy, popularity

### Bookmarks
- Save articles locally
- Access offline
- Remove bookmarks

### Sharing
- Share article title and URL
- Native share sheet integration

## Rate Limits

**Free Tier NewsAPI:**
- 100 requests per day
- Articles from last 30 days only
- 250 articles per request max

**Caching Strategy:**
- Headlines cached for 15 minutes
- Reduces API calls
- Improves performance

**Best Practices:**
- Use pagination (20 articles per page)
- Cache aggressively
- Consider upgrading to paid tier for production

## Troubleshooting

### "Failed to fetch news"
- Check Edge Function is deployed
- Verify NEWS_API_KEY secret is set
- Check Supabase URL and anon key in Flutter app
- Verify NewsAPI.org API key is valid

### "Rate limit exceeded"
- Free tier is limited to 100 requests/day
- Wait 24 hours or upgrade to paid tier
- Check cache is working properly

### "No articles found"
- Some categories may have no recent articles
- Try a different category or country
- Search queries must match article content

### CORS errors
- Ensure cors.ts is in _shared folder
- Redeploy Edge Function
- Check browser console for specific CORS errors

## Database Schema (Optional)

For storing bookmarks in Supabase instead of local storage:

```sql
-- Create bookmarks table
CREATE TABLE news_bookmarks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  image_url TEXT,
  source_name TEXT NOT NULL,
  published_at TIMESTAMP WITH TIME ZONE NOT NULL,
  bookmarked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, article_id)
);

-- Enable RLS
ALTER TABLE news_bookmarks ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own bookmarks
CREATE POLICY "Users can view own bookmarks"
  ON news_bookmarks FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can create their own bookmarks
CREATE POLICY "Users can create own bookmarks"
  ON news_bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own bookmarks
CREATE POLICY "Users can delete own bookmarks"
  ON news_bookmarks FOR DELETE
  USING (auth.uid() = user_id);

-- Create index for performance
CREATE INDEX news_bookmarks_user_id_idx ON news_bookmarks(user_id);
CREATE INDEX news_bookmarks_bookmarked_at_idx ON news_bookmarks(bookmarked_at DESC);
```

## Upgrade Considerations

### Paid NewsAPI Tier Benefits
- Unlimited requests
- Historical data (up to 5 years)
- More sources
- Faster response times
- HTTPS support

### Cost: Starting at $449/month

For high-traffic apps, consider:
- Implementing aggressive caching
- Using Supabase database for caching
- Batch requests
- User-based rate limiting

## Security Notes

- ✅ API key stored securely in Edge Functions
- ✅ Client never sees API key
- ✅ CORS properly configured
- ✅ RLS policies for bookmarks (if using database)
- ✅ Input validation on Edge Function

## Next Steps

1. Deploy Edge Function
2. Set API secrets
3. Test integration
4. Add to app navigation
5. Monitor usage and caching
6. Consider paid tier for production
