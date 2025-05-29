# 🎯 RENDER DEPLOYMENT - QUICK REFERENCE CARD

## 📝 Copy These EXACT Values:

```
Name:           crystal-grimoire-backend
Region:         Oregon (US West)
Branch:         main
Root Directory: backend_crystal
Environment:    Python 3
Build Command:  pip install -r requirements_simple.txt
Start Command:  python simple_backend.py
Plan:           Free
```

## 🔧 Environment Variables (Optional):
```
PORT = 8000
HOST = 0.0.0.0
```

## ✅ Deployment Checklist:
- [ ] Login to https://dashboard.render.com
- [ ] Click "New +" → "Web Service"
- [ ] Connect `crystal-grimoire-clean` repository
- [ ] Enter all values EXACTLY as shown above
- [ ] Click "Advanced" and add environment variables
- [ ] Click "Create Web Service"
- [ ] Wait 3-5 minutes for deployment
- [ ] Copy your backend URL when done

## 🔍 What to Look For:
- Green "Live" status = Success! ✅
- URL format: `https://crystal-grimoire-backend-[random].onrender.com`
- Test by visiting the URL in your browser

## 📞 When Deployed:
Come back here with your backend URL and I'll connect everything!