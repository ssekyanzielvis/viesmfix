# News Feature - Comprehensive Testing Guide

## 🧪 Test Categories

### 1. Unit Tests (Recommended)

Create these test files for complete coverage:

#### A. Entity Tests
**File:** `test/domain/entities/news_article_entity_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:viesmfix/src/domain/entities/news_article_entity.dart';

void main() {
  group('NewsArticleEntity', () {
    test('should create entity with all fields', () {
      final article = NewsArticleEntity(
        id: 'test-id',
        sourceName: 'Test Source',
        title: 'Test Title',
        description: 'Test Description',
        url: 'https://test.com/article',
        urlToImage: 'https://test.com/image.jpg',
        publishedAt: DateTime(2024, 1, 1),
      );

      expect(article.id, 'test-id');
      expect(article.sourceName, 'Test Source');
      expect(article.title, 'Test Title');
    });

    test('should handle nullable fields', () {
      final article = NewsArticleEntity(
        id: 'test-id',
        sourceName: 'Test Source',
        title: 'Test Title',
        url: 'https://test.com/article',
        publishedAt: DateTime(2024, 1, 1),
      );

      expect(article.description, isNull);
      expect(article.urlToImage, isNull);
      expect(article.author, isNull);
      expect(article.content, isNull);
    });

    test('should support bookmark flag', () {
      final article = NewsArticleEntity(
        id: 'test-id',
        sourceName: 'Test Source',
        title: 'Test Title',
        url: 'https://test.com/article',
        publishedAt: DateTime(2024, 1, 1),
        isBookmarked: true,
      );

      expect(article.isBookmarked, isTrue);
    });
  });

  group('NewsCategory', () {
    test('should have all categories', () {
      expect(NewsCategory.values.length, 7);
      expect(NewsCategory.values.contains(NewsCategory.general), isTrue);
      expect(NewsCategory.values.contains(NewsCategory.technology), isTrue);
    });

    test('should have display names', () {
      expect(NewsCategory.technology.displayName, 'Technology');
      expect(NewsCategory.sports.displayName, 'Sports');
      expect(NewsCategory.business.displayName, 'Business');
    });
  });
}
```

#### B. Model Tests
**File:** `test/data/models/news_article_model_test.dart`
```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:viesmfix/src/data/models/news_article_model.dart';

void main() {
  final testJson = {
    'source': {'id': 'test-source', 'name': 'Test Source'},
    'title': 'Test Article',
    'description': 'Test Description',
    'url': 'https://test.com/article',
    'urlToImage': 'https://test.com/image.jpg',
    'publishedAt': '2024-01-01T12:00:00Z',
    'author': 'Test Author',
    'content': 'Test Content',
  };

  group('NewsArticleModel', () {
    test('should deserialize from JSON', () {
      final model = NewsArticleModel.fromJson(testJson);

      expect(model.title, 'Test Article');
      expect(model.source.name, 'Test Source');
      expect(model.description, 'Test Description');
      expect(model.publishedAt, isA<DateTime>());
    });

    test('should serialize to JSON', () {
      final model = NewsArticleModel.fromJson(testJson);
      final json = model.toJson();

      expect(json['title'], 'Test Article');
      expect(json['source']['name'], 'Test Source');
      expect(json['url'], 'https://test.com/article');
    });

    test('should convert to entity', () {
      final model = NewsArticleModel.fromJson(testJson);
      final entity = model.toEntity();

      expect(entity.title, 'Test Article');
      expect(entity.sourceName, 'Test Source');
      expect(entity.url, 'https://test.com/article');
    });

    test('should handle nullable fields', () {
      final minimalJson = {
        'source': {'id': null, 'name': 'Test Source'},
        'title': 'Test Article',
        'url': 'https://test.com/article',
        'publishedAt': '2024-01-01T12:00:00Z',
      };

      final model = NewsArticleModel.fromJson(minimalJson);

      expect(model.description, isNull);
      expect(model.urlToImage, isNull);
      expect(model.author, isNull);
      expect(model.content, isNull);
    });
  });
}
```

