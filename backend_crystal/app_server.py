#!/usr/bin/env python3
"""
Full-Featured CrystalGrimoire Backend Server
"""

from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List, Optional, Dict, Any
import base64
import json
import uuid
import httpx
import sqlite3
import hashlib
import jwt
from datetime import datetime, timedelta
from pathlib import Path
import os

app = FastAPI(title="CrystalGrimoire API", version="2.0.0")

# Security
security = HTTPBearer()
SECRET_KEY = "crystal-grimoire-secret-key-change-in-production"
ALGORITHM = "HS256"

# Database setup
DATABASE_PATH = "crystal_grimoire.db"

# Enable CORS for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "http://localhost:8081", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gemini API configuration
GEMINI_API_KEY = "AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4"
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

async def init_database():
    """Initialize SQLite database"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    # Users table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            subscription_tier TEXT DEFAULT 'free',
            monthly_identifications INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Crystal identifications table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS crystal_identifications (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            session_id TEXT,
            crystal_name TEXT,
            confidence REAL,
            full_response TEXT,
            images_hash TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)
    
    # User collections table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_collections (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            crystal_identification_id TEXT,
            notes TEXT,
            favorite BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (crystal_identification_id) REFERENCES crystal_identifications (id)
        )
    """)
    
    # Usage tracking table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usage_tracking (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            action_type TEXT,
            monthly_count INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)
    
    conn.commit()
    conn.close()

