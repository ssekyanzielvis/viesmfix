# 🚀 Quick Start Guide

## Run the App in 3 Steps:

### 1️⃣ Get API Key
Visit: https://www.themoviedb.org/settings/api
Copy your **API Read Access Token**

### 2️⃣ Navigate to Project
```bash
cd c:\Users\Vash\Desktop\viesmfix\viesmfix\viesmfix
```

### 3️⃣ Run!
```bash
flutter run --dart-define=TMDB_API_KEY=YOUR_API_KEY_HERE
```

---

## 📱 Platform-Specific Commands

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

---

## 🔧 Common Commands

**Install dependencies:**
```bash
flutter pub get
```

**Generate code (after model changes):**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Clean build:**
```bash
flutter clean
flutter pub get
flutter run --dart-define=TMDB_API_KEY=your_key
```

---

## ✅ What Works Now

- ✅ Browse trending movies
- ✅ Browse popular movies  
- ✅ Browse upcoming movies
- ✅ Search any movie
- ✅ View full movie details
- ✅ See cast & crew
- ✅ Similar movie recommendations
- ✅ Dark/Light theme toggle

---

## 📚 Documentation

- `README.md` - Full documentation
- `SETUP_GUIDE.md` - Detailed setup instructions
- `IMPLEMENTATION_SUMMARY.md` - Complete implementation details

---

## 💡 Tips

1. **First time setup**: Run `flutter pub get` before anything else
2. **API Key**: Never commit your API key to git
3. **Theme**: Toggle using the icon in the top-right corner
4. **Search**: Has built-in debouncing (500ms delay)
5. **Images**: Cached automatically for better performance

---

## 🐛 Troubleshooting

**Error: "No API key"**
→ Make sure you're using `--dart-define=TMDB_API_KEY=your_key`

**Error: Missing .g.dart files**
→ Run `dart run build_runner build --delete-conflicting-outputs`

**Error: Dependencies not found**
→ Run `flutter pub get`

**App crashes on startup**
→ Check that your TMDB API key is valid

---

## 🎯 Project Structure

```
lib/
├── app.dart                 # Main app
├── main.dart                # Entry point
└── src/
    ├── core/                # Constants, themes
    ├── data/                # Models, repositories
    ├── domain/              # Entities, interfaces
    ├── presentation/        # UI, providers
    └── services/            # API services
```

---

## 🎨 Features

**Home Screen:**
- Horizontal scrolling movie sections
- Trending, Popular, Upcoming
- Theme toggle
- Search navigation

**Movie Details:**
- Full movie information
- Cast with photos
- Similar movies
- Ratings & reviews

**Search:**
- Real-time search
- Grid layout
- Empty states
- Error handling

---

**Need more help?** Check `SETUP_GUIDE.md`

**Ready to extend?** See `IMPLEMENTATION_SUMMARY.md` for architecture details

---

Enjoy your movie app! 🎬✨
