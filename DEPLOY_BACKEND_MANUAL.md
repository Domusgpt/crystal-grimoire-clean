# 🚀 Manual Backend Deployment Guide

## Current Status
✅ **Backend Code**: Ready in `/backend_crystal/`
✅ **GitHub**: Pushed to repository
✅ **Deployment Configs**: Created for Railway, Render, Fly.io

## Option 1: Deploy to Render (EASIEST - 5 minutes)

### Step-by-Step:
1. Go to **https://render.com**
2. Sign up/login with GitHub
3. Click **"New +"** → **"Web Service"**
4. Connect GitHub account if not connected
5. Search for: **`crystal-grimoire-clean`**
6. Click **"Connect"**
7. Configure:
   - **Name**: `crystal-grimoire-backend`
   - **Root Directory**: `backend_crystal`
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python app.py`
   - **Plan**: `Free`
8. Click **"Create Web Service"**

**Expected URL**: `https://crystal-grimoire-backend.onrender.com`

## Option 2: Deploy to Railway (ALSO EASY)

### Step-by-Step:
1. Go to **https://railway.app**
2. Login with GitHub
3. Click **"Deploy from GitHub repo"**
4. Select: **`Domusgpt/crystal-grimoire-clean`**
5. Set **Root Directory**: `backend_crystal`
6. Railway auto-detects Python and deploys
7. Set environment variables:
   - `PORT` = `8000`
   - `HOST` = `0.0.0.0`

**Expected URL**: `https://crystal-grimoire-backend-production.up.railway.app`

## Option 3: Fly.io (More Control)

### Step-by-Step:
1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Login: `flyctl auth login`
3. Deploy:
   ```bash
   cd backend_crystal
   flyctl launch --dockerfile
   flyctl deploy
   ```

## Test Deployment

Once deployed, test with:
```bash
curl https://YOUR-DEPLOYED-URL.com/health
```

Expected response:
```json
{"status": "healthy", "service": "crystalgrimoire-full"}
```

## Connect Flutter App

After deployment, update Flutter app configuration:

1. Edit: `crystal_grimoire_flutter/lib/config/backend_config.dart`
2. Update baseUrl to your deployed URL:
```dart
static const String baseUrl = 'https://YOUR-DEPLOYED-URL.com';
```

## API Testing

Test crystal identification without auth:
```bash
curl -X POST https://YOUR-DEPLOYED-URL.com/api/v1/crystal/identify-anonymous \
  -F "images=@test_crystal.jpg" \
  -F "description=Please identify this crystal"
```

## Next Steps After Deployment

1. ✅ Get backend URL
2. 🔄 Update Flutter app configuration
3. 🔄 Test full integration
4. 🔄 Deploy updated Flutter app

## Current Backend Features
✅ **Gemini AI Integration** - Enhanced spiritual advisor prompt
✅ **User Authentication** - JWT tokens, registration, login
✅ **Crystal Collection** - Save and manage identified crystals
✅ **Usage Tracking** - Monthly limits and subscription tiers
✅ **Anonymous Testing** - No auth required for demos
✅ **SQLite Database** - Automatically initialized
✅ **CORS Enabled** - Works with web frontend

**The backend is ready - just needs cloud deployment! 🚀**