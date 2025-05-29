"""
Flutter App API Adapter - Maps Flutter expected endpoints to backend routes
"""
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Request
from typing import List, Optional
import json

from app.api.crystal_routes import identify_crystal as backend_identify

router = APIRouter()

@router.post("/crystal/identify")
async def flutter_identify_crystal(
    request: Request,
    images: List[UploadFile] = File(...),
    description: str = Form(""),
    session_id: Optional[str] = Form(None),
    previous_context: Optional[str] = Form(None)
):
    """
    Flutter app compatibility endpoint - maps to backend crystal identification
    """
    # Call the backend identify function with adapted parameters
    response = await backend_identify(
        request=request,
        images=images,
        description=description,
        include_spiritual_properties=True,
        include_healing_properties=True,
        include_care_instructions=True
    )
    
    # Transform response to match Flutter's expected format
    flutter_response = {
        "sessionId": session_id or "default",
        "fullResponse": f"""Ah, beloved seeker...

This is {response.identification.name}.

{response.identification.description}

**Confidence Level**: {response.confidence_level}

**Key Features Observed**:
{chr(10).join(f'- {feature}' for feature in response.key_features)}

**Spiritual Properties**:
{chr(10).join(f'- {prop}' for prop in response.spiritual_properties.get('primary_properties', [])[:5])}

**Chakra Associations**:
{chr(10).join(f'- {chakra}' for chakra in response.spiritual_properties.get('chakra_associations', []))}

**Care Instructions**:
{chr(10).join(f'- {instruction}' for instruction in response.care_instructions[:3])}

May this crystal guide you on your spiritual journey, beloved seeker.""",
        
        "crystal": {
            "id": session_id or "generated",
            "name": response.identification.name,
            "scientificName": response.identification.scientific_name or "",
            "description": response.identification.description,
            "metaphysicalProperties": response.spiritual_properties.get('primary_properties', []),
            "healingProperties": response.healing_properties.get('applications', []) if response.healing_properties else [],
            "chakras": response.spiritual_properties.get('chakra_associations', []),
            "colorDescription": response.visual_analysis.color.primary_color if response.visual_analysis else "",
            "hardness": response.identification.mohs_hardness or "",
            "formation": response.identification.crystal_system or "",
            "careInstructions": ". ".join(response.care_instructions[:3]),
            "identificationDate": "2025-05-28T00:00:00Z",
            "imageUrls": [],
            "confidence": response.confidence_level.lower()
        },
        
        "confidence": response.confidence_level.lower(),
        "needsMoreInfo": response.confidence_level.lower() == "low",
        "suggestedAngles": ["Side view", "Top view", "With light behind"] if response.confidence_level.lower() == "low" else [],
        "observedFeatures": response.key_features,
        "spiritualMessage": f"This {response.identification.name} resonates with divine energy and will support your spiritual journey.",
        "timestamp": "2025-05-28T00:00:00Z"
    }
    
    return flutter_response

@router.get("/crystal/collection/{user_id}")
async def get_user_collection(user_id: str):
    """
    Get user's crystal collection (stub for now)
    """
    return {
        "userId": user_id,
        "crystals": [],
        "count": 0
    }

@router.post("/crystal/save")
async def save_crystal(
    crystal_data: dict,
    user_id: str = Form(...)
):
    """
    Save crystal to user's collection (stub for now)
    """
    return {
        "success": True,
        "crystalId": "saved_crystal_id",
        "message": "Crystal saved to your collection"
    }

@router.get("/usage/{user_id}")
async def get_usage_stats(user_id: str):
    """
    Get user's usage statistics
    """
    return {
        "userId": user_id,
        "monthlyIdentifications": 2,
        "monthlyLimit": 4,
        "subscriptionTier": "free",
        "remainingIdentifications": 2
    }