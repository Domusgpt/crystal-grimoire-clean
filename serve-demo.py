#!/usr/bin/env python3
"""
Simple server to serve the CrystalGrimoire demo
Run this script and share the ngrok URL with people
"""

import http.server
import socketserver
import os
import webbrowser
from pathlib import Path

# Configuration
PORT = 8080
WEB_DIR = "crystal_grimoire_flutter/build/web"

def main():
    print("🔮 Starting CrystalGrimoire Demo Server...")
    
    # Check if build exists
    if not os.path.exists(WEB_DIR):
        print(f"❌ Build directory not found: {WEB_DIR}")
        print("Run 'flutter build web' first!")
        return
    
    # Change to web directory
    os.chdir(WEB_DIR)
    
    # Create server
    Handler = http.server.SimpleHTTPRequestHandler
    
    try:
        with socketserver.TCPServer(("", PORT), Handler) as httpd:
            print(f"✅ Demo server running at: http://localhost:{PORT}")
            print(f"📁 Serving: {os.getcwd()}")
            print(f"")
            print(f"🌐 To share with others:")
            print(f"   1. Install ngrok: https://ngrok.com/download")
            print(f"   2. Run: ngrok http {PORT}")
            print(f"   3. Share the https URL")
            print(f"")
            print(f"🔮 Demo Features:")
            print(f"   ✨ Beautiful mystical UI")
            print(f"   📸 Camera interface") 
            print(f"   🎯 Upload crystal photos")
            print(f"   💜 Spiritual guidance format")
            print(f"")
            print(f"⚠️  Note: Crystal identification requires backend")
            print(f"   But UI/UX demo works perfectly!")
            print(f"")
            print(f"Press Ctrl+C to stop server")
            
            # Open browser
            webbrowser.open(f'http://localhost:{PORT}')
            
            # Start serving
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print(f"\n👋 Demo server stopped")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()