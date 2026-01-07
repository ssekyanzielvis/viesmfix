# ViesMFix - Netflix-Inspired Movie App

A beautiful, cross-platform movie discovery app built with Flutter and powered by TMDB API. Features a Netflix-inspired dark theme, smooth animations, and comprehensive movie information.

## Features

- 🎬 **Movie Discovery**: Browse trending, popular, and upcoming movies
- 🔍 **Advanced Search**: Search for movies with real-time results
- 📱 **Responsive Design**: Works seamlessly on mobile, tablet, and desktop
- 🌓 **Theme Support**: Beautiful dark and light themes
- ⭐ **Movie Details**: Comprehensive information including cast, crew, and similar movies
- 🎨 **Modern UI**: Netflix-inspired interface with smooth animations
- 📊 **Ratings & Reviews**: View TMDB ratings and vote counts
- 🎭 **Genre Filtering**: Browse movies by genre

## Technology Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **API**: TMDB (The Movie Database)
- **HTTP Client**: Dio
- **Image Caching**: cached_network_image
- **Code Generation**: freezed, json_serializable
- **Fonts**: Google Fonts (Poppins)

## Getting Started

### Prerequisites

- Flutter SDK 3.10.4 or higher
- Dart SDK 3.10.4 or higher
- TMDB API Key (get it from [TMDB](https://www.themoviedb.org/settings/api))

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd viesmfix
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code for JSON serialization:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Create a `.env` file or set environment variables for your TMDB API key:
```bash
# Option 1: Run with --dart-define
flutter run --dart-define=TMDB_API_KEY=your_api_key_here

# Option 2: For development, you can hardcode the key in environment.dart (NOT recommended for production)
```

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── app.dart                          # Main app widget
├── main.dart                         # Entry point
└── src/
    ├── core/
    │   ├── constants/                # App constants and environment config
    │   └── themes/                   # Theme definitions and colors
    ├── data/
    │   ├── mappers/                  # Data mappers (model to entity)
    │   ├── models/                   # Data models
    │   └── repositories/             # Repository implementations
    ├── domain/
    │   ├── entities/                 # Business entities
    │   └── repositories/             # Repository interfaces
    ├── presentation/
    │   ├── features/                 # Feature modules (home, search, movie details)
    │   ├── providers/                # Riverpod providers
    │   └── widgets/                  # Reusable widgets
    └── services/
        └── api/                      # API services (TMDB)
```

## Features Roadmap

### Current Features
- ✅ Movie browsing (Trending, Popular, Upcoming)
- ✅ Movie search
- ✅ Detailed movie information
- ✅ Cast and crew information
- ✅ Similar movie recommendations
- ✅ Dark/Light theme toggle
- ✅ Responsive design

### Planned Features
- 🔲 Watchlist functionality (with Supabase backend)
- 🔲 User authentication
- 🔲 User ratings and reviews
- 🔲 Advanced filtering and sorting
- 🔲 Offline mode with local caching
- 🔲 Multi-language support
- 🔲 TV Shows support
- 🔲 Social features (share, discuss)

## Configuration

### TMDB API Setup

1. Sign up at [TMDB](https://www.themoviedb.org/signup)
2. Request an API key from your account settings
3. Use the API key when running the app

### Optional: Supabase Setup (for future features)

For watchlist and user features, you'll need to:
1. Create a Supabase project
2. Set up authentication
3. Create necessary tables
4. Add Supabase URL and anon key to environment variables

## Building for Production

### Android
```bash
flutter build apk --release --dart-define=TMDB_API_KEY=your_api_key
```

### iOS
```bash
flutter build ios --release --dart-define=TMDB_API_KEY=your_api_key
```

### Web
```bash
flutter build web --release --dart-define=TMDB_API_KEY=your_api_key
```

### Desktop (Windows)
```bash
flutter build windows --release --dart-define=TMDB_API_KEY=your_api_key
```

## Code Generation

When you modify model files, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or for watch mode during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Architecture

This project follows Clean Architecture principles:

- **Domain Layer**: Contains business entities and repository interfaces
- **Data Layer**: Implements repositories and handles data sources (API, local storage)
- **Presentation Layer**: UI components, screens, and state management

### State Management

The app uses Riverpod for state management with the following provider types:
- `Provider`: For dependency injection (services, repositories)
- `FutureProvider`: For async data fetching
- `StateNotifierProvider`: For mutable state (theme, auth)
- `StateProvider`: For simple state (search query)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Movie data provided by [TMDB](https://www.themoviedb.org/)
- Icons from Material Design
- Fonts from Google Fonts

## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.

---

**Note**: This app uses the TMDB API but is not endorsed or certified by TMDB.

