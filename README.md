# 🔮 CrystalGrimoire - AI Crystal Identification & Spiritual Guidance

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)
![Python](https://img.shields.io/badge/Python-3.8+-green)
![License](https://img.shields.io/badge/License-Proprietary-red)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Mobile%20%7C%20Desktop-orange)

A mystical crystal identification app that combines cutting-edge AI with spiritual wisdom to help seekers identify and connect with their crystalline companions.

## ✨ Features

- 📸 **AI-Powered Identification**: Take a photo and get instant crystal identification with 80%+ accuracy
- 🔮 **Spiritual Guidance**: Receive personalized metaphysical insights and chakra connections
- 📚 **Crystal Journal**: Track your collection and spiritual experiences
- 💎 **Multi-Platform**: Works on Web, iOS, Android, and Desktop
- 🎯 **Expert-Level Accuracy**: Enhanced mineralogy AI prompt for professional-grade identification
- 💜 **Beautiful UI**: Mystical purple theme with smooth animations

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.10+)
- Python 3.8+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/[YOUR_USERNAME]/crystal-grimoire-clean.git
   cd crystal-grimoire-clean
   ```

2. **Set up the backend**
   ```bash
   cd backend_crystal
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   
   # Add your Gemini API key to .env
   echo "GEMINI_API_KEY=your-key-here" > .env
   
   # Start the server
   python app_server.py
   ```

3. **Set up Flutter app**
   ```bash
   # In a new terminal
   cd crystal_grimoire_flutter
   flutter pub get
   
   # Run on web
   flutter run -d chrome
   
   # Run on mobile
   flutter run
   ```

## 🏗️ Architecture

```
CrystalGrimoire/
├── crystal_grimoire_flutter/    # Flutter cross-platform app
│   ├── lib/
│   │   ├── screens/           # UI screens
│   │   ├── services/          # AI integration, caching
│   │   ├── models/           # Data models
│   │   └── widgets/          # Reusable components
│   └── web/                   # Web-specific files
│
└── backend_crystal/           # FastAPI backend
    ├── app_server.py         # Main server with auth & AI
    └── app/                  # API routes and services
```

## 🔧 Configuration

### Backend Configuration
Create a `.env` file in `backend_crystal/`:
```env
GEMINI_API_KEY=your-gemini-api-key
SECRET_KEY=your-secret-key
DATABASE_URL=sqlite:///crystal_grimoire.db
```

### Flutter Configuration
Update `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String geminiApiKey = 'your-key-here';
  static const String backendUrl = 'http://localhost:8000';
}
```

## 📱 Platform-Specific Setup

### iOS
```bash
cd crystal_grimoire_flutter/ios
pod install
flutter build ios
```

### Android
```bash
flutter build apk --release
# or for Play Store:
flutter build appbundle --release
```

### Web Deployment
```bash
flutter build web --release
# Deploy build/web folder to your hosting
```

## 🧪 Testing

```bash
# Backend tests
cd backend_crystal
pytest

# Flutter tests
cd crystal_grimoire_flutter
flutter test
```

## 🚢 Deployment

### Backend (Fly.io)
```bash
cd backend_crystal
fly launch
fly deploy
```

### Frontend (Vercel/Netlify)
```bash
cd crystal_grimoire_flutter
flutter build web --release
# Deploy build/web folder
```

## 💰 Monetization

- **Free Tier**: 10 identifications/month
- **Premium**: $9.99/month - Unlimited IDs, spiritual chat
- **Pro**: $19.99/month - Advanced features, API access

## 🛣️ Roadmap

- [x] Core crystal identification
- [x] Enhanced AI accuracy (80%+)
- [ ] Crystal journal feature
- [ ] Payment integration
- [ ] Mobile app store launch
- [ ] Desktop applications
- [ ] Community features

## 🔒 Proprietary Software

This is proprietary software owned by Paul Phillips. For licensing inquiries, please contact: phillips.paul.email@gmail.com

## 📄 License

This project is PROPRIETARY SOFTWARE. All rights reserved. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google Gemini AI for powerful vision capabilities
- Flutter team for the amazing framework
- Crystal healing community for inspiration

## 📧 Contact

- Email: support@crystalgrimoire.app
- Discord: [Join our community](#)
- Twitter: [@CrystalGrimoire](#)

---

**Made with 💜 and ✨ for crystal seekers everywhere**