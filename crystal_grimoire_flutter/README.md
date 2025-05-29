# 🔮 Crystal Grimoire - Flutter App

A mystical crystal identification app that combines AI-powered recognition with personalized spiritual guidance, featuring beautiful animations and astrological integration.

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10+ installed
- Chrome browser (for web development)
- Git

### Setup Instructions

```bash
# 1. Clone and navigate to project
cd /mnt/c/Users/millz/Desktop/CrystalGrimoire-main/crystal-grimoire-clean/crystal_grimoire_flutter

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run -d chrome  # For web
flutter run           # For any available device
```

### Backend Setup (Required for Full Features)

The app uses a Python backend deployed on Render:
- **Backend URL**: https://crystal-grimoire-backend.onrender.com
- **API**: Gemini AI for crystal identification
- **No API key needed** - backend handles authentication

To run backend locally:
```bash
cd ../backend_crystal
pip install -r requirements_simple.txt
python simple_backend.py
```

## ✨ Latest Features (May 2025)

### 🎨 Enhanced Journal with Animations
- **Unique Color Schemes**: Each tab has its own mystical palette
  - All Crystals: Purple gradient theme
  - Favorites: Pink/Gold gradient theme
  - By Purpose: Green gradient theme
  - Insights: Blue gradient theme
- **Parallax Scrolling**: Floating background particles
- **Micro-Animations**: Breathing buttons, floating cards, pulsing glows
- **Smart Display**: Chakra indicators and usage tags on cards

### 🌟 Birth Chart Integration (Premium)
- **Free Astrology API**: Accurate planetary calculations
- **Personalized AI Guidance**: Based on your sun, moon, and rising signs
- **Crystal Compatibility**: Recommendations aligned with your zodiac
- **Beautiful UI**: Animated starfield and rotating zodiac wheel

### 💎 Enhanced Crystal Properties
- **Primary Uses Section**: Visual tags for different applications
- **Smart Icons**: Context-aware icons for meditation, healing, etc.
- **Auto-Save**: Quick save identified crystals to collection
- **Rich Metadata**: Track size, quality, source, and notes

## 📱 App Features

### Core Features
- **AI Crystal Identification**: Multi-angle photo analysis
- **Spiritual Guidance**: Personalized metaphysical insights
- **Crystal Collection**: Track and manage your crystals
- **Journal System**: Log experiences and track usage
- **Mystical Animations**: Beautiful UI with depth effects

### Premium Features ($9.99/month)
- **Birth Chart Integration**: Astrological personalization
- **Unlimited Identifications**: No monthly limits
- **Spiritual Chat**: Direct AI guidance
- **Advanced Insights**: Deeper metaphysical analysis

### Pro Features ($19.99/month)
- **Multiple AI Models**: GPT-4, Claude, Gemini
- **Priority Support**: Direct access to team
- **Beta Features**: Early access to new tools
- **API Access**: Build your own integrations

## 🎯 Testing Guide

### 1. Test Journal Animations
- Open Journal from bottom navigation
- Switch between tabs to see color transitions
- Notice floating cards and parallax effects
- Try favoriting crystals (heart icon)

### 2. Test Birth Chart (Premium)
- Go to Settings → Birth Chart
- Click "Add Birth Chart"
- Enter test data:
  - Date: Any past date
  - Time: 14:30
  - Location: New York
- View your Big Three and crystal recommendations

### 3. Test Crystal Identification
- Click camera button
- Upload 1-5 crystal photos
- See enhanced results with:
  - Primary uses with icons
  - Chakra associations
  - Healing properties
  - Auto-save option

### 4. Test Collection Features
- After identifying, save to collection
- View in Journal → All Crystals
- See chakra dots and usage tags
- Track usage statistics in Insights tab

## 🛠️ Technical Details

### Architecture
```
lib/
├── models/          # Data models
│   ├── birth_chart.dart      # Astrology system
│   └── crystal.dart          # Crystal data
├── services/        # Business logic
│   ├── astrology_service.dart # Free API integration
│   └── backend_service.dart   # AI identification
├── screens/         # UI screens
│   ├── journal_screen.dart    # Enhanced with animations
│   └── birth_chart_screen.dart # New astrology UI
└── widgets/         # Reusable components
```

### Key Technologies
- **Flutter**: Cross-platform framework
- **Gemini AI**: Crystal identification (via backend)
- **Free Astrology API**: Birth chart calculations
- **Animations**: Custom parallax and micro-animations

### API Integration
- **Crystal ID**: Backend handles Gemini AI calls
- **Astrology**: Direct integration with freeastrologyapi.com
- **Storage**: Local with SharedPreferences
- **State**: Provider pattern

## 🚀 Deployment

### Build for Production
```bash
# Build optimized web version
flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true

# Output in build/web/
```

### Deploy to Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Current Deployments
- **Frontend**: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app
- **Backend**: https://crystal-grimoire-backend.onrender.com

## 🔧 Configuration

### Backend URL
Edit `/lib/config/backend_config.dart`:
```dart
static const String baseUrl = 'https://crystal-grimoire-backend.onrender.com';
```

### Subscription Tiers
- **Free**: 10 IDs/month, basic features
- **Premium**: $9.99/month - Unlimited, birth chart
- **Pro**: $19.99/month - All AI models
- **Founders**: $499 lifetime - Everything forever

## 📝 Development Notes

### Recent Improvements
1. **Performance**: Optimized animations for smooth 60fps
2. **UX**: Enhanced visual hierarchy and feedback
3. **Features**: Birth chart integration complete
4. **Polish**: Micro-animations throughout

### Known Issues
- Birth chart requires manual location entry (geocoding API planned)
- Some animations may lag on older devices
- Backend cold start can take 30 seconds

### Future Enhancements
- Planetary transits and aspects
- Crystal compatibility reports
- Moon phase recommendations
- Community features

## 🤝 Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

## 📄 License
Proprietary - All rights reserved

## 💜 Acknowledgments
- Gemini AI for crystal identification
- Free Astrology API for birth charts
- Flutter team for the framework
- Our mystical community for inspiration

---
Made with 💜 and ✨ by the Crystal Grimoire Team