def get_db():
    """Get database connection"""
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row
    return conn

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Get current user from JWT token"""
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

async def call_gemini_api(images: List[UploadFile], description: str) -> tuple[str, str]:
    """Call Gemini API for crystal identification"""
    
    spiritual_prompt = """You are the CrystalGrimoire Spiritual Advisor - a mystical guide who channels both ancient wisdom 
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
        
        # Build Gemini request
        parts = [
            {
                'text': spiritual_prompt + '\n\n' + 
                       (description or 'Please identify this crystal and provide spiritual guidance.')
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

@app.on_event("startup")
async def startup_event():
    await init_database()

@app.get("/")
async def root():
    return {
        "name": "CrystalGrimoire Full API",
        "version": "2.0.0",
        "status": "online",
        "message": "Crystal identification and spiritual guidance with full backend features",
        "features": [
            "User authentication",
            "Crystal identification with Gemini AI",
            "User collections",
            "Usage tracking",
            "Subscription management"
        ]
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "crystalgrimoire-full"}

# Authentication endpoints
@app.post("/api/v1/auth/register")
async def register(email: str = Form(...), password: str = Form(...)):
    """Register a new user"""
    conn = get_db()
    cursor = conn.cursor()
    
    # Check if user exists
    cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
    if cursor.fetchone():
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Hash password
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    user_id = str(uuid.uuid4())
    
    # Create user
    cursor.execute(
        "INSERT INTO users (id, email, password_hash) VALUES (?, ?, ?)",
        (user_id, email, password_hash)
    )
    conn.commit()
    conn.close()
    
    # Generate JWT token
    token_data = {"sub": user_id, "exp": datetime.utcnow() + timedelta(days=30)}
    token = jwt.encode(token_data, SECRET_KEY, algorithm=ALGORITHM)
    
    return {
        "access_token": token,
        "token_type": "bearer",
        "user_id": user_id,
        "email": email
    }

@app.post("/api/v1/auth/login")
async def login(email: str = Form(...), password: str = Form(...)):
    """Login user"""
    conn = get_db()
    cursor = conn.cursor()
    
    # Check credentials
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    cursor.execute(
        "SELECT id, email, subscription_tier FROM users WHERE email = ? AND password_hash = ?",
        (email, password_hash)
    )
    user = cursor.fetchone()
    conn.close()
    
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Generate JWT token
    token_data = {"sub": user["id"], "exp": datetime.utcnow() + timedelta(days=30)}
    token = jwt.encode(token_data, SECRET_KEY, algorithm=ALGORITHM)
    
    return {
        "access_token": token,
        "token_type": "bearer",
        "user_id": user["id"],
        "email": user["email"],
        "subscription_tier": user["subscription_tier"]
    }

# Crystal identification with auth
@app.post("/api/v1/crystal/identify")
async def identify_crystal(
    images: List[UploadFile] = File(...),
    description: str = Form(""),
    session_id: Optional[str] = Form(None),
    user_id: str = Depends(get_current_user)
):
    """Identify crystal with authentication and usage tracking"""
    
    if not images:
        raise HTTPException(status_code=400, detail="At least one image required")
    
    conn = get_db()
    cursor = conn.cursor()
    
    # Check usage limits
    cursor.execute("""
        SELECT monthly_identifications, subscription_tier 
        FROM users WHERE id = ?
    """, (user_id,))
    user = cursor.fetchone()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check limits for free users
    if user["subscription_tier"] == "free" and user["monthly_identifications"] >= 4:
        raise HTTPException(
            status_code=429, 
            detail="Monthly identification limit reached. Upgrade to premium for unlimited access."
        )
    
    session_id = session_id or str(uuid.uuid4())
    
    try:
        # Call Gemini API
        identified_crystal, full_response = await call_gemini_api(images, description)
        
        # Parse confidence based on new mystical expressions
        confidence = 0.7
        if "spirits clearly reveal" in full_response.lower() or "spirits have shown" in full_response.lower():
            confidence = 0.9
        elif "energies suggest" in full_response.lower() or "vibrations indicate" in full_response.lower():
            confidence = 0.75
        elif "i sense" in full_response.lower() or "feels like" in full_response.lower():
            confidence = 0.55
        elif "message is unclear" in full_response.lower() or "guards its secrets" in full_response.lower():
            confidence = 0.3
        
        # Generate image hash for caching
        image_data = b""
        for image in images:
            await image.seek(0)
            image_data += await image.read()
        images_hash = hashlib.sha256(image_data).hexdigest()
        
        # Save identification to database
        identification_id = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO crystal_identifications 
            (id, user_id, session_id, crystal_name, confidence, full_response, images_hash)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (identification_id, user_id, session_id, identified_crystal, confidence, full_response, images_hash))
        
        # Update user usage count
        cursor.execute("""
            UPDATE users SET monthly_identifications = monthly_identifications + 1
            WHERE id = ?
        """, (user_id,))
        
        # Track usage
        cursor.execute("""
            INSERT INTO usage_tracking (id, user_id, action_type)
            VALUES (?, ?, 'crystal_identification')
        """, (str(uuid.uuid4()), user_id))
        
        conn.commit()
        conn.close()
        
        # Response in Flutter's expected format
        response = {
            "sessionId": session_id,
            "identificationId": identification_id,
            "fullResponse": full_response,
            "crystal": {
                "id": identification_id,
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
            "spiritualMessage": f"This {identified_crystal} has chosen you for your spiritual journey.",
            "timestamp": datetime.now().isoformat()
        }
        
        return response
        
    except Exception as e:
        conn.close()
        raise HTTPException(status_code=500, detail=f"Crystal identification failed: {str(e)}")

# Collection endpoints
@app.get("/api/v1/crystal/collection/{user_id}")
async def get_collection(user_id: str, current_user: str = Depends(get_current_user)):
    """Get user's crystal collection"""
    if user_id != current_user:
        raise HTTPException(status_code=403, detail="Access denied")
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT ci.*, uc.notes, uc.favorite, uc.created_at as saved_at
        FROM crystal_identifications ci
        JOIN user_collections uc ON ci.id = uc.crystal_identification_id
        WHERE uc.user_id = ?
        ORDER BY uc.created_at DESC
    """, (user_id,))
    
    crystals = [dict(row) for row in cursor.fetchall()]
    conn.close()
    
    return {
        "userId": user_id,
        "crystals": crystals,
        "count": len(crystals)
    }

@app.post("/api/v1/crystal/save")
async def save_crystal(
    crystal_id: str = Form(...),
    notes: str = Form(""),
    user_id: str = Depends(get_current_user)
):
    """Save crystal to user collection"""
    conn = get_db()
    cursor = conn.cursor()
    
    # Check if crystal exists and belongs to user
    cursor.execute("""
        SELECT id FROM crystal_identifications 
        WHERE id = ? AND user_id = ?
    """, (crystal_id, user_id))
    
    if not cursor.fetchone():
        raise HTTPException(status_code=404, detail="Crystal not found")
    
    # Check if already saved
    cursor.execute("""
        SELECT id FROM user_collections 
        WHERE user_id = ? AND crystal_identification_id = ?
    """, (user_id, crystal_id))
    
    if cursor.fetchone():
        raise HTTPException(status_code=400, detail="Crystal already in collection")
    
    # Save to collection
    collection_id = str(uuid.uuid4())
    cursor.execute("""
        INSERT INTO user_collections (id, user_id, crystal_identification_id, notes)
        VALUES (?, ?, ?, ?)
    """, (collection_id, user_id, crystal_id, notes))
    
    conn.commit()
    conn.close()
    
    return {
        "success": True,
        "collectionId": collection_id,
        "message": "Crystal saved to your collection"
    }

@app.get("/api/v1/usage/{user_id}")
async def get_usage(user_id: str, current_user: str = Depends(get_current_user)):
    """Get usage statistics"""
    if user_id != current_user:
        raise HTTPException(status_code=403, detail="Access denied")
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT monthly_identifications, subscription_tier 
        FROM users WHERE id = ?
    """, (user_id,))
    user = cursor.fetchone()
    conn.close()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    limits = {
        "free": 4,
        "premium": -1,  # unlimited
        "pro": -1      # unlimited
    }
    
    monthly_limit = limits.get(user["subscription_tier"], 4)
    remaining = max(0, monthly_limit - user["monthly_identifications"]) if monthly_limit > 0 else -1
    
    return {
        "userId": user_id,
        "monthlyIdentifications": user["monthly_identifications"],
        "monthlyLimit": monthly_limit,
        "subscriptionTier": user["subscription_tier"],
        "remainingIdentifications": remaining
    }

# Anonymous endpoint for testing without auth
@app.post("/api/v1/crystal/identify-anonymous")
async def identify_crystal_anonymous(
    images: List[UploadFile] = File(...),
    description: str = Form(""),
    session_id: Optional[str] = Form(None)
):
    """Identify crystal without authentication (for testing)"""
    
    if not images:
        raise HTTPException(status_code=400, detail="At least one image required")
    
    session_id = session_id or str(uuid.uuid4())
    
    try:
        # Call Gemini API
        identified_crystal, full_response = await call_gemini_api(images, description)
        
        # Parse confidence based on new mystical expressions
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
    print("🔮 Starting CrystalGrimoire Full Backend...")
    print("📚 API docs will be at: http://localhost:8000/docs")
    print("🔐 Features: Auth, Collections, Usage Tracking, Gemini AI")
    uvicorn.run(app, host="0.0.0.0", port=8000)