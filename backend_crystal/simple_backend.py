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

JOURNAL DATA REQUIREMENTS:
Your response will be parsed to create journal entries. Please structure your response to include:
1. Clear crystal identification with specific mineral name
2. 3-5 specific metaphysical properties
3. 2-4 healing applications
4. Associated chakras (be specific - Crown, Third Eye, Throat, Heart, Solar Plexus, Sacral, Root)
5. Astrological connections (elements, zodiac signs, planetary influences)
6. Specific meditation practices or rituals
7. Care and cleansing instructions
8. Personal spiritual message for the seeker

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
        
        # Parse response for structured data
        def extract_data_from_response(text):
            # Extract metaphysical properties
            metaphysical = []
            healing = []
            chakras = []
            elements = []
            zodiac_signs = []
            care_instructions = ""
            
            # Look for numbered lists and specific patterns
            lines = text.split('\n')
            
            # Extract metaphysical properties (look for numbered lists)
            for i, line in enumerate(lines):
                if any(word in line.lower() for word in ['metaphysical', 'properties', 'energy', 'spiritual']):
                    # Look for the next few lines for numbered items
                    for j in range(i+1, min(i+8, len(lines))):
                        if lines[j].strip().startswith(('1.', '2.', '3.', '4.', '5.', '-', '•')):
                            prop = lines[j].strip()
                            prop = prop.split('.', 1)[-1].strip() if '.' in prop else prop.lstrip('-•').strip()
                            if prop and len(prop) > 5:
                                metaphysical.append(prop[:50])  # Limit length
            
            # Extract chakras
            chakra_names = ['crown', 'third eye', 'throat', 'heart', 'solar plexus', 'sacral', 'root']
            for chakra in chakra_names:
                if chakra.lower() in text.lower():
                    chakras.append(chakra.title())
            
            # Extract elements
            element_names = ['fire', 'earth', 'air', 'water']
            for element in element_names:
                if element.lower() in text.lower():
                    elements.append(element.title())
            
            # Extract zodiac signs
            zodiac = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 
                     'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
            for sign in zodiac:
                if sign.lower() in text.lower():
                    zodiac_signs.append(sign.title())
            
            # Extract care instructions
            care_keywords = ['cleanse', 'charge', 'care', 'clean', 'purify', 'moonlight', 'sunlight']
            for line in lines:
                if any(keyword in line.lower() for keyword in care_keywords):
                    care_instructions = line.strip()
                    break
            
            return {
                'metaphysical': metaphysical[:5] if metaphysical else [
                    "Amplifies spiritual energy", "Enhances intuition", "Promotes emotional healing"
                ],
                'healing': healing[:4] if healing else [
                    "Stress relief", "Mental clarity", "Emotional balance"
                ],
                'chakras': chakras[:3] if chakras else ["Crown", "Heart"],
                'elements': elements[:2] if elements else ["Air"],
                'zodiac_signs': zodiac_signs[:3] if zodiac_signs else [],
                'care_instructions': care_instructions or "Cleanse under moonlight, charge in sunlight"
            }
        
        parsed_data = extract_data_from_response(full_response)
        
        # Response in Flutter's expected format with enhanced journal data
        response = {
            "sessionId": session_id,
            "identificationId": str(uuid.uuid4()),
            "fullResponse": full_response,
            "crystal": {
                "id": str(uuid.uuid4()),
                "name": identified_crystal,
                "scientificName": f"{identified_crystal} Variety",
                "description": full_response[:200] + "..." if len(full_response) > 200 else full_response,
                "metaphysicalProperties": parsed_data['metaphysical'],
                "healingProperties": parsed_data['healing'],
                "chakras": parsed_data['chakras'],
                "colorDescription": "Beautiful natural coloration",
                "hardness": "7 (Mohs scale)",
                "formation": "Natural crystal formation",
                "careInstructions": parsed_data['care_instructions'],
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
            "timestamp": datetime.now().isoformat(),
            # Enhanced journal data
            "journalData": {
                "elements": parsed_data['elements'],
                "zodiacSigns": parsed_data['zodiac_signs'],
                "meditationSuggestions": [
                    "Hold during morning meditation",
                    "Place on altar during full moon",
                    "Carry for daily energy protection"
                ],
                "affirmations": [
                    f"I am open to the healing energy of {identified_crystal}",
                    "My spiritual path is illuminated with divine light",
                    "I trust my intuition and inner wisdom"
                ],
                "ritualSuggestions": [
                    "New moon intention setting",
                    "Chakra balancing session",
                    "Energy cleansing ritual"
                ]
            }
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