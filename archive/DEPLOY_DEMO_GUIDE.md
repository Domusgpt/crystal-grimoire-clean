# 🚀 Deploy CrystalGrimoire Demo

This guide will help you deploy a working demo that people can try.

## Option 1: Quick Local Demo (5 minutes)

### 1. Start Backend
```bash
cd backend_crystal
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app_server.py
```

### 2. Start Flutter Web
```bash
cd crystal_grimoire_flutter
flutter run -d web-server --web-port 8080
```

### 3. Share with ngrok (for remote access)
```bash
# Install ngrok: https://ngrok.com/download
ngrok http 8080
# Share the https URL with people to try
```

---

## Option 2: Free Cloud Deployment (Recommended)

### Backend on Render.com (Free)

1. **Create `render.yaml`** in backend_crystal/:
```yaml
services:
  - type: web
    name: crystal-grimoire-api
    env: python
    buildCommand: "pip install -r requirements.txt"
    startCommand: "uvicorn app_server:app --host 0.0.0.0 --port $PORT"
    envVars:
      - key: GEMINI_API_KEY
        sync: false  # Add manually in dashboard
```

2. **Deploy to Render**:
   - Push code to GitHub
   - Connect Render to your repo
   - It will auto-deploy

### Frontend on Vercel (Free)

1. **Update API URL** in `crystal_grimoire_flutter/lib/config/backend_config.dart`:
```dart
class BackendConfig {
  static const String apiUrl = 'https://crystal-grimoire-api.onrender.com';
}
```

2. **Build and Deploy**:
```bash
cd crystal_grimoire_flutter
flutter build web --release

# Install Vercel CLI
npm i -g vercel

# Deploy
cd build/web
vercel --prod
```

---

## Option 3: All-in-One on Fly.io

### 1. Create Dockerfile in root:
```dockerfile
# Backend build
FROM python:3.10-slim as backend
WORKDIR /app
COPY backend_crystal/requirements.txt .
RUN pip install -r requirements.txt
COPY backend_crystal/ .

# Flutter build
FROM ghcr.io/cirruslabs/flutter:stable as flutter-build
WORKDIR /app
COPY crystal_grimoire_flutter/ .
RUN flutter pub get
RUN flutter build web --release

# Final image
FROM python:3.10-slim
WORKDIR /app

# Copy backend
COPY --from=backend /app /app

# Copy Flutter build
COPY --from=flutter-build /app/build/web /app/static

# Install production server
RUN pip install uvicorn

# Start script
COPY <<EOF start.sh
#!/bin/bash
uvicorn app_server:app --host 0.0.0.0 --port 8080
EOF

RUN chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]
```

### 2. Deploy to Fly.io:
```bash
# Install flyctl: https://fly.io/docs/getting-started/installing-flyctl/
fly auth login
fly launch --name crystal-grimoire-demo
fly secrets set GEMINI_API_KEY="your-api-key"
fly deploy
```

---

## 🔒 Protecting Your Demo

### 1. **Add Demo Limits**:
- Limit to 3 identifications per user
- Add watermark to results
- Disable some premium features

### 2. **Add Analytics**:
```javascript
// In index.html
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
```

### 3. **Add Demo Banner**:
```dart
// In home_screen.dart
Container(
  color: Colors.orange,
  child: Text("DEMO VERSION - Limited Features"),
)
```

---

## 🎯 Quick Demo URL Options

### Free Hosting Services:
1. **Vercel**: crystal-grimoire.vercel.app
2. **Netlify**: crystal-grimoire.netlify.app
3. **Render**: crystal-grimoire.onrender.com
4. **Fly.io**: crystal-grimoire.fly.dev

### Estimated Costs:
- **Free Tier**: 0$/month (with limits)
- **Basic**: ~$7/month (Fly.io)
- **Production**: ~$20-50/month

---

## 📊 Demo Features to Showcase

1. **Landing Page**: Beautiful mystical UI
2. **Camera Feature**: Take/upload crystal photos
3. **AI Identification**: Show 80%+ accuracy
4. **Spiritual Guidance**: Demonstrate unique value
5. **Results Screen**: Professional crystal analysis

---

## 🚨 Important Security Notes

1. **Use Demo API Key**: Create separate Gemini key for demo
2. **Add Rate Limiting**: Prevent abuse
3. **Monitor Usage**: Set up alerts
4. **Protect Source**: Don't expose proprietary algorithms

---

## 📱 Sharing Your Demo

### Demo Link Template:
```
🔮 Try CrystalGrimoire - AI Crystal Identifier

Identify any crystal with 80%+ accuracy using AI!
✨ Instant identification
💜 Spiritual guidance
📱 Works on any device

Try it now: [YOUR-DEMO-URL]

Limited time demo - Full app coming soon!
```

### Where to Share:
- Crystal Facebook groups
- Reddit: r/Crystals, r/mineralcollectors
- Crystal Instagram pages
- Spiritual forums
- Product Hunt (coming soon)

---

Ready to deploy your demo and start getting user feedback! 🚀