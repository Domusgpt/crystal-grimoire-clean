#!/bin/bash

# 🔮 Crystal Grimoire Easy Redeploy Script
# Builds Flutter web app and deploys to Vercel

echo "🔮 Starting Crystal Grimoire deployment..."

# Navigate to Flutter app directory
cd crystal_grimoire_flutter

echo "📱 Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Flutter build failed!"
    exit 1
fi

echo "🌐 Copying web files to root for deployment..."
cp -r build/web/* .

echo "🚀 Deploying to Vercel..."
npx vercel --prod --yes

if [ $? -eq 0 ]; then
    echo "✅ Deployment successful!"
    echo "🔮 Live demo: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app"
    echo "📂 Repository: https://github.com/Domusgpt/crystal-grimoire-clean"
else
    echo "❌ Deployment failed!"
    exit 1
fi

echo "🔮 Crystal Grimoire deployment complete!"