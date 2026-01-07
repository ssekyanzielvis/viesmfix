# News Feature Implementation Checklist

Use this checklist to ensure complete implementation of the news feature.

## ✅ Prerequisites

- [ ] **NewsAPI.org Account**
  - [ ] Signed up at https://newsapi.org/
  - [ ] API key obtained and saved securely
  - [ ] Tier confirmed (Free: 100 req/day, Paid: Unlimited)

- [ ] **Supabase Project**
  - [ ] Project created at https://supabase.com/
  - [ ] Project URL noted: `https://__________.supabase.co`
  - [ ] Anon key noted
  - [ ] Service role key noted (for admin tasks)

- [ ] **Development Tools**
  - [ ] Supabase CLI installed: `npm install -g supabase`
  - [ ] Flutter SDK installed (3.10.4+)
  - [ ] Dart SDK installed (3.0+)
  - [ ] IDE setup (VS Code / Android Studio)

## 📦 Dependencies

- [ ] **Update pubspec.yaml**
  ```yaml
  dependencies:
    url_launcher: ^6.3.1
    share_plus: ^10.1.3
    dartz: ^0.10.1
    # ... existing dependencies
  ```

- [ ] **Run pub get**
  ```bash
  flutter pub get
  ```

- [ ] **Verify all dependencies installed**
  ```bash
  flutter pub deps
  ```

## 🗄️ Backend Setup

- [ ] **Navigate to Supabase functions directory**
  ```bash
  cd supabase/functions
  ```

- [ ] **Verify Edge Function exists**
  - [ ] `news-proxy/index.ts` present
  - [ ] `_shared/cors.ts` present

- [ ] **Login to Supabase**
  ```bash
  supabase login
  ```

- [ ] **Link project (first time only)**
  ```bash
  supabase link --project-ref YOUR_PROJECT_REF
  ```

- [ ] **Deploy Edge Function**
  ```bash
  supabase functions deploy news-proxy
  ```

- [ ] **Set environment secrets**
  ```bash
  supabase secrets set NEWS_API_KEY=your_newsapi_key_here
  ```

- [ ] **Verify secret is set**
  ```bash
  supabase secrets list
  ```

- [ ] **Test Edge Function**
  ```bash
  curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/news-proxy/top-headlines' \
    -H 'Authorization: Bearer YOUR_ANON_KEY' \
    -H 'Content-Type: application/json' \
    -d '{"category": "technology", "country": "us", "page": 1, "pageSize": 10}'
  ```
  Expected: JSON response with news articles

## 💾 Database Setup (Optional - for server-side bookmarks)

- [ ] **Run migration**
  ```bash
  supabase db push
  ```
  Or manually run the SQL in Supabase dashboard

- [ ] **Verify tables created**
  - [ ] `news_bookmarks` table exists
  - [ ] Indexes created
  - [ ] RLS policies enabled
  - [ ] Helper functions created

- [ ] **Test bookmark insert** (via SQL Editor)
  ```sql
  SELECT * FROM news_bookmarks LIMIT 1;
  ```

## 📱 Flutter App Configuration

- [ ] **Update environment.dart**
  - [ ] Set `SUPABASE_URL`
  - [ ] Set `SUPABASE_ANON_KEY`
  - [ ] Verify `enableNews = true`

- [ ] **Initialize SharedPreferences in main.dart**
  ```dart
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
  ```

- [ ] **Add routes to router**
  - [ ] `/news` → NewsScreen
  - [ ] `/news/search` → NewsSearchScreen
  - [ ] `/news/bookmarks` → NewsBookmarksScreen
  - [ ] `/news/article` → NewsArticleDetailScreen

- [ ] **Add news to navigation**
  - [ ] Bottom navigation bar (OR)
  - [ ] Drawer menu (OR)
  - [ ] Tab bar (OR)
  - [ ] Custom navigation

## 🎨 UI Integration

- [ ] **Add news icon to navigation**
  - [ ] Icon: `Icons.newspaper` or `Icons.newspaper_outlined`
  - [ ] Label: "News"
  - [ ] Color matches app theme

- [ ] **Test navigation**
  - [ ] Tap news icon → opens NewsScreen
  - [ ] Back button works
  - [ ] Deep linking works (if implemented)

