# ✅ Terminal Restart Checklist

## 1. Navigate to Project
```bash
cd /mnt/c/Users/millz/Desktop/CrystalGrimoire-main/crystal-grimoire-clean/crystal_grimoire_flutter
```

## 2. Verify Flutter Installation
```bash
flutter --version
# Should show Flutter 3.x.x

flutter doctor
# Check for any issues
```

## 3. Install Dependencies
```bash
flutter pub get
```

## 4. Quick Test Run
```bash
flutter run -d chrome
# Or use any available device
flutter devices
```

## 5. Key Files to Remember

### Configuration Files
- `/lib/config/backend_config.dart` - Backend URL settings
- `/lib/services/astrology_service.dart` - Free astrology API
- `/lib/services/storage_service.dart` - Local storage for birth charts

### New Feature Files
- `/lib/screens/journal_screen.dart` - Enhanced with animations
- `/lib/screens/birth_chart_screen.dart` - Birth chart UI
- `/lib/models/birth_chart.dart` - Astrology data model

### Backend
- `/backend_crystal/simple_backend.py` - Python backend with Gemini AI

## 6. Test Features

### Journal Animations
1. Open Journal (book icon)
2. Switch tabs - see color changes:
   - All: Purple
   - Favorites: Pink
   - Purpose: Green
   - Insights: Blue

### Birth Chart
1. Settings → Birth Chart
2. Add chart (Premium feature)
3. Enter any date/time/location

### Crystal ID
1. Camera button
2. Upload photo
3. See new "Primary Uses" section

## 7. Common Commands

```bash
# Clean rebuild
flutter clean && flutter pub get

# Build web
flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true

# Run with logging
flutter run -d chrome -v

# Format code
flutter format lib/

# Analyze code
flutter analyze
```

## 8. Backend Commands

```bash
# Navigate to backend
cd ../backend_crystal

# Install deps
pip install -r requirements_simple.txt

# Run locally
python simple_backend.py
```

## 9. Git Status
```bash
# Check what's changed
git status

# See recent commits
git log --oneline -10
```

## 10. Deployment URLs
- Frontend: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app
- Backend: Deploy to Render (see QUICK_START_GUIDE.md)

## Summary of Today's Work
✅ Enhanced journal with unique color schemes per section
✅ Added parallax scrolling and micro-animations
✅ Integrated birth chart with free astrology API
✅ Enhanced crystal property display
✅ AI personalization based on user's astrology
✅ Auto-save identified crystals to collection

Everything is tested and working! 🎉