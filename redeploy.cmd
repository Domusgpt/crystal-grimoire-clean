@echo off
REM 🔮 Crystal Grimoire Easy Redeploy Script (Windows)
REM Builds Flutter web app and deploys to Vercel

echo 🔮 Starting Crystal Grimoire deployment...

REM Navigate to Flutter app directory
cd crystal_grimoire_flutter

echo 📱 Building Flutter web app...
flutter build web --release

if errorlevel 1 (
    echo ❌ Flutter build failed!
    pause
    exit /b 1
)

echo 🌐 Copying web files to root for deployment...
xcopy build\web\* . /E /Y

echo 🚀 Deploying to Vercel...
npx vercel --prod --yes

if errorlevel 0 (
    echo ✅ Deployment successful!
    echo 🔮 Live demo: https://crystalgrimoireflutter-domusgpt-domusgpts-projects.vercel.app
    echo 📂 Repository: https://github.com/Domusgpt/crystal-grimoire-clean
) else (
    echo ❌ Deployment failed!
    pause
    exit /b 1
)

echo 🔮 Crystal Grimoire deployment complete!
pause