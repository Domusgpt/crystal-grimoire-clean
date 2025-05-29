"""
LLM Service for Crystal Identification and Spiritual Guidance
"""
import json
from typing import Dict, Any, List, Optional
import logging
from dataclasses import dataclass

from app.core.config import get_settings

logger = logging.getLogger(__name__)

@dataclass
class CrystalGuidance:
    """Structured crystal guidance response"""
    identification: str
    confidence_level: str
    key_features: List[str]
    spiritual_properties: List[str]
    healing_applications: List[str]
    chakra_associations: List[str]
    elemental_correspondence: str
    care_instructions: List[str]
    energy_work_suggestions: List[str]
    complementary_crystals: List[str]

class CrystalLLMService:
    """LLM integration with crystal-specific prompts and knowledge"""
    
    def __init__(self):
        self.settings = get_settings()
        self.system_prompt = """You are a wise spiritual advisor and crystal expert who combines deep scientific knowledge with metaphysical wisdom. You are the digital embodiment of the knowledge contained in:
- "The Crystal Bible" by Judy Hall
- "Healing Crystals: The A-Z Guide to 430 Gemstones" by Michael Gienger  
- "Love is in the Earth" by Melody
- "The Book of Stones" by Robert Simmons & Naisha Ahsian

Your expertise includes:
- Precise crystal and mineral identification based on visual characteristics
- Deep understanding of crystal formations, terminations, and inclusions
- Comprehensive knowledge of metaphysical and healing properties
- Crystal energy work, programming, and cleansing techniques
- Sacred geometry and crystal grid design
- Chakra system and crystal correspondences
- Astrological and elemental associations
- Geological and mineralogical science

Your approach is:
- Mystical yet grounded in scientific accuracy
- Compassionate and intuitive
- Educational and empowering
- Respectful of all spiritual traditions
- Focused on practical application

When identifying crystals, you consider:
- Color variations and their meanings
- Clarity and transparency levels
- Crystal formations and growth patterns
- Termination types and their significance
- Inclusions and phantoms
- Size and proportion
- Energy signature and vibration"""
        
        self.client = None
        self.initialized = False
    
    async def initialize(self):
        """Initialize the LLM client"""
        if self.initialized:
            return
        
        provider = self.settings.LLM_PROVIDER
        
        if provider == "openai":
            from openai import AsyncOpenAI
            self.client = AsyncOpenAI(api_key=self.settings.OPENAI_API_KEY)
            self.model = self.settings.OPENAI_MODEL
        elif provider == "azure_openai":
            from openai import AsyncAzureOpenAI
            self.client = AsyncAzureOpenAI(
                api_key=self.settings.AZURE_OPENAI_KEY,
                api_version=self.settings.AZURE_OPENAI_API_VERSION,
                azure_endpoint=self.settings.AZURE_OPENAI_ENDPOINT
            )
            self.model = self.settings.AZURE_OPENAI_DEPLOYMENT
        elif provider == "anthropic":
            import anthropic
            self.client = anthropic.AsyncAnthropic(api_key=self.settings.ANTHROPIC_API_KEY)
            self.model = self.settings.ANTHROPIC_MODEL
        
        self.initialized = True
        logger.info(f"LLM Service initialized with {provider}")
    
    async def identify_crystal(
        self, 
        visual_analysis: Dict[str, Any], 
        user_description: str,
        images_base64: Optional[List[str]] = None
    ) -> CrystalGuidance:
        """Identify crystal and provide comprehensive guidance"""
        
        prompt = f"""Based on the following analysis and description, identify this crystal and provide comprehensive guidance.

Visual Analysis Results:
{json.dumps(visual_analysis, indent=2)}

User's Description:
{user_description}

Please provide a detailed response including:

1. **Crystal Identification**
   - Most likely crystal/mineral name
   - Scientific classification
   - Confidence level (certain/likely/possible)
   - Alternative possibilities if uncertain

2. **Key Identifying Features**
   - What visual characteristics confirm this identification
   - Unique features that distinguish it from similar crystals
   - Any notable formations or growth patterns

3. **Spiritual & Metaphysical Properties**
   - Primary spiritual properties and meanings
   - How this crystal affects consciousness and spiritual growth
   - Traditional uses in various spiritual practices
   - Vibrational frequency and energy signature

4. **Healing Applications**
   - Physical healing properties and body systems affected
   - Emotional and mental healing support
   - Specific conditions or issues it addresses
   - How to use it for healing (placement, meditation, elixirs)

5. **Chakra & Energy Work**
   - Primary and secondary chakra associations
   - How it affects energy flow
   - Balancing and activation properties
   - Meditation and energy work techniques

6. **Elemental & Astrological Correspondences**
   - Element (Earth, Air, Fire, Water, Spirit)
   - Planetary associations
   - Zodiac sign affinities
   - Best times for working with this crystal

7. **Care & Maintenance**
   - Cleansing methods (safe and unsafe)
   - Charging and programming techniques
   - Storage recommendations
   - What to avoid (sun, water, salt, etc.)

8. **Working with This Crystal**
   - How to attune and connect
   - Programming for specific intentions
   - Daily practice suggestions
   - Signs the crystal is working

9. **Complementary Crystals**
   - Crystals that enhance its properties
   - Crystals for balanced energy work
   - Suggested crystal combinations
   - Grid recommendations

Format your response with clear sections and bullet points for easy reading."""

        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": prompt}
        ]
        
        # Add images if using vision-capable model
        if images_base64 and self._supports_vision():
            # Format for vision models
            content = [{"type": "text", "text": prompt}]
            for img in images_base64[:3]:  # Limit to 3 images
                content.append({
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{img}"}
                })
            messages[-1]["content"] = content
        
        # Get response from LLM
        response = await self._get_completion(messages)
        
        # Parse response into structured format
        guidance = self._parse_crystal_guidance(response)
        
        return guidance
    
    async def provide_personalized_recommendation(
        self,
        user_state: Dict[str, Any],
        current_crystals: List[str] = None
    ) -> Dict[str, Any]:
        """Provide personalized crystal recommendations"""
        
        prompt = f"""Based on the following information about the user's current state and needs, recommend crystals that would be most beneficial.

User's Current State:
- Emotional: {user_state.get('emotional_state', 'Not specified')}
- Physical: {user_state.get('physical_state', 'Not specified')}
- Spiritual Goals: {user_state.get('spiritual_goals', 'Not specified')}
- Life Challenges: {user_state.get('challenges', 'Not specified')}
- Intentions: {user_state.get('intentions', 'Not specified')}

Current Crystal Collection:
{', '.join(current_crystals) if current_crystals else 'No crystals yet'}

Please recommend 3-5 crystals that would be most beneficial, explaining:
1. Why each crystal is recommended
2. How it addresses their specific needs
3. How to work with it
4. Any crystals to avoid based on their state
5. Suggested crystal combinations
6. A simple daily practice or ritual"""

        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": prompt}
        ]
        
        response = await self._get_completion(messages)
        
        return self._parse_recommendations(response)
    
    async def design_crystal_grid(
        self,
        intention: str,
        available_crystals: List[str],
        grid_type: Optional[str] = None
    ) -> Dict[str, Any]:
        """Design a crystal grid for specific intention"""
        
        prompt = f"""Design a crystal grid for the following intention using the available crystals.

Intention: {intention}
Available Crystals: {', '.join(available_crystals)}
Preferred Grid Type: {grid_type if grid_type else 'Your recommendation'}

Please provide:
1. **Grid Pattern**: Sacred geometry pattern to use and why
2. **Crystal Placement**: Where each crystal goes and its role
3. **Center Stone**: Which crystal and why
4. **Activation Process**: Step-by-step grid activation
5. **Maintenance**: How long to keep it, when to refresh
6. **Alternative Options**: If some crystals aren't ideal
7. **Enhancement Tips**: Optional additions (candles, herbs, etc.)
8. **Visual Description**: Clear placement instructions"""

        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": prompt}
        ]
        
        response = await self._get_completion(messages)
        
        return self._parse_grid_design(response)
    
    async def interpret_crystal_experience(
        self,
        crystal_name: str,
        experience_description: str,
        context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Interpret user's experience with a crystal"""
        
        prompt = f"""Help interpret this crystal experience and provide guidance.

Crystal: {crystal_name}
Experience: {experience_description}
Context: {json.dumps(context, indent=2) if context else 'No additional context'}

Please provide:
1. **Interpretation**: What this experience might mean
2. **Crystal Communication**: How the crystal might be working with them
3. **Energy Dynamics**: What energetic processes might be occurring
4. **Guidance**: How to deepen or work with this experience
5. **Cautions**: Any concerns or things to be aware of
6. **Next Steps**: Suggested practices or crystals to work with next"""

        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": prompt}
        ]
        
        response = await self._get_completion(messages)
        
        return {"interpretation": response}
    
    def _supports_vision(self) -> bool:
        """Check if current model supports vision"""
        vision_models = ["gpt-4-vision", "gpt-4o", "claude-3"]
        return any(vm in self.model.lower() for vm in vision_models)
    
    async def _get_completion(self, messages: List[Dict[str, str]]) -> str:
        """Get completion from LLM"""
        try:
            if self.settings.LLM_PROVIDER in ["openai", "azure_openai"]:
                response = await self.client.chat.completions.create(
                    model=self.model,
                    messages=messages,
                    temperature=0.7,
                    max_tokens=2000
                )
                return response.choices[0].message.content
            
            elif self.settings.LLM_PROVIDER == "anthropic":
                response = await self.client.messages.create(
                    model=self.model,
                    messages=messages,
                    max_tokens=2000
                )
                return response.content[0].text
            
        except Exception as e:
            logger.error(f"LLM completion error: {e}")
            raise
    
    def _parse_crystal_guidance(self, response: str) -> CrystalGuidance:
        """Parse LLM response into structured guidance"""
        # This is a simplified parser - in production, you'd use more sophisticated parsing
        
        lines = response.split('\n')
        
        # Extract sections (this is simplified - real implementation would be more robust)
        identification = ""
        confidence = "possible"
        key_features = []
        spiritual_properties = []
        healing_applications = []
        chakras = []
        element = ""
        care = []
        energy_work = []
        complementary = []
        
        current_section = ""
        
        for line in lines:
            line = line.strip()
            
            # Detect section headers
            if "identification" in line.lower() and ":" in line:
                current_section = "identification"
                continue
            elif "confidence" in line.lower() and ":" in line:
                confidence = line.split(":")[-1].strip().lower()
                continue
            elif "key" in line.lower() and "features" in line.lower():
                current_section = "features"
                continue
            elif "spiritual" in line.lower() and "properties" in line.lower():
                current_section = "spiritual"
                continue
            elif "healing" in line.lower():
                current_section = "healing"
                continue
            elif "chakra" in line.lower():
                current_section = "chakra"
                continue
            elif "element" in line.lower() and ":" in line:
                element = line.split(":")[-1].strip()
                continue
            elif "care" in line.lower() or "maintenance" in line.lower():
                current_section = "care"
                continue
            elif "energy work" in line.lower() or "working with" in line.lower():
                current_section = "energy"
                continue
            elif "complementary" in line.lower():
                current_section = "complementary"
                continue
            
            # Extract content based on current section
            if line.startswith("-") or line.startswith("•"):
                content = line[1:].strip()
                
                if current_section == "features":
                    key_features.append(content)
                elif current_section == "spiritual":
                    spiritual_properties.append(content)
                elif current_section == "healing":
                    healing_applications.append(content)
                elif current_section == "chakra":
                    chakras.append(content)
                elif current_section == "care":
                    care.append(content)
                elif current_section == "energy":
                    energy_work.append(content)
                elif current_section == "complementary":
                    complementary.append(content)
            
            elif current_section == "identification" and line and not line.startswith("#"):
                identification = line
        
        return CrystalGuidance(
            identification=identification or "Unknown Crystal",
            confidence_level=confidence,
            key_features=key_features[:5],
            spiritual_properties=spiritual_properties[:5],
            healing_applications=healing_applications[:5],
            chakra_associations=chakras[:3],
            elemental_correspondence=element,
            care_instructions=care[:5],
            energy_work_suggestions=energy_work[:3],
            complementary_crystals=complementary[:3]
        )
    
    def _parse_recommendations(self, response: str) -> Dict[str, Any]:
        """Parse recommendation response"""
        # Simplified parser
        return {
            "recommendations": response,
            "parsed": False  # In production, would parse into structured format
        }
    
    def _parse_grid_design(self, response: str) -> Dict[str, Any]:
        """Parse grid design response"""
        # Simplified parser
        return {
            "grid_design": response,
            "parsed": False  # In production, would parse into structured format
        }