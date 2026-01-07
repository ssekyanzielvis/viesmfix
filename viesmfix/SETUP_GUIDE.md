# ViesMFix - Setup and Next Steps

## ✅ What's Been Implemented

### Core Infrastructure
- ✅ Complete project structure with Clean Architecture
- ✅ Environment configuration system
- ✅ Netflix-inspired dark/light themes with Material 3
- ✅ App constants and configuration

### Domain Layer
- ✅ Movie entities (MovieEntity, MovieDetailEntity, Genre, Cast, Crew, Video)
- ✅ User entities
- ✅ Watchlist entities
- ✅ Repository interfaces

### Data Layer
- ✅ TMDB API service with Dio HTTP client
- ✅ TMDB models with JSON serialization annotations
- ✅ Movie mapper (converts models to entities)
- ✅ Movie repository implementation

### Presentation Layer
- ✅ Riverpod providers (theme, movies, search)
- ✅ Shared widgets (MovieCard, MovieSection, LoadingShimmer)
- ✅ Home screen with trending/popular/upcoming movies
- ✅ Movie detail screen with full information
- ✅ Search screen with real-time search
- ✅ Main app setup with theme switching

## 🚀 Next Steps to Run the App

### 1. Install Dependencies
```bash
cd viesmfix
flutter pub get
```

### 2. Generate Code for Models
The TMDB models use json_serializable and need code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Note**: You'll see some errors initially because the `.g.dart` files don't exist yet. This is normal and will be fixed by running the build_runner command.

### 3. Get TMDB API Key
1. Go to https://www.themoviedb.org/signup
2. Create an account
3. Navigate to Settings > API
4. Request an API key (choose "Developer" option)
5. Copy your API Read Access Token (Bearer token format)

### 4. Run the App
```bash
# Replace YOUR_API_KEY with your actual TMDB API key
flutter run --dart-define=TMDB_API_KEY=YOUR_API_KEY
```

## 📝 Important Notes

### Code Generation
The app uses `json_serializable` for JSON parsing. The model files have annotations that need code generation:

**Files that need generation:**
- `lib/src/data/models/remote/tmdb_movie_model.dart`

When you modify any model file, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use watch mode during development:
```bash
dart run build_runner watch
```

### API Key Configuration

**Option 1: Command Line (Recommended)**
```bash
flutter run --dart-define=TMDB_API_KEY=your_key_here
```

**Option 2: Hardcode for Development Only**
In `lib/src/core/constants/environment.dart`, temporarily replace:
```dart
static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY', defaultValue: '');
```
with:
```dart
static const String tmdbApiKey = 'YOUR_ACTUAL_API_KEY';
```
**⚠️ Warning**: Never commit your API key to version control!

### Running on Different Platforms

**Android/iOS:**
```bash
flutter run --dart-define=TMDB_API_KEY=your_key
```

**Web:**
```bash
flutter run -d chrome --dart-define=TMDB_API_KEY=your_key
```

**Windows:**
```bash
flutter run -d windows --dart-define=TMDB_API_KEY=your_key
```

## 🎨 Features Available Now

1. **Home Screen**
   - Browse trending movies
   - Explore popular movies
   - Check upcoming releases
   - Dark/light theme toggle

2. **Movie Details**
   - Full movie information
   - Cast and crew
   - Similar movie recommendations
   - Ratings and vote counts
   - Movie trailers (metadata available)

3. **Search**
   - Real-time movie search
   - Grid view of results
   - Direct navigation to movie details

## 🔧 Troubleshooting

### Error: "No BuildRunner factories have been registered"
**Solution**: Run `flutter pub get` first, then `dart run build_runner build`

### Error: "TMDB API Key not found"
**Solution**: Make sure you're running with `--dart-define=TMDB_API_KEY=your_key`

### Error: "Failed to fetch movies"
**Solution**: 
1. Check your internet connection
2. Verify your API key is correct
3. Check if TMDB API is accessible in your region

### Build errors about missing .g.dart files
**Solution**: Run `dart run build_runner build --delete-conflicting-outputs`

## 📦 Features Not Yet Implemented

The following features are defined but not yet implemented:
- ❌ Supabase backend integration
- ❌ User authentication (login/signup screens)
- ❌ Watchlist functionality
- ❌ User profiles
- ❌ Advanced routing with go_router
- ❌ Offline caching

These can be added in future iterations based on your needs.

## 🎯 Quick Test

After setup, you should be able to:
1. Launch the app
2. See trending/popular movies on the home screen
3. Tap on a movie to see details
4. Use the search icon to search for movies
5. Toggle between dark and light themes

## 📚 Architecture Overview

The app follows Clean Architecture:
```
Presentation (UI + Riverpod) 
    ↓
Domain (Entities + Repository Interfaces)
    ↓
Data (Models + Repository Implementations + API Service)
```

This separation makes the code:
- ✅ Testable
- ✅ Maintainable
- ✅ Scalable
- ✅ Independent of frameworks

## 🤝 Need Help?

If you encounter any issues:
1. Check this setup guide
2. Review the README.md
3. Check Flutter doctor: `flutter doctor -v`
4. Ensure you're using Flutter 3.10.4 or higher

Happy coding! 🚀
