#!/bin/bash

echo "🚀 Deploying CrystalGrimoire Demo..."

# Build Flutter web
echo "📦 Building Flutter web app..."
cd crystal_grimoire_flutter
flutter build web --release

# Create vercel.json for configuration
cat > build/web/vercel.json << EOF
{
  "routes": [
    {
      "src": "/(.*)",
      "headers": {
        "Cache-Control": "public, max-age=3600"
      },
      "dest": "/\$1"
    }
  ]
}
EOF

# Deploy to Vercel
echo "🌐 Deploying to Vercel..."
cd build/web
npx vercel --prod --yes

echo "✅ Demo deployed! Share the URL with potential users."
echo "⚠️  Note: Backend needs to be deployed separately for full functionality"