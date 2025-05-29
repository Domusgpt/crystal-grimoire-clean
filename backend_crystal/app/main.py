"""
CrystalGrimoire Vision API - Crystal Identification & Spiritual Guidance
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

from app.core.config import get_settings
from app.core.database import init_database
from app.api import crystal_routes, inventory_routes, journal_routes, recommendation_routes

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    logger.info("Starting CrystalGrimoire Vision API...")
    settings = get_settings()
    
    # Initialize database
    await init_database()
    
    # Initialize LLM service
    from app.services.llm_service import CrystalLLMService
    llm_service = CrystalLLMService()
    await llm_service.initialize()
    app.state.llm_service = llm_service
    
    # Initialize vision service
    from app.services.vision_service import VisionService
    vision_service = VisionService()
    app.state.vision_service = vision_service
    
    logger.info("CrystalGrimoire Vision API started successfully")
    
    yield
    
    logger.info("Shutting down CrystalGrimoire Vision API...")

def create_app() -> FastAPI:
    """Create and configure the FastAPI application"""
    settings = get_settings()
    
    app = FastAPI(
        title="CrystalGrimoire Vision API",
        description="Crystal identification and spiritual guidance system",
        version="1.0.0",
        lifespan=lifespan
    )
    
    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include routers
    app.include_router(crystal_routes.router, prefix="/api/v1/crystals", tags=["crystals"])
    app.include_router(inventory_routes.router, prefix="/api/v1/inventory", tags=["inventory"])
    app.include_router(journal_routes.router, prefix="/api/v1/journal", tags=["journal"])
    app.include_router(recommendation_routes.router, prefix="/api/v1/recommendations", tags=["recommendations"])
    
    return app

app = create_app()

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "CrystalGrimoire Vision API",
        "version": "1.0.0",
        "status": "online",
        "features": [
            "Crystal identification from images",
            "Spiritual and metaphysical properties",
            "Personal inventory management",
            "Crystal journaling",
            "Personalized recommendations",
            "Crystal grid design"
        ]
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "crystalgrimoire-vision"}

if __name__ == "__main__":
    import uvicorn
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.PORT,
        reload=settings.DEBUG
    )