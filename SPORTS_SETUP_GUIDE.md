# Sports Feature - Complete Setup Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Backend Setup](#backend-setup)
4. [Flutter App Setup](#flutter-app-setup)
5. [Configuration](#configuration)
6. [Testing](#testing)
7. [Deployment](#deployment)

## Overview

The Sports Feature transforms your app into a comprehensive sports guide with:
- ✅ Live match scores with real-time updates
- ✅ Upcoming matches schedule
- ✅ Legal streaming links aggregation
- ✅ Multi-sport support (Football, Basketball, Tennis, etc.)
- ✅ Regional streaming availability
- ✅ User personalization (favorite leagues/sports)
- ✅ Push notifications for match start and scores
- ✅ Calendar integration
- ✅ Bookmarks and watchlist

## Prerequisites

- ✅ Flutter 3.10.4+ installed
- ✅ Dart 3.0+ SDK
- ✅ Supabase project created
- ✅ Supabase CLI installed (`npm install -g supabase`)
- ✅ Sports API key (TheSportsDB, Sportmonks, or similar)
- ✅ Node.js 16+ (for Edge Functions)

## Backend Setup

### Step 1: Database Migration

Run the database migration to create all required tables:

```bash
cd supabase
supabase db push
```

This creates:
- `leagues` - Sports leagues/competitions
- `sport_events` - Live and upcoming matches
- `streaming_providers` - Streaming services (ESPN+, Peacock, DAZN, etc.)
- `broadcasting_rights` - Event-to-provider mapping
- `user_sport_bookmarks` - User bookmarked matches
- `user_sport_notifications` - Notification preferences
- `user_sport_preferences` - User settings
- `sports_api_cache` - API response caching

### Step 2: Set Environment Variables

Set your API keys in Supabase:

```bash
# Sports API key (e.g., TheSportsDB, Sportmonks)
supabase secrets set SPORTS_API_KEY=your_sports_api_key_here

# Supabase service role key (for backend operations)
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Step 3: Deploy Edge Functions

Deploy the sports API proxy function:

```bash
supabase functions deploy sports-api
```

Deploy the sync function for real-time updates:

```bash
supabase functions deploy sports-sync
```

### Step 4: Setup Cron Job (Optional but Recommended)

For automatic score updates, set up a cron job to call the sync function every 1-5 minutes:

Using Supabase pg_cron:

```sql
SELECT cron.schedule(
  'sync-sports-scores',
  '*/2 * * * *', -- Every 2 minutes
  $$
  SELECT
    net.http_post(
      url := 'https://your-project.supabase.co/functions/v1/sports-sync/cron',
      headers := '{"Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
    )
  $$
);
```

### Step 5: Seed Initial Data

The migration includes popular streaming providers. You can add more leagues and configure broadcasting rights:

```sql
-- Add a popular league
INSERT INTO leagues (name, sport_type, logo, country) VALUES
  ('Premier League', 'football', 'https://...', 'GB'),
  ('NBA', 'basketball', 'https://...', 'US'),
  ('Wimbledon', 'tennis', 'https://...', 'GB');

-- Map broadcasting rights (example)
INSERT INTO broadcasting_rights (event_id, provider_id, deep_link, available_regions, type) VALUES
  ('event-uuid', 'provider-uuid', 'peacocktv://sports/live/12345', ARRAY['US'], 'live');
```

## Flutter App Setup

### Step 1: Add Dependencies

All required dependencies are already in `pubspec.yaml`:
- ✅ `supabase_flutter` - Backend integration
- ✅ `flutter_riverpod` - State management
- ✅ `dio` - HTTP client
- ✅ `shared_preferences` - Local caching
- ✅ `url_launcher` - Deep linking
- ✅ `intl` - Date formatting

Run:
```bash
flutter pub get
```

### Step 2: Initialize Supabase

In `lib/main.dart`, Supabase should already be initialized. Ensure you have:

```dart
await Supabase.initialize(
  url: Environment.supabaseUrl,
  anonKey: Environment.supabaseAnonKey,
);
```

### Step 3: Initialize SharedPreferences

In your app initialization:

```dart
final prefs = await SharedPreferences.getInstance();

// Override providers with actual instances
runApp(
  ProviderScope(
    overrides: [
      sportsLocalDataSourceProvider.overrideWithValue(
        SportsLocalDataSource(prefs),
      ),
    ],
    child: MyApp(),
  ),
);
```

### Step 4: Add Routes

Add sports routes to `lib/src/core/router/app_router.dart`:

```dart
import '../presentation/screens/sports_screens.dart';

// Add to routes list
GoRoute(
  path: '/sports',
  name: 'sports',
  builder: (context, state) => const SportsScreen(),
),
GoRoute(
  path: '/sportsMatchDetail',
  name: 'sportsMatchDetail',
  builder: (context, state) {
    final match = state.extra as SportEventEntity;
    return MatchDetailScreen(match: match);
  },
),
```

### Step 5: Add to Navigation

Add sports to your main navigation (bottom nav, drawer, etc.):

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.sports_soccer),
  label: 'Sports',
),
```

## Configuration

### Environment Variables

Update `lib/src/core/constants/environment.dart`:

```dart
class Environment {
  // ... existing vars
  
  static const bool enableSports = true;
  
  // Optional: Configure cache duration
  static const int sportsCacheDurationMinutes = 5; // Shorter for live events
}
```

### Regional Configuration

Set user's region for streaming availability:

```dart
// In user settings or app initialization
ref.read(userRegionProvider.notifier).state = 'US'; // or 'GB', 'AU', etc.
```

### API Configuration

The sports feature uses TheSportsDB by default (free tier available). To use a different API:

1. Update `sports_remote_datasource.dart` to match your API's response format
2. Update the Edge Function `sports-api/index.ts` to call your API
3. Update models in `sport_event_model.dart` if needed

## Testing

### Manual Testing Checklist

**Live Matches:**
- [ ] Live matches display with current scores
- [ ] Scores update in real-time (via stream)
- [ ] Live indicator shows on active matches
- [ ] Can filter by sport type
- [ ] Can refresh to get latest data

**Upcoming Matches:**
- [ ] Shows upcoming matches sorted by date
- [ ] Displays correct team logos
- [ ] Shows streaming options
- [ ] Can load more matches (pagination)

**Match Details:**
- [ ] Shows full match information
- [ ] Streaming options are clickable
- [ ] Deep links work (if apps installed)
- [ ] Can bookmark/unbookmark
- [ ] Can enable/disable notifications

**Personalization:**
- [ ] Can add favorite leagues
- [ ] My Matches shows relevant content
- [ ] Preferences persist across sessions

**Performance:**
- [ ] Caching works (check X-Cache headers)
- [ ] App loads quickly
- [ ] No excessive API calls
- [ ] Real-time updates don't cause lag

### Unit Testing

Run tests:
```bash
flutter test
```

Example test:
```dart
test('SportEvent entity should have correct live status', () {
  final event = SportEventEntity(
    id: '1',
    homeTeam: 'Team A',
    awayTeam: 'Team B',
    league: league,
    sportType: SportType.football,
    startTime: DateTime.now(),
    status: EventStatus.live,
  );
  
  expect(event.isLive, true);
  expect(event.isUpcoming, false);
});
```

## Deployment

### Production Checklist

- [ ] Database migration applied to production
- [ ] Edge Functions deployed
- [ ] API keys set in production Supabase
- [ ] Cron job configured for score updates
- [ ] Popular leagues seeded in database
- [ ] Streaming providers configured
- [ ] Deep links tested on iOS/Android
- [ ] Push notifications configured (if using)
- [ ] Analytics tracking added
- [ ] Error logging configured

### Monitoring

**Database Queries:**
```sql
-- Check live events
SELECT * FROM sport_events WHERE status = 'live';

-- Check cache hit rate
SELECT 
  cache_type,
  COUNT(*) as cached_items,
  AVG(EXTRACT(EPOCH FROM (NOW() - created_at))) as avg_age_seconds
FROM sports_api_cache
GROUP BY cache_type;

-- Check popular leagues
SELECT 
  l.name,
  COUNT(DISTINCT e.id) as event_count,
  COUNT(DISTINCT br.provider_id) as provider_count
FROM leagues l
LEFT JOIN sport_events e ON e.league_id = l.id
LEFT JOIN broadcasting_rights br ON br.event_id = e.id
GROUP BY l.id, l.name
ORDER BY event_count DESC;
```

**Edge Function Logs:**
```bash
supabase functions logs sports-api
supabase functions logs sports-sync
```

### Performance Optimization

**Caching Strategy:**
- Live matches: 2-5 minute cache
- Upcoming matches: 15 minute cache
- Leagues: 1 hour cache
- Streaming providers: 1 day cache

**Database Indexes:**
Already created in migration:
- `idx_events_status` - Fast live/upcoming queries
- `idx_events_start_time` - Quick date range queries
- `idx_broadcasting_regions` - Efficient regional filtering

**Real-time Optimization:**
Only subscribe to:
- Live match updates (when viewing match detail)
- Live matches list (when on live tab)

Unsubscribe when navigating away to save resources.

## Troubleshooting

**No matches showing:**
- Check database has events (run seed queries)
- Verify Edge Function is deployed and accessible
- Check API key is valid
- Look at Edge Function logs for errors

**Streaming links not working:**
- Verify broadcasting_rights table has data
- Check user's region matches available_regions
- Ensure streaming providers are marked as active

**Real-time not updating:**
- Confirm Supabase Realtime is enabled on tables
- Check subscription in provider code
- Verify RLS policies allow reads (when auth is enabled)

**Cache not clearing:**
- Manually clear: `SELECT clean_expired_sports_cache();`
- Check cron job is running
- Verify expires_at timestamps are correct

## Next Steps

1. **Add More Sports APIs:** Integrate additional data sources for better coverage
2. **Enhance Deep Linking:** Add more streaming app integrations
3. **Push Notifications:** Implement full notification system
4. **Calendar Integration:** Allow users to add matches to calendar
5. **Social Features:** Add match discussions, predictions
6. **Analytics:** Track user engagement, popular matches
7. **Monetization:** Add affiliate links for streaming subscriptions

## Support

For issues or questions:
- Check Supabase dashboard logs
- Review Edge Function responses
- Test API endpoints directly
- Check database table contents

**Common SQL Queries:**
```sql
-- Get all live matches with streaming
SELECT * FROM get_live_matches();

-- View upcoming matches
SELECT * FROM upcoming_matches_with_streaming;

-- Check streaming provider coverage
SELECT 
  sp.name,
  COUNT(DISTINCT br.event_id) as events_covered
FROM streaming_providers sp
LEFT JOIN broadcasting_rights br ON br.provider_id = sp.id
GROUP BY sp.id, sp.name;
```

---

**Status:** ✅ Ready for Deployment
**Version:** 1.0.0
**Last Updated:** January 7, 2026