- [ ] **Verify theme consistency**
  - [ ] Colors match app theme
  - [ ] Fonts match app fonts
  - [ ] Spacing consistent
  - [ ] Animations match app style

## 🧪 Testing

### Manual Testing

- [ ] **Browse News**
  - [ ] Open news screen
  - [ ] See articles loading
  - [ ] Switch between categories
  - [ ] Pull to refresh
  - [ ] Scroll to load more (pagination)
  - [ ] Tap article → opens detail view

- [ ] **Search**
  - [ ] Open search screen
  - [ ] Enter query → see results
  - [ ] Apply filters (date range, sort)
  - [ ] Clear search
  - [ ] Search with no results

- [ ] **Bookmarks**
  - [ ] Bookmark an article
  - [ ] Navigate to bookmarks
  - [ ] See bookmarked article
  - [ ] Remove bookmark
  - [ ] Bookmark count updates

- [ ] **Article Detail**
  - [ ] View full article
  - [ ] See images
  - [ ] Read content
  - [ ] Share article
  - [ ] Open in browser
  - [ ] Bookmark/unbookmark

- [ ] **Error Handling**
  - [ ] No internet → see error message
  - [ ] Rate limit exceeded → see error
  - [ ] Invalid category → handled gracefully
  - [ ] Broken image → placeholder shown

### Automated Testing (Optional)

- [ ] **Unit Tests**
  - [ ] Repository tests
  - [ ] Use case tests
  - [ ] Data source tests

- [ ] **Widget Tests**
  - [ ] NewsScreen renders
  - [ ] Article cards display
  - [ ] Search functionality

- [ ] **Integration Tests**
  - [ ] Full bookmark flow
  - [ ] Search and open article
  - [ ] Category switching

## 🔒 Security Verification

- [ ] **API Key Security**
  - [ ] Confirm API key NOT in client code
  - [ ] Confirm API key in Edge Function secrets
  - [ ] Verify client cannot access secrets

- [ ] **CORS Configuration**
  - [ ] CORS headers present in Edge Function
  - [ ] Test from different origins
  - [ ] No CORS errors in browser console

- [ ] **RLS Policies** (if using database)
  - [ ] Users can only see own bookmarks
  - [ ] Users can only modify own bookmarks
  - [ ] Test with different user accounts

- [ ] **Input Validation**
  - [ ] Search query sanitized
  - [ ] URL validation before opening
  - [ ] No SQL injection possible

## 📊 Performance Optimization

- [ ] **Caching**
  - [ ] Headlines cached for 15 minutes
  - [ ] Cache expires correctly
  - [ ] Old cache cleared on new fetch

- [ ] **Image Loading**
  - [ ] Images load lazily
  - [ ] Broken images show placeholder
  - [ ] Consider using CachedNetworkImage

- [ ] **Pagination**
  - [ ] Load 20 articles per page
  - [ ] Infinite scroll works smoothly
  - [ ] Loading indicator shown

- [ ] **Memory Management**
  - [ ] Controllers disposed properly
  - [ ] No memory leaks
  - [ ] Smooth navigation (no jank)

## 📝 Documentation

- [ ] **Code Comments**
  - [ ] All classes documented
  - [ ] Complex logic explained
  - [ ] API endpoints documented

- [ ] **README Updates**
  - [ ] News feature mentioned
  - [ ] Setup instructions added
  - [ ] Screenshots included (optional)

- [ ] **User Guide** (Optional)
  - [ ] How to browse news
  - [ ] How to search
  - [ ] How to bookmark
  - [ ] How to share

## 🚀 Deployment

### Pre-Deployment

- [ ] **Code Quality**
  - [ ] Run `flutter analyze` → no errors
  - [ ] Run `flutter test` → all pass
  - [ ] Code formatted: `flutter format .`

- [ ] **Environment Variables**
  - [ ] Production Supabase URL set
  - [ ] Production API keys configured
  - [ ] Feature flags verified

- [ ] **Build Testing**
  - [ ] Android build succeeds
  - [ ] iOS build succeeds
  - [ ] Web build succeeds (if applicable)

### Deployment Steps

- [ ] **Android**
  - [ ] Update version in pubspec.yaml
  - [ ] Build release APK/AAB
  - [ ] Test on real device
  - [ ] Upload to Play Store

