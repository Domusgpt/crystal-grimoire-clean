#!/bin/bash

echo "🔮 Deploying CrystalGrimoire Demo to Vercel..."

# Check if backend is configured for demo
if grep -q "localhost:8000" crystal_grimoire_flutter/lib/config/backend_config.dart; then
    echo "⚠️  WARNING: Backend is still pointing to localhost!"
    echo "The demo will work but crystal identification will fail without backend."
    echo "Consider deploying backend to Render.com first."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Deploy to Vercel
cd crystal_grimoire_flutter/build/web

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm i -g vercel
fi

echo "🚀 Deploying to Vercel..."
vercel --prod

echo "
✅ Demo deployed successfully!

Next steps:
1. Share the URL with potential users
2. Deploy backend for full functionality (see DEPLOY_DEMO_GUIDE.md)
3. Monitor usage and gather feedback

Remember: This is a DEMO. Add watermarks and limits to protect your IP!
"