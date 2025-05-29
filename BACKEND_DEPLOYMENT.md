# 🔮 Backend Deployment Guide

## Quick Deploy Options

### Option 1: Railway (Recommended)
1. Go to [Railway.app](https://railway.app)
2. Login with GitHub
3. Click "Deploy from GitHub repo"
4. Select: `Domusgpt/crystal-grimoire-clean`
5. Set root directory: `backend_crystal`
6. Railway will auto-detect Python and deploy

**Environment Variables to Set:**
- `PORT` = `8000`
- `HOST` = `0.0.0.0`

### Option 2: Render
1. Go to [Render.com](https://render.com)
2. Connect GitHub account
3. Create new "Web Service"
4. Select: `Domusgpt/crystal-grimoire-clean`
5. Set:
   - Root Directory: `backend_crystal`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `python app.py`

### Option 3: Fly.io
```bash
cd backend_crystal
fly launch --dockerfile
```

### Option 4: Local Development
```bash
cd backend_crystal
pip install -r requirements.txt
python app_server.py
```

## Expected Deployment URL Format
- Railway: `https://crystal-grimoire-backend-production.up.railway.app`
- Render: `https://crystal-grimoire-backend.onrender.com`

## API Endpoints Once Deployed

### Health Check
```
GET /health
```

### Anonymous Testing (No Auth Required)
```
POST /api/v1/crystal/identify-anonymous
Content-Type: multipart/form-data

Body:
- images: [image files]
- description: "optional description"
```

### With Authentication
```
POST /api/v1/auth/register
POST /api/v1/auth/login  
POST /api/v1/crystal/identify
GET /api/v1/crystal/collection/{user_id}
```

## Integration with Flutter App

Once deployed, update the Flutter app's backend configuration:

```dart
// lib/config/backend_config.dart
class BackendConfig {
  static const String baseUrl = 'https://YOUR-DEPLOYED-URL.com';
  static const String identifyEndpoint = '/api/v1/crystal/identify-anonymous';
}
```

## Features Available
✅ Gemini AI crystal identification
✅ Enhanced spiritual advisor prompt  
✅ User authentication system
✅ Crystal collection management
✅ Usage tracking and limits
✅ Anonymous testing endpoint
✅ SQLite database with automatic setup
✅ CORS enabled for web app integration

## Current Status
- ✅ Backend code ready
- ✅ Deployment configs created  
- ✅ GitHub repository updated
- 🔄 Awaiting cloud deployment