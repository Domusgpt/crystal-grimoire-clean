"""
Crystal Models for CrystalGrimoire
"""
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime
from enum import Enum

class ChakraType(str, Enum):
    """Chakra classifications"""
    ROOT = "root"
    SACRAL = "sacral"
    SOLAR_PLEXUS = "solar_plexus"
    HEART = "heart"
    THROAT = "throat"
    THIRD_EYE = "third_eye"
    CROWN = "crown"
    EARTH_STAR = "earth_star"
    SOUL_STAR = "soul_star"

class ElementType(str, Enum):
    """Elemental correspondences"""
    EARTH = "earth"
    AIR = "air"
    FIRE = "fire"
    WATER = "water"
    SPIRIT = "spirit"
    STORM = "storm"

class CrystalSystem(str, Enum):
    """Crystal systems in mineralogy"""
    CUBIC = "cubic"
    TETRAGONAL = "tetragonal"
    ORTHORHOMBIC = "orthorhombic"
    HEXAGONAL = "hexagonal"
    TRIGONAL = "trigonal"
    MONOCLINIC = "monoclinic"
    TRICLINIC = "triclinic"
    AMORPHOUS = "amorphous"

# Request/Response Models
class CrystalIdentificationRequest(BaseModel):
    """Request model for crystal identification"""
    description: Optional[str] = Field(None, description="User's description of the crystal")
    include_spiritual_properties: bool = Field(True, description="Include spiritual properties")
    include_healing_properties: bool = Field(True, description="Include healing properties")
    include_care_instructions: bool = Field(True, description="Include care instructions")

class CrystalMatch(BaseModel):
    """A potential crystal match"""
    name: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    description: str

class SpiritualProperties(BaseModel):
    """Spiritual and metaphysical properties"""
    primary_properties: List[str]
    chakra_associations: List[str]
    elemental_correspondence: str
    zodiac_signs: Optional[List[str]] = None
    planetary_associations: Optional[List[str]] = None

class HealingProperties(BaseModel):
    """Healing and therapeutic properties"""
    applications: List[str]
    energy_work: List[str]
    physical_benefits: Optional[List[str]] = None
    emotional_benefits: Optional[List[str]] = None
    mental_benefits: Optional[List[str]] = None

class CrystalIdentificationResponse(BaseModel):
    """Response model for crystal identification"""
    identification: str = Field(..., description="Identified crystal name")
    confidence_level: str = Field(..., description="Confidence in identification")
    visual_analysis: Dict[str, Any] = Field(..., description="Visual characteristics")
    key_features: List[str] = Field(..., description="Key identifying features")
    potential_matches: List[CrystalMatch] = Field(..., description="Other possible matches")
    spiritual_properties: Optional[SpiritualProperties] = None
    healing_properties: Optional[HealingProperties] = None
    care_instructions: Optional[List[str]] = None
    complementary_crystals: Optional[List[str]] = None
    size_estimation: Optional[Dict[str, Any]] = None

# Database Models
class Crystal(BaseModel):
    """Crystal database model"""
    id: int
    name: str
    mineral_group: Optional[str]
    chemical_formula: Optional[str]
    crystal_system: Optional[CrystalSystem]
    mohs_hardness: Optional[float] = Field(None, ge=1.0, le=10.0)
    specific_gravity: Optional[float]
    refractive_index: Optional[str]
    description: str
    created_at: datetime
    updated_at: datetime

class CrystalProperty(BaseModel):
    """Crystal property model"""
    crystal_id: int
    property_type: str  # healing, spiritual, emotional
    property_name: str
    description: str
    chakras: List[ChakraType]
    elements: List[ElementType]
    zodiac_signs: Optional[List[str]] = None

class CrystalVisual(BaseModel):
    """Visual characteristics for crystal matching"""
    crystal_id: int
    color_primary: str
    color_secondary: Optional[str]
    transparency: str  # transparent, translucent, opaque
    luster: str  # vitreous, metallic, dull, etc.
    common_formations: List[str]
    common_inclusions: List[str]

# User Inventory Models
class UserCrystal(BaseModel):
    """User's crystal in their inventory"""
    id: int
    user_id: int
    crystal_id: int
    nickname: Optional[str]
    acquisition_date: Optional[datetime]
    source: Optional[str] = Field(None, description="Where acquired")
    notes: Optional[str]
    images: List[str] = Field(default_factory=list, description="Image URLs")
    energy_work_log: List[Dict[str, Any]] = Field(default_factory=list)
    created_at: datetime
    updated_at: datetime

class CrystalInventoryAdd(BaseModel):
    """Add crystal to inventory"""
    crystal_name: str
    nickname: Optional[str] = None
    acquisition_date: Optional[datetime] = None
    source: Optional[str] = None
    notes: Optional[str] = None

class CrystalInventoryUpdate(BaseModel):
    """Update crystal in inventory"""
    nickname: Optional[str] = None
    notes: Optional[str] = None
    source: Optional[str] = None

# Journal Models
class JournalEntry(BaseModel):
    """Crystal journal entry"""
    id: int
    user_id: int
    crystal_id: Optional[int]
    crystal_name: Optional[str]
    entry_type: str = Field(..., description="meditation, healing, dream, experience, etc.")
    title: str
    content: str
    mood_before: Optional[str]
    mood_after: Optional[str]
    insights: Optional[List[str]]
    created_at: datetime
    updated_at: datetime

class JournalEntryCreate(BaseModel):
    """Create journal entry"""
    crystal_id: Optional[int] = None
    crystal_name: Optional[str] = None
    entry_type: str
    title: str
    content: str
    mood_before: Optional[str] = None
    mood_after: Optional[str] = None
    insights: Optional[List[str]] = None

# Grid Models
class CrystalGridDesign(BaseModel):
    """Crystal grid design"""
    intention: str
    grid_pattern: str = Field(..., description="Sacred geometry pattern")
    center_stone: str
    surrounding_stones: List[Dict[str, str]] = Field(..., description="Position and crystal")
    activation_instructions: List[str]
    notes: Optional[str]
    created_at: datetime

class GridTemplate(BaseModel):
    """Pre-designed grid template"""
    id: int
    name: str
    intention_category: str
    description: str
    pattern_type: str
    required_crystals: List[str]
    optional_crystals: List[str]
    instructions: List[str]

# Recommendation Models
class UserStateInput(BaseModel):
    """User state for recommendations"""
    emotional_state: Optional[str] = None
    physical_state: Optional[str] = None
    spiritual_goals: Optional[str] = None
    challenges: Optional[str] = None
    intentions: Optional[str] = None
    current_crystals: Optional[List[str]] = None

class CrystalRecommendation(BaseModel):
    """Crystal recommendation"""
    crystal_name: str
    reason: str
    how_to_use: str
    expected_benefits: List[str]
    acquisition_priority: str = Field(..., description="high, medium, low")

class RecommendationResponse(BaseModel):
    """Recommendation response"""
    recommendations: List[CrystalRecommendation]
    crystals_to_avoid: Optional[List[Dict[str, str]]] = None
    suggested_combinations: Optional[List[List[str]]] = None
    daily_practice: Optional[str] = None