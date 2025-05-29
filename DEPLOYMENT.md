# 🔮 Crystal Grimoire Deployment Guide

## Live Demo
**✅ Current Deployment**: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app

## Quick Redeploy

### Windows Users
```cmd
redeploy.cmd
```

### Linux/Mac Users  
```bash
./redeploy.sh
```

## Manual Deployment Steps

1. **Build Flutter Web App**
   ```bash
   cd crystal_grimoire_flutter
   flutter build web --release
   ```

2. **Copy Web Files to Root**
   ```bash
   cp -r build/web/* .
   ```

3. **Deploy to Vercel**
   ```bash
   npx vercel --prod --yes
   ```

## Repository Status
- **GitHub**: https://github.com/Domusgpt/crystal-grimoire-clean
- **Visibility**: Public (for GitHub Pages capability)
- **License**: Proprietary (All rights reserved)

## Deployment Architecture
- **Frontend**: Flutter Web (deployed to Vercel)
- **Static Files**: Served directly from Vercel CDN
- **AI Service**: Multi-provider (Gemini/OpenAI/Groq) with demo fallback
- **Platform**: Cross-platform web deployment

## Troubleshooting

### Build Issues
- Ensure Flutter is installed: `flutter doctor`
- Clear build cache: `flutter clean && flutter pub get`
- Check web support: `flutter config --enable-web`

### Deployment Issues
- Verify Vercel authentication: `npx vercel whoami`
- Check team access: `npx vercel teams ls`
- Clear Vercel cache: `rm -rf .vercel`

### Access Issues
- Use production URL: `crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app`
- Avoid deployment-specific URLs (they may return 401)

## Features Available in Demo
✅ Camera capture and gallery selection
✅ Multi-angle photo instructions
✅ AI-powered crystal identification (demo mode)
✅ Mystical UI with animations
✅ Chakra associations and spiritual guidance
✅ Results display with confidence levels
✅ Cross-platform web compatibility

**Note**: For full AI functionality, add API keys to `lib/config/api_config.dart`