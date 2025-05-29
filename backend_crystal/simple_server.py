#!/usr/bin/env python3
"""
Simple Crystal API server - minimal version to prove integration works
"""

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
import base64
import json
import uuid
from datetime import datetime

app = FastAPI(title="CrystalGrimoire API", version="1.0.0")

# Enable CORS for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "http://localhost:8081", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "name": "CrystalGrimoire Simple API",
        "version": "1.0.0",
        "status": "online",
        "message": "Crystal identification and spiritual guidance"
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "crystalgrimoire-simple"}

@app.post("/api/v1/crystal/identify")
async def identify_crystal(
    images: List[UploadFile] = File(...),
    description: str = Form(""),
    session_id: str = Form(None)
):
    """
    Simple crystal identification endpoint that proves integration works
    """
    if not images:
        raise HTTPException(status_code=400, detail="At least one image required")
    
    # Simulate AI identification (in real version, this calls Gemini/OpenAI)
    crystal_names = ["Amethyst", "Clear Quartz", "Rose Quartz", "Citrine", "Black Tourmaline"]
    identified_crystal = crystal_names[len(images) % len(crystal_names)]
    
    # Mock response in Flutter's expected format
    response = {
        "sessionId": session_id or str(uuid.uuid4()),
        "fullResponse": f"""Ah, beloved seeker...

This beautiful crystal appears to be {identified_crystal}.

**Confidence Level**: HIGH

**Key Features Observed**:
- Beautiful crystalline structure
- Clear energy signature
- Harmonious vibrations

**Spiritual Properties**:
- Amplifies positive energy
- Enhances meditation
- Promotes spiritual growth
- Brings clarity and peace
- Supports emotional healing

**Chakra Associations**:
- Crown Chakra (spiritual connection)
- Heart Chakra (love and compassion)

**Care Instructions**:
- Cleanse under moonlight monthly
- Charge in sunlight briefly
- Store with loving intention

May this crystal guide you on your spiritual journey, beloved seeker. ✨""",
        
        "crystal": {
            "id": str(uuid.uuid4()),
            "name": identified_crystal,
            "scientificName": f"{identified_crystal} Variety",
            "description": f"A beautiful {identified_crystal} crystal with excellent spiritual properties",
            "metaphysicalProperties": [
                "Spiritual amplification",
                "Emotional healing", 
                "Mental clarity",
                "Energy purification"
            ],
            "healingProperties": [
                "Stress relief",
                "Anxiety reduction",
                "Sleep improvement",
                "Chakra balancing"
            ],
            "chakras": ["Crown", "Heart"],
            "colorDescription": "Clear to translucent with beautiful inner light",
            "hardness": "7 (Mohs scale)",
            "formation": "Hexagonal crystal system",
            "careInstructions": "Cleanse monthly under moonlight. Charge in morning sunlight.",
            "identificationDate": datetime.now().isoformat(),
            "imageUrls": [],
            "confidence": "high"
        },
        
        "confidence": "high",
        "needsMoreInfo": False,
        "suggestedAngles": [],
        "observedFeatures": [
            "Clear crystalline structure",
            "Good transparency",
            "Hexagonal formation",
            "Strong energy signature"
        ],
        "spiritualMessage": f"This {identified_crystal} resonates with divine love and will support your highest good.",
        "timestamp": datetime.now().isoformat()
    }
    
    return response

@app.get("/api/v1/crystal/collection/{user_id}")
async def get_collection(user_id: str):
    """Mock user collection"""
    return {
        "userId": user_id,
        "crystals": [],
        "count": 0
    }

@app.post("/api/v1/crystal/save")
async def save_crystal(
    crystal_data: dict,
    user_id: str = Form(...)
):
    """Mock save crystal"""
    return {
        "success": True,
        "crystalId": str(uuid.uuid4()),
        "message": "Crystal saved to your collection"
    }

@app.get("/api/v1/usage/{user_id}")
async def get_usage(user_id: str):
    """Mock usage stats"""
    return {
        "userId": user_id,
        "monthlyIdentifications": 2,
        "monthlyLimit": 4,
        "subscriptionTier": "free",
        "remainingIdentifications": 2
    }

if __name__ == "__main__":
    import uvicorn
    print("🔮 Starting CrystalGrimoire Simple API...")
    print("📚 API docs will be at: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)