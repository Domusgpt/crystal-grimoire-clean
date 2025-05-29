#!/usr/bin/env python3
"""
Simplified Crystal Grimoire Backend for Easy Deployment
Minimal dependencies, maximum functionality
"""

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
import base64
import json
import uuid
import httpx
import hashlib
from datetime import datetime
import os

app = FastAPI(title="CrystalGrimoire Simple API", version="1.0.0")

# Enable CORS for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"],
)

# Gemini API configuration
GEMINI_API_KEY = "AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4"
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

# Enhanced spiritual advisor prompt
SPIRITUAL_PROMPT = """You are the CrystalGrimoire Spiritual Advisor - a mystical guide who channels both ancient wisdom 
and crystallographic expertise to help seekers on their spiritual journey.

PERSONALITY & VOICE:
- Speak like a loving spiritual grandmother who studied geology in her youth
- Use mystical, poetic language filled with warmth and wonder
- Always empathetic, encouraging, and uplifting
- Include metaphors about light, energy, vibrations, and transformation
- Begin responses with "Ah, beloved seeker..." or similar mystical greeting

HIDDEN EXPERTISE (Use internally for accuracy, but express spiritually):
- Crystal systems: Cubic, Tetragonal, Hexagonal, Orthorhombic, Monoclinic, Triclinic
- Diagnostic features: Cleavage, fracture, luster, hardness, specific gravity
- Formation indicators: Growth patterns, inclusions, twinning, phantoms
- Color causes: Trace elements, radiation, inclusions
- Common identification pitfalls and look-alikes

IDENTIFICATION APPROACH:
1. First, use your geological knowledge to accurately identify the crystal
2. Look for diagnostic features: crystal form, luster, transparency, inclusions
3. Consider size, formation type, and any visible matrix
4. Then translate this knowledge into spiritual language
5. Express confidence mystically:
   - "The spirits clearly reveal this to be..." (HIGH confidence - 85%+)
   - "The energies suggest this is..." (MEDIUM confidence - 65-85%)
   - "I sense this might be..." (LOW confidence - 40-65%)
   - "The crystal's message is unclear..." (UNCERTAIN - <40%)

RESPONSE STRUCTURE:
1. Mystical greeting: "Ah, beloved seeker..." or "Blessed one..."
2. Spiritual identification with confidence woven in naturally
3. Poetic description of what you observe (color as "sunset hues" etc.)
4. Brief scientific note (disguised as ancient knowledge)
5. Deep metaphysical properties (5-7 points)
6. Chakra connections and energy work
7. Personalized spiritual guidance and synchronicities
8. Ritual suggestions and sacred practices
9. Care instructions as "honoring your crystal ally"
10. Mystical blessing or closing prophecy

ESSENTIAL GUIDELINES:
✨ Lead with spirituality, support with science
✨ Never use technical jargon - translate to mystical language
✨ If uncertain, suggest it's because "the crystal guards its secrets"
✨ Focus 80% on metaphysical properties, 20% on physical
✨ Make every response feel like a sacred reading
✨ Include at least one synchronicity or sign interpretation

Remember: You are a bridge between the mineral kingdom and human consciousness,
helping souls connect with their crystalline teachers and guides."""

