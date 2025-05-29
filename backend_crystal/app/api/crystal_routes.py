"""
Crystal Identification API Routes
"""
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Depends, Request
from typing import List, Optional
import base64
import io
from PIL import Image

from app.services.vision_service import VisionService, CrystalAnalysis
from app.services.llm_service import CrystalLLMService, CrystalGuidance
from app.models.crystal import CrystalIdentificationRequest, CrystalIdentificationResponse

router = APIRouter()

@router.post("/identify", response_model=CrystalIdentificationResponse)
async def identify_crystal(
    request: Request,
    images: List[UploadFile] = File(..., description="Crystal images from multiple angles"),
    description: str = Form("", description="User's description of the crystal"),
    include_spiritual_properties: bool = Form(True),
    include_healing_properties: bool = Form(True),
    include_care_instructions: bool = Form(True)
):
    """
    Identify a crystal from uploaded images and description.
    
    Upload multiple images from different angles for best results.
    Include any known information about size, origin, or unique features in the description.
    """
    
    # Validate images
    if not images or len(images) == 0:
        raise HTTPException(status_code=400, detail="At least one image is required")
    
    if len(images) > 5:
        raise HTTPException(status_code=400, detail="Maximum 5 images allowed")
    
    # Get services from app state
    vision_service: VisionService = request.app.state.vision_service
    llm_service: CrystalLLMService = request.app.state.llm_service
    
    try:
        # Read and validate images
        image_bytes_list = []
        image_base64_list = []
        
        for image in images:
            # Check file type
            if not image.content_type.startswith('image/'):
                raise HTTPException(
                    status_code=400, 
                    detail=f"File {image.filename} is not an image"
                )
            
            # Read image bytes
            contents = await image.read()
            image_bytes_list.append(contents)
            
            # Convert to base64 for LLM (if vision-capable)
            image_base64_list.append(base64.b64encode(contents).decode())
            
            # Validate image can be opened
            try:
                img = Image.open(io.BytesIO(contents))
                img.verify()
            except Exception:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid image file: {image.filename}"
                )
        
        # Analyze images with vision service
        visual_analysis: CrystalAnalysis = await vision_service.analyze_crystal_images(
            image_bytes_list
        )
        
        # Get comprehensive guidance from LLM
        guidance: CrystalGuidance = await llm_service.identify_crystal(
            visual_analysis=visual_analysis.characteristics,
            user_description=description,
            images_base64=image_base64_list if llm_service._supports_vision() else None
        )
        
        # Build response
        response = CrystalIdentificationResponse(
            identification=guidance.identification,
            confidence_level=guidance.confidence_level,
            visual_analysis=visual_analysis.characteristics,
            key_features=guidance.key_features,
            potential_matches=[
                {
                    "name": match["name"],
                    "confidence": visual_analysis.confidence_scores.get(match["name"], 0.0),
                    "description": match.get("description", "")
                }
                for match in visual_analysis.potential_matches[:5]
            ]
        )
        
        # Add optional properties based on request
        if include_spiritual_properties:
            response.spiritual_properties = {
                "primary_properties": guidance.spiritual_properties,
                "chakra_associations": guidance.chakra_associations,
                "elemental_correspondence": guidance.elemental_correspondence
            }
        
        if include_healing_properties:
            response.healing_properties = {
                "applications": guidance.healing_applications,
                "energy_work": guidance.energy_work_suggestions
            }
        
        if include_care_instructions:
            response.care_instructions = guidance.care_instructions
        
        response.complementary_crystals = guidance.complementary_crystals
        
        # Add size information if available
        if visual_analysis.scale_info:
            response.size_estimation = {
                "estimated_size_cm": visual_analysis.scale_info.estimated_size_cm,
                "reference_type": visual_analysis.scale_info.reference_type,
                "confidence": visual_analysis.scale_info.confidence
            }
        
        return response
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")

