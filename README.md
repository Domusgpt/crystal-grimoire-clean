# 🔮 Crystal Grimoire - Enhanced Mystical Crystal Companion

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)
![Python](https://img.shields.io/badge/Python-3.8+-green)
![License](https://img.shields.io/badge/License-Proprietary-red)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Mobile-orange)

A mystical crystal identification app that combines AI-powered recognition with personalized spiritual guidance, featuring beautiful animations and astrological integration.

## ✨ Latest Updates (May 2025)

### 🎨 Enhanced Journal System
- **Unique Color Schemes**: Each section has its own mystical palette
- **Parallax Scrolling**: Floating background particles with depth effects  
- **Micro-Animations**: Breathing buttons, floating cards, pulsing glows
- **Smart Display**: Chakra indicators and usage tags on crystal cards

### 🌟 Birth Chart Integration (Premium)
- **Free Astrology API**: Accurate planetary calculations at no cost
- **Personalized AI Guidance**: Based on your sun, moon, and rising signs
- **Crystal Compatibility**: Recommendations aligned with your zodiac energies
- **Beautiful Visualization**: Animated starfield and rotating zodiac wheel

### 💎 Enhanced Crystal Properties
- **Primary Uses Section**: Visual tags for meditation, healing, protection
- **Smart Icons**: Context-aware icons for different applications
- **Auto-Save Feature**: Quick save identified crystals to collection
- **Rich Metadata**: Track size, quality, source, and personal notes

## 🚀 Quick Start

```bash
# Clone and navigate to Flutter app
git clone https://github.com/Domusgpt/crystal-grimoire-clean.git
cd crystal-grimoire-clean/crystal_grimoire_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

## 📱 Core Features

### Free Tier
- **AI Crystal Identification**: 10 identifications per month
- **Basic Collection**: Track your crystals
- **Spiritual Guidance**: General metaphysical insights
- **Beautiful Animations**: Full UI experience

### Premium ($9.99/month)
- **Unlimited Identifications**: No monthly limits
- **Birth Chart Integration**: Personalized astrological guidance
- **Enhanced Insights**: Deeper spiritual analysis
- **Priority Support**: Direct access to team

### Pro ($19.99/month)
- **Multiple AI Models**: GPT-4, Claude, Gemini
- **Advanced Features**: Beta access to new tools
- **API Access**: Build custom integrations
- **White-label Options**: Brand customization

## 🎯 Key Technologies

- **Frontend**: Flutter 3.10+ (Web/Mobile)
- **Backend**: Python FastAPI with Gemini AI
- **Astrology**: Free Astrology API integration
- **Animations**: Custom parallax and micro-animations
- **Storage**: Local with SharedPreferences
- **Deployment**: Vercel (Frontend) + Render (Backend)

## 🌟 Unique Features

### Mystical Animations
- Dynamic color schemes per journal section
- Parallax scrolling with floating particles
- Breathing effects on interactive elements
- Smooth transitions between screens

### Astrological Integration
- Birth chart calculation with planetary positions
- Zodiac-based crystal recommendations
- AI guidance incorporating astrological profile
- Beautiful cosmic visualizations

### Enhanced UX
- Auto-save identified crystals to collection
- Smart usage tracking and insights
- Chakra indicators on crystal cards
- Context-aware iconography

## 📂 Project Structure

```
crystal-grimoire-clean/
├── crystal_grimoire_flutter/     # Flutter app
│   ├── lib/
│   │   ├── models/              # Data models
│   │   ├── services/            # Business logic  
│   │   ├── screens/             # UI screens
│   │   └── widgets/             # Reusable components
│   └── README.md                # Detailed Flutter docs
├── backend_crystal/             # Python backend
│   ├── simple_backend.py        # Gemini AI integration
│   └── requirements_simple.txt  # Dependencies
├── archive/                     # Old documentation
├── DEVELOPMENT_STATUS.md        # Current project status
├── QUICK_START_GUIDE.md         # Setup instructions
└── TERMINAL_RESTART_CHECKLIST.md # Quick reference
```

## 🚀 Deployment

### Live Deployments
- **Frontend**: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app
- **Backend**: Ready for Render deployment

### Build Commands
```bash
# Build for production
flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true

# Deploy to Vercel
vercel --prod
```

## 🔧 Configuration

### Backend URL
Configure in `/crystal_grimoire_flutter/lib/config/backend_config.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### Astrology API
Uses freeastrologyapi.com (100% free, no key required)

## 📖 Documentation

- **[Development Status](DEVELOPMENT_STATUS.md)** - Complete feature overview
- **[Quick Start Guide](QUICK_START_GUIDE.md)** - Setup instructions
- **[Flutter README](crystal_grimoire_flutter/README.md)** - Detailed app docs
- **[Archive](archive/)** - Previous documentation versions

## 🎯 Testing the App

1. **Journal Animations**: Switch tabs to see color transitions
2. **Birth Chart**: Settings → Birth Chart (Premium feature)
3. **Crystal ID**: Camera → Upload photo → See enhanced results
4. **Collection**: Save crystals → View in Journal with new features

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

Proprietary - All rights reserved

## 💜 Acknowledgments

- **Gemini AI** for crystal identification
- **Free Astrology API** for birth chart calculations  
- **Flutter Team** for the amazing framework
- **Our Community** for inspiration and feedback

---

**Made with 💜 and ✨ by the Crystal Grimoire Team**

*Transform your crystal journey with AI-powered identification and personalized spiritual guidance.*