#!/usr/bin/env python3
"""
Entry point for deployment platforms
"""
import os
from app_server import app

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    host = os.environ.get("HOST", "0.0.0.0")
    
    print(f"🔮 Starting CrystalGrimoire Backend on {host}:{port}")
    print("📚 API docs available at: /docs")
    print("🔐 Features: Auth, Collections, Usage Tracking, Gemini AI")
    
    uvicorn.run(app, host=host, port=port)