#### C. Repository Tests
**File:** `test/data/repositories/news_repository_impl_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:viesmfix/src/data/repositories/news_repository_impl.dart';
import 'package:viesmfix/src/data/datasources/news_remote_datasource.dart';
import 'package:viesmfix/src/data/datasources/news_local_datasource.dart';

@GenerateMocks([NewsRemoteDataSource, NewsLocalDataSource])
void main() {
  late NewsRepositoryImpl repository;
  late MockNewsRemoteDataSource mockRemoteDataSource;
  late MockNewsLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockNewsRemoteDataSource();
    mockLocalDataSource = MockNewsLocalDataSource();
    repository = NewsRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('getTopHeadlines', () {
    test('should return cached data when available and fresh', () async {
      // Arrange
      when(mockLocalDataSource.getCachedHeadlines(any))
          .thenAnswer((_) async => []);
      when(mockLocalDataSource.isCacheValid(any))
          .thenReturn(true);

      // Act
      final result = await repository.getTopHeadlines();

      // Assert
      expect(result, isA<Right>());
      verify(mockLocalDataSource.getCachedHeadlines(any));
      verifyNever(mockRemoteDataSource.getTopHeadlines(any, any, any, any));
    });

    test('should fetch from remote when cache is stale', () async {
      // Arrange
      when(mockLocalDataSource.isCacheValid(any))
          .thenReturn(false);
      when(mockRemoteDataSource.getTopHeadlines(any, any, any, any))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getTopHeadlines();

      // Assert
      expect(result, isA<Right>());
      verify(mockRemoteDataSource.getTopHeadlines(any, any, any, any));
    });
  });
}
```

### 2. Widget Tests

#### A. News Card Test
**File:** `test/presentation/widgets/enhanced_news_card_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viesmfix/src/presentation/widgets/enhanced_news_card.dart';
import 'package:viesmfix/src/domain/entities/news_article_entity.dart';

void main() {
  late NewsArticleEntity testArticle;

  setUp(() {
    testArticle = NewsArticleEntity(
      id: 'test-1',
      sourceName: 'Test Source',
      title: 'Test Article Title',
      description: 'Test Description',
      url: 'https://test.com/article',
      publishedAt: DateTime(2024, 1, 1),
    );
  });

  testWidgets('should display article title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnhancedNewsArticleCard(
            article: testArticle,
            onTap: () {},
            onBookmark: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Article Title'), findsOneWidget);
    expect(find.text('Test Source'), findsOneWidget);
  });

  testWidgets('should trigger onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnhancedNewsArticleCard(
            article: testArticle,
            onTap: () => tapped = true,
            onBookmark: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('should show bookmark icon when bookmarked', (tester) async {
    final bookmarkedArticle = NewsArticleEntity(
      id: 'test-1',
      sourceName: 'Test Source',
      title: 'Test Article',
      url: 'https://test.com',
      publishedAt: DateTime(2024, 1, 1),
      isBookmarked: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnhancedNewsArticleCard(
            article: bookmarkedArticle,
            onTap: () {},
            onBookmark: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });
}
```

#### B. News Screen Test
**File:** `test/presentation/screens/news_screen_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viesmfix/src/presentation/screens/news_screen.dart';

void main() {
  testWidgets('should display loading indicator initially', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NewsScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('should display category tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NewsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
  });
}
```

### 3. Integration Tests

**File:** `integration_test/news_feature_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viesmfix/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('News Feature Integration Tests', () {
    testWidgets('complete news flow test', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to news
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();

      // Verify news feed loaded
      expect(find.byType(ListView), findsOneWidget);

      // Test category switching
      await tester.tap(find.text('Technology'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test article tap
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify detail screen
      expect(find.text('Read Full Article'), findsOneWidget);

      // Test bookmark
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pumpAndSettle();

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify search results
      expect(find.byType(Card), findsWidgets);
    });
  });
}
```

### 4. Manual Testing Checklist

#### A. Functionality Tests
- [ ] **News Feed**
  - [ ] Initial load shows articles
  - [ ] Pull-to-refresh works
  - [ ] Infinite scroll loads more
  - [ ] Category tabs switch correctly
  - [ ] Empty state shows when no articles
  - [ ] Error state shows with retry button

- [ ] **Search**
  - [ ] Search input works
  - [ ] Results appear after search
  - [ ] Date filter works
  - [ ] Sort options work (Published At, Relevancy, Popularity)
  - [ ] Clear filters works
  - [ ] Empty state shows when no results

- [ ] **Bookmarks**
  - [ ] Bookmark icon toggles correctly
  - [ ] Bookmarked articles appear in bookmarks screen
  - [ ] Remove bookmark shows confirmation
  - [ ] Bookmark persists across app restarts
  - [ ] Empty state shows when no bookmarks

- [ ] **Article Detail**
  - [ ] Full article content displays
  - [ ] Images load correctly
  - [ ] Bookmark button works
  - [ ] Share button opens share sheet
  - [ ] "Read Full Article" opens browser
  - [ ] Back navigation works

#### B. Responsive Design Tests
- [ ] **Mobile (360x800)**
  - [ ] Single column grid
  - [ ] Touch targets large enough
  - [ ] Text readable
  - [ ] Images scale correctly

- [ ] **Tablet Portrait (768x1024)**
  - [ ] 2-column grid
  - [ ] Increased spacing
  - [ ] Larger text/icons
  - [ ] Better use of space