@router.get("/database/{crystal_name}")
async def get_crystal_info(crystal_name: str):
    """
    Get detailed information about a specific crystal from the database.
    """
    
    from app.services.crystal_db_service import CrystalDBService
    db_service = CrystalDBService()
    
    try:
        crystal_info = await db_service.get_crystal_by_name(crystal_name)
        
        if not crystal_info:
            raise HTTPException(status_code=404, detail=f"Crystal '{crystal_name}' not found")
        
        return crystal_info
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@router.get("/search")
async def search_crystals(
    color: Optional[str] = None,
    chakra: Optional[str] = None,
    element: Optional[str] = None,
    property: Optional[str] = None,
    limit: int = 20
):
    """
    Search crystals by various properties.
    """
    
    from app.services.crystal_db_service import CrystalDBService
    db_service = CrystalDBService()
    
    try:
        results = await db_service.search_crystals(
            color=color,
            chakra=chakra,
            element=element,
            property=property,
            limit=limit
        )
        
        return {
            "count": len(results),
            "crystals": results
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search error: {str(e)}")

@router.post("/compare")
async def compare_crystals(
    request: Request,
    images1: List[UploadFile] = File(..., description="First crystal images"),
    images2: List[UploadFile] = File(..., description="Second crystal images"),
    description1: str = Form("", description="First crystal description"),
    description2: str = Form("", description="Second crystal description")
):
    """
    Compare two crystals to understand their differences and combined properties.
    """
    
    vision_service: VisionService = request.app.state.vision_service
    llm_service: CrystalLLMService = request.app.state.llm_service
    
    try:
        # Analyze both crystals
        crystal1_bytes = [await img.read() for img in images1]
        crystal2_bytes = [await img.read() for img in images2]
        
        analysis1 = await vision_service.analyze_crystal_images(crystal1_bytes)
        analysis2 = await vision_service.analyze_crystal_images(crystal2_bytes)
        
        # Get identifications
        guidance1 = await llm_service.identify_crystal(
            visual_analysis=analysis1.characteristics,
            user_description=description1
        )
        
        guidance2 = await llm_service.identify_crystal(
            visual_analysis=analysis2.characteristics,
            user_description=description2
        )
        
        # Get comparison analysis from LLM
        comparison_prompt = f"""Compare these two crystals and explain their differences and how they work together:

Crystal 1: {guidance1.identification}
Properties: {', '.join(guidance1.spiritual_properties[:3])}
Chakras: {', '.join(guidance1.chakra_associations)}

Crystal 2: {guidance2.identification}
Properties: {', '.join(guidance2.spiritual_properties[:3])}
Chakras: {', '.join(guidance2.chakra_associations)}

Explain:
1. Key differences between them
2. How they complement each other
3. Best uses for each
4. If they work well together
5. Any cautions about combining them"""

        comparison_response = await llm_service._get_completion([
            {"role": "system", "content": llm_service.system_prompt},
            {"role": "user", "content": comparison_prompt}
        ])
        
        return {
            "crystal1": {
                "identification": guidance1.identification,
                "confidence": guidance1.confidence_level,
                "key_properties": guidance1.spiritual_properties[:3]
            },
            "crystal2": {
                "identification": guidance2.identification,
                "confidence": guidance2.confidence_level,
                "key_properties": guidance2.spiritual_properties[:3]
            },
            "comparison": comparison_response
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Comparison error: {str(e)}")

@router.post("/energy-reading")
async def crystal_energy_reading(
    request: Request,
    images: List[UploadFile] = File(..., description="Crystal images"),
    intention: str = Form(..., description="Your intention or question"),
    current_state: str = Form("", description="Your current emotional/spiritual state")
):
    """
    Get an energy reading for how a crystal can help with your specific intention.
    """
    
    vision_service: VisionService = request.app.state.vision_service
    llm_service: CrystalLLMService = request.app.state.llm_service
    
    try:
        # Analyze crystal
        image_bytes = [await img.read() for img in images]
        analysis = await vision_service.analyze_crystal_images(image_bytes)
        
        # Get crystal identification
        guidance = await llm_service.identify_crystal(
            visual_analysis=analysis.characteristics,
            user_description=""
        )
        
        # Get personalized energy reading
        reading_prompt = f"""Provide a personalized energy reading for working with {guidance.identification} crystal.

User's Intention: {intention}
Current State: {current_state}

Crystal Properties: {', '.join(guidance.spiritual_properties[:3])}
Chakras: {', '.join(guidance.chakra_associations)}

Please provide:
1. How this crystal specifically addresses their intention
2. What energies it will bring into their life
3. How to work with it for their intention
4. What to expect as it works with them
5. Signs that it's working
6. Any messages or insights from the crystal's energy
7. Suggested ritual or practice"""

        reading = await llm_service._get_completion([
            {"role": "system", "content": llm_service.system_prompt},
            {"role": "user", "content": reading_prompt}
        ])
        
        return {
            "crystal": guidance.identification,
            "intention": intention,
            "energy_reading": reading
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Energy reading error: {str(e)}")