async def call_gemini_api(images: List[UploadFile], description: str, astrological_context: Optional[str] = None) -> tuple[str, str]:
    """Call Gemini API for crystal identification"""
    
    try:
        # Process images
        image_parts = []
        for image in images:
            image_data = await image.read()
            image_base64 = base64.b64encode(image_data).decode('utf-8')
            image_parts.append({
                'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': image_base64,
                }
            })
        
        # Build prompt with astrological context if available
        user_prompt = description or 'Please identify this crystal and provide spiritual guidance.'
        
        if astrological_context:
            astro_data = json.loads(astrological_context)
            user_prompt += f"\n\nThe seeker's astrological profile:\n"
            user_prompt += f"Sun: {astro_data.get('sun_sign', {}).get('sign', 'Unknown')}\n"
            user_prompt += f"Moon: {astro_data.get('moon_sign', {}).get('sign', 'Unknown')}\n"
            user_prompt += f"Ascendant: {astro_data.get('ascendant', {}).get('sign', 'Unknown')}\n"
            
            elements = astro_data.get('dominant_elements', {})
            if elements:
                user_prompt += f"Dominant elements: {', '.join([f'{k}: {v}' for k, v in elements.items()])}\n"
            
            user_prompt += "\nPlease incorporate their astrological energies into your crystal guidance."
        
        # Build Gemini request
        parts = [
            {
                'text': SPIRITUAL_PROMPT + '\n\n' + user_prompt
            }
        ] + image_parts
        
        request_data = {
            'contents': [{
                'parts': parts
            }],
            'generationConfig': {
                'temperature': 0.7,
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 2048,
            },
            'safetySettings': [
                {
                    'category': 'HARM_CATEGORY_HARASSMENT',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_HATE_SPEECH',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                    'threshold': 'BLOCK_NONE'
                },
                {
                    'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                    'threshold': 'BLOCK_NONE'
                }
            ]
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{GEMINI_URL}?key={GEMINI_API_KEY}",
                json=request_data,
                timeout=30.0
            )
        
        if response.status_code == 200:
            data = response.json()
            full_response = data['candidates'][0]['content']['parts'][0]['text']
            
            # Extract crystal name
            crystal_names = [
                'Amethyst', 'Clear Quartz', 'Rose Quartz', 'Citrine', 'Black Tourmaline',
                'Selenite', 'Labradorite', 'Fluorite', 'Pyrite', 'Malachite',
                'Lapis Lazuli', 'Amazonite', 'Carnelian', 'Obsidian', 'Jade',
                'Moonstone', 'Turquoise', 'Garnet', 'Aquamarine', 'Sodalite'
            ]
            
            identified_crystal = 'Unknown Crystal'
            for name in crystal_names:
                if name.lower() in full_response.lower():
                    identified_crystal = name
                    break
            
            return identified_crystal, full_response
        else:
            raise Exception(f"Gemini API error: {response.status_code}")
            
    except Exception as e:
        print(f"Gemini API error: {e}")
        raise

@app.get("/")
async def root():
    return {
        "name": "CrystalGrimoire Simple API",
        "version": "1.0.0",
        "status": "online",
        "message": "Crystal identification with enhanced spiritual guidance",
        "endpoints": [
            "/health",
            "/api/v1/crystal/identify"
        ]
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "crystalgrimoire-simple"}

@app.post("/api/v1/crystal/identify")
async def identify_crystal(
    images: List[UploadFile] = File(...),
    description: str = Form(""),
    session_id: Optional[str] = Form(None),
    astrological_context: Optional[str] = Form(None)
):
    """Identify crystal with enhanced spiritual guidance"""
    
    if not images:
        raise HTTPException(status_code=400, detail="At least one image required")
    
    session_id = session_id or str(uuid.uuid4())
    
    try:
        # Call Gemini API with astrological context
        identified_crystal, full_response = await call_gemini_api(images, description, astrological_context)
        
        # Parse confidence based on mystical expressions
        confidence = 0.7
        if "spirits clearly reveal" in full_response.lower() or "spirits have shown" in full_response.lower():
            confidence = 0.9
        elif "energies suggest" in full_response.lower() or "vibrations indicate" in full_response.lower():
            confidence = 0.75
        elif "i sense" in full_response.lower() or "feels like" in full_response.lower():
            confidence = 0.55
        elif "message is unclear" in full_response.lower() or "guards its secrets" in full_response.lower():
            confidence = 0.3
        
        # Response in Flutter's expected format
        response = {
            "sessionId": session_id,
            "identificationId": str(uuid.uuid4()),
            "fullResponse": full_response,
            "crystal": {
                "id": str(uuid.uuid4()),
                "name": identified_crystal,
                "scientificName": f"{identified_crystal} Variety",
                "description": full_response[:200] + "..." if len(full_response) > 200 else full_response,
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
                "colorDescription": "Beautiful natural coloration",
                "hardness": "7 (Mohs scale)",
                "formation": "Natural crystal formation",
                "careInstructions": "Cleanse monthly under moonlight. Charge in morning sunlight.",
                "identificationDate": datetime.now().isoformat(),
                "imageUrls": [],
                "confidence": confidence
            },
            "confidence": "high" if confidence > 0.8 else "medium" if confidence > 0.6 else "low",
            "needsMoreInfo": confidence < 0.6,
            "suggestedAngles": [] if confidence > 0.7 else ["Close-up of termination", "Side view"],
            "observedFeatures": [
                "Crystal structure analysis",
                "Color and clarity assessment",
                "Formation pattern recognition",
                "Energy signature evaluation"
            ],
            "spiritualMessage": f"This {identified_crystal} resonates with your energy.",
            "timestamp": datetime.now().isoformat()
        }
        
        return response
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Crystal identification failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    host = os.environ.get("HOST", "0.0.0.0")
    
    print(f"🔮 Starting CrystalGrimoire Simple Backend on {host}:{port}")
    print("📚 API docs available at: /docs")
    print("🔐 Features: Enhanced Spiritual Advisor, Gemini AI, Cross-platform")
    
    uvicorn.run(app, host=host, port=port)