- [ ] **Tablet Landscape (1024x768)**
  - [ ] 3-column grid
  - [ ] Optimal content density
  - [ ] Proper card aspect ratios

- [ ] **Desktop (1920x1080)**
  - [ ] 4-column grid
  - [ ] Max-width constraint
  - [ ] Centered content
  - [ ] Desktop-appropriate spacing

#### C. Performance Tests
- [ ] **Loading Performance**
  - [ ] Initial load < 1 second (cached)
  - [ ] Search results < 1 second
  - [ ] Smooth scrolling (60 FPS)
  - [ ] No frame drops during category switch

- [ ] **Cache Performance**
  - [ ] First load shows loading indicator
  - [ ] Second load within 15 min loads instantly
  - [ ] Cache invalidates after 15 minutes
  - [ ] Database cache working (check X-Cache headers)

- [ ] **Memory Usage**
  - [ ] No memory leaks
  - [ ] Images properly cached
  - [ ] Scrolling doesn't increase memory significantly

#### D. Error Handling Tests
- [ ] **Network Errors**
  - [ ] Airplane mode shows connection error
  - [ ] Timeout shows appropriate error
  - [ ] Retry button works after error
  - [ ] Cached data shown when offline

- [ ] **API Errors**
  - [ ] Rate limit error shows specific message
  - [ ] Invalid API key shows auth error
  - [ ] 404 errors handled gracefully

- [ ] **Edge Cases**
  - [ ] No image articles show placeholder
  - [ ] Very long titles truncate correctly
  - [ ] Missing fields don't crash app
  - [ ] Rapid tab switching doesn't cause issues

### 5. Accessibility Tests

- [ ] **Screen Reader**
  - [ ] Article titles announced
  - [ ] Category tabs labeled
  - [ ] Buttons have semantic labels
  - [ ] Images have descriptions

- [ ] **Keyboard Navigation**
  - [ ] Tab key navigates elements
  - [ ] Enter activates buttons/cards
  - [ ] Escape closes dialogs

- [ ] **Visual**
  - [ ] Text contrast meets WCAG AA
  - [ ] Focus indicators visible
  - [ ] Tap targets ≥ 44x44 pixels
  - [ ] Works with large text settings

### 6. Localization Tests

Test in all 8 languages:
- [ ] English (en)
- [ ] Spanish (es)
- [ ] French (fr)
- [ ] German (de)
- [ ] Portuguese (pt)
- [ ] Chinese (zh)
- [ ] Japanese (ja)
- [ ] Arabic (ar)

For each:
- [ ] UI strings translated
- [ ] Category names translated
- [ ] Error messages translated
- [ ] Date formatting correct for locale
- [ ] RTL layout correct (Arabic)

### 7. Security Tests

- [ ] **API Security**
  - [ ] API key not exposed in client
  - [ ] All requests go through Edge Function
  - [ ] No sensitive data in URLs
  - [ ] HTTPS only

- [ ] **Data Privacy**
  - [ ] Bookmarks stored locally only
  - [ ] No PII sent to analytics
  - [ ] Cache cleared properly

## 🎯 Test Execution

### Run Unit Tests
```bash
flutter test test/domain/
flutter test test/data/
flutter test test/presentation/
```

### Run Widget Tests
```bash
flutter test test/presentation/widgets/
flutter test test/presentation/screens/
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Generate Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Target Coverage
- Overall: ≥ 80%
- Domain layer: ≥ 90%
- Data layer: ≥ 85%
- Presentation layer: ≥ 75%

## 📊 Test Results Template

```markdown
# News Feature Test Results

**Date:** 2024-01-07
**Tester:** [Name]
**Environment:** [Dev/Staging/Production]
**Platform:** [Android/iOS/Web]
**Device:** [Device Details]

## Test Summary
- Total Tests: [X]
- Passed: [X]
- Failed: [X]
- Skipped: [X]
- Pass Rate: [X]%

## Detailed Results

### Functionality: ✅/❌
- News Feed: ✅
- Search: ✅
- Bookmarks: ✅
- Article Detail: ✅

### Responsive Design: ✅/❌
- Mobile: ✅
- Tablet: ✅
- Desktop: ✅

### Performance: ✅/❌
- Load Time: [Xms]
- Cache Hit Rate: [X]%
- Memory Usage: [XMB]

### Errors Found
1. [Description] - [Severity: Critical/Major/Minor]
2. ...

### Recommendations
1. [Recommendation]
2. ...
```

## 🚀 Ready for Production

Before marking as production-ready, ensure:
- [ ] All critical tests pass
- [ ] No P0/P1 bugs
- [ ] Performance meets targets
- [ ] Accessibility requirements met
- [ ] All 8 languages tested
- [ ] Documentation complete
- [ ] Monitoring in place
- [ ] Rollback plan ready
