# 🔮 Crystal Grimoire - Flutter App

A mystical crystal identification app with beautiful animations and spiritual guidance.

## 🚀 Quick Start (5 Minutes!)

### 1. Get a FREE API Key (No Credit Card!)

**Option A: Google Gemini (RECOMMENDED - Has Vision/Image Support)**
1. Go to https://makersuite.google.com/app/apikey
2. Click "Create API key"
3. Copy your key

**Option B: Groq (Also FREE but no image support yet)**
1. Go to https://console.groq.com/keys
2. Sign up and create key

### 2. Add Your API Key

Open `lib/config/api_config.dart` and add your key:
```dart
static const String geminiApiKey = 'YOUR_KEY_HERE'; // <-- Paste here!
```

### 3. Run the App

```bash
# Get dependencies
flutter pub get

# Run on your device/emulator
flutter run
```

## 📱 How to Test

1. **Launch the app** - You'll see the mystical home screen
2. **Tap "Identify Crystal"** - Opens the camera screen
3. **Take photos** - Capture 1-5 angles of any crystal (or even a rock!)
4. **Get identification** - The AI will analyze and provide spiritual guidance

## 🎨 Features

- ✨ Beautiful animations and mystical UI
- 📸 Multi-angle photo capture
- 🤖 AI-powered crystal identification
- 💎 Crystal collection management
- 🔮 Spiritual guidance and chakra info
- 💰 Free tier with upgrade options

## 🛠️ Troubleshooting

**"Please set your API key!" error**
- Make sure you added your key to `api_config.dart`
- Restart the app after adding the key

**Network errors**
- Check your internet connection
- Make sure the API service isn't blocked by firewall

**No identification results**
- Try better lighting
- Include something for scale (coin, ruler)
- Take multiple angles

## 🎯 What to Test

Try identifying:
- Real crystals (if you have any)
- Rocks from outside
- Glass objects (for fun!)
- Purple/clear objects to see if it thinks they're amethyst/quartz

The AI is pretty good at identifying crystal-like objects and will give mystical guidance even for regular rocks!

## 📝 Development

The app is built with:
- Flutter for cross-platform UI
- Google Gemini AI for crystal identification (FREE tier!)
- Beautiful custom animations
- Mystical purple theme

## 🔧 Customization

- Change AI provider in `api_config.dart` (defaultProvider)
- Adjust theme colors in `lib/config/theme.dart`
- Modify spiritual advisor personality in `ai_service.dart`

Enjoy your mystical crystal journey! 🔮✨