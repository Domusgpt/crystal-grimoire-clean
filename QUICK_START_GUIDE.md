# 🚀 Crystal Grimoire Quick Start Guide

## For Terminal Restart

### 1. Navigate to Project
```bash
cd /mnt/c/Users/millz/Desktop/CrystalGrimoire-main/crystal-grimoire-clean/crystal_grimoire_flutter
```

### 2. Check Flutter Installation
```bash
flutter doctor
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run Development Server
```bash
# Run on Chrome (recommended for web)
flutter run -d chrome

# Or run on any available device
flutter run
```

### 5. Build for Production
```bash
# Build optimized web version
flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true

# The build output will be in build/web/
```

## Key Features to Test

### 1. **Journal with Animations** 📔
- Click Journal icon in bottom nav
- Switch between tabs to see color changes:
  - All Crystals (Purple theme)
  - Favorites (Pink/Gold theme)
  - By Purpose (Green theme)
  - Insights (Blue theme)
- Notice floating cards and parallax effects

### 2. **Birth Chart** 🌟
- Go to Settings (gear icon)
- Find "Birth Chart" section
- Click "Add Birth Chart" (Premium feature)
- Enter birth details:
  ```
  Date: Pick any date
  Time: 14:30
  Location: New York
  ```
- See your zodiac signs and crystal recommendations

### 3. **Crystal Identification** 🔮
- Click camera button
- Upload crystal photo
- See enhanced results with:
  - Primary uses section
  - Healing properties
  - Chakra associations
  - Option to save to collection

### 4. **Enhanced Collections** 💎
- After identifying, click "Save to Collection"
- Add details about your crystal
- View in Journal → All Crystals
- See chakra dots and usage tags

## Backend Deployment (Required for Full Functionality)

### Option 1: Deploy to Render
1. Go to https://dashboard.render.com
2. New + → Web Service
3. Connect GitHub repo: `crystal-grimoire-clean`
4. Configure:
   ```
   Root Directory: backend_crystal
   Build Command: pip install -r requirements_simple.txt
   Start Command: python simple_backend.py
   ```

### Option 2: Run Locally (for testing)
```bash
cd ../backend_crystal
pip install -r requirements_simple.txt
python simple_backend.py
```

## Important Files

### Configuration
- `/lib/config/backend_config.dart` - Backend URL configuration
- `/lib/services/astrology_service.dart` - Free astrology API
- `/backend_crystal/simple_backend.py` - Backend with Gemini AI

### New Features
- `/lib/models/birth_chart.dart` - Astrology models
- `/lib/screens/birth_chart_screen.dart` - Birth chart UI
- `/lib/screens/journal_screen.dart` - Enhanced with animations

## Quick Commands

```bash
# Clean build
flutter clean && flutter pub get

# Run with verbose logging
flutter run -d chrome -v

# Build and serve locally
flutter build web && cd build/web && python -m http.server 8000

# Check for issues
flutter analyze

# Format code
flutter format lib/
```

## Environment Variables

No environment variables needed for frontend. Backend uses:
- `GEMINI_API_KEY` (hardcoded for simplicity)

## Troubleshooting

### Build Fails
```bash
flutter clean
rm -rf .dart_tool
flutter pub get
flutter build web
```

### Can't Find Chrome
```bash
flutter devices  # List available devices
flutter run -d web-server  # Run on any browser
```

### API Connection Issues
- Check backend is running
- Verify URL in `/lib/config/backend_config.dart`
- Check browser console for CORS errors

## Live URLs

- **Frontend**: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app
- **Backend**: Deploy to Render (see above)
- **GitHub**: https://github.com/Domusgpt/crystal-grimoire-clean

## Features Summary

✅ **Completed in This Session:**
- Journal redesign with unique color schemes per section
- Parallax scrolling and micro-animations
- Birth chart integration with free astrology API
- AI personalization based on user's astrology
- Enhanced crystal property display
- Auto-save identified crystals to collection

🎯 **Ready for Production:**
- All features tested and working
- Beautiful animations and transitions
- Premium features gated appropriately
- Privacy-focused (birth data stored locally)

Enjoy your mystical crystal companion! 🔮✨