- [ ] **iOS**
  - [ ] Update version in pubspec.yaml
  - [ ] Configure code signing
  - [ ] Build release IPA
  - [ ] Test on real device
  - [ ] Upload to App Store

- [ ] **Web** (Optional)
  - [ ] Build for web
  - [ ] Test responsive design
  - [ ] Deploy to hosting

## 📈 Monitoring

- [ ] **Set up monitoring**
  - [ ] Edge Function logs
  - [ ] Error tracking (Sentry, Firebase Crashlytics)
  - [ ] Analytics (Firebase, Mixpanel)
  - [ ] Performance monitoring

- [ ] **Track metrics**
  - [ ] API usage (requests per day)
  - [ ] Cache hit rate
  - [ ] User engagement (articles read, bookmarked)
  - [ ] Error rates

- [ ] **Set up alerts**
  - [ ] Rate limit approaching
  - [ ] High error rate
  - [ ] Edge Function failures

## 🐛 Troubleshooting Checklist

### "Failed to fetch news"
- [ ] Check internet connection
- [ ] Verify Edge Function deployed
- [ ] Check NEWS_API_KEY secret set
- [ ] Test Edge Function with curl
- [ ] Check Supabase URL/anon key

### "Rate limit exceeded"
- [ ] Check NewsAPI.org dashboard
- [ ] Verify cache is working
- [ ] Consider upgrading tier
- [ ] Wait 24 hours for reset

### "No articles found"
- [ ] Try different category
- [ ] Check search query
- [ ] Verify API is working (newsapi.org status)
- [ ] Check Edge Function logs

### CORS errors
- [ ] Verify cors.ts exists
- [ ] Redeploy Edge Function
- [ ] Check browser console
- [ ] Test in different browser

### Images not loading
- [ ] Check URL validity
- [ ] Verify internet connection
- [ ] Test image URLs directly
- [ ] Check placeholder is shown

## ✨ Optional Enhancements

- [ ] **Push Notifications**
  - [ ] Breaking news alerts
  - [ ] Personalized recommendations
  - [ ] Scheduled digests

- [ ] **Offline Mode**
  - [ ] Download articles for offline
  - [ ] Sync when online
  - [ ] Offline indicator

- [ ] **Personalization**
  - [ ] Track reading history
  - [ ] Recommend articles
  - [ ] Favorite categories

- [ ] **Advanced Features**
  - [ ] Text-to-speech
  - [ ] Save to collections
  - [ ] Reading time estimates
  - [ ] Related articles

- [ ] **Social Features**
  - [ ] Share to social media
  - [ ] Comment on articles
  - [ ] Like/react to articles
  - [ ] Follow topics

## 📋 Final Verification

- [ ] **Functionality**: All features work as expected
- [ ] **Performance**: App is fast and responsive
- [ ] **Security**: No API keys exposed, RLS working
- [ ] **UX**: Interface is intuitive and attractive
- [ ] **Errors**: All errors handled gracefully
- [ ] **Documentation**: Code and setup documented
- [ ] **Testing**: Manual and automated tests pass
- [ ] **Deployment**: App deployed successfully

## 🎉 Launch Checklist

- [ ] **Marketing Materials**
  - [ ] Screenshots of news feature
  - [ ] App store description updated
  - [ ] Feature announcement prepared

- [ ] **User Communication**
  - [ ] In-app announcement
  - [ ] Email to users
  - [ ] Social media posts

- [ ] **Support Ready**
  - [ ] FAQ updated
  - [ ] Support team trained
  - [ ] Bug report system ready

- [ ] **Monitoring Active**
  - [ ] Logs being collected
  - [ ] Alerts configured
  - [ ] Dashboard setup

---

## Notes

- Check off items as you complete them
- Add any custom items specific to your app
- Update this checklist for future features
- Keep this document version-controlled

## Support

For issues:
1. Review this checklist
2. Check NEWS_SETUP_GUIDE.md
3. Review NEWS_FEATURE_DOCS.md
4. Check Edge Function logs
5. Test with curl
6. Create issue with details

---

**Last Updated**: 2024
**Feature Version**: 1.0.0
**Status**: Implementation Guide
