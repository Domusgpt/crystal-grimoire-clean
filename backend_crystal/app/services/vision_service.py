"""
Vision Service for Crystal Image Analysis
"""
import base64
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
import numpy as np
from PIL import Image
import io
import logging

logger = logging.getLogger(__name__)

@dataclass
class CrystalFeatures:
    """Extracted features from crystal images"""
    dominant_colors: List[Tuple[int, int, int]]
    transparency_score: float  # 0-1, where 1 is fully transparent
    luster_type: str
    detected_formations: List[str]
    termination_types: List[str]
    inclusion_patterns: List[str]
    estimated_hardness: Optional[float]
    crystal_system: Optional[str]

@dataclass
class ScaleReference:
    """Detected scale reference in image"""
    reference_type: str  # 'ruler', 'coin', 'hand', etc.
    estimated_size_cm: float
    confidence: float

@dataclass
class CrystalAnalysis:
    """Complete analysis results"""
    characteristics: Dict[str, Any]
    potential_matches: List[Dict[str, Any]]
    confidence_scores: Dict[str, float]
    scale_info: Optional[ScaleReference]

class VisionService:
    """Handles crystal image analysis and feature extraction"""
    
    def __init__(self):
        self.color_mappings = {
            "clear": [(255, 255, 255), (240, 240, 240)],
            "purple": [(128, 0, 128), (147, 112, 219), (138, 43, 226)],
            "pink": [(255, 192, 203), (255, 182, 193)],
            "green": [(0, 128, 0), (34, 139, 34), (144, 238, 144)],
            "blue": [(0, 0, 255), (30, 144, 255), (135, 206, 235)],
            "black": [(0, 0, 0), (47, 79, 79)],
            "yellow": [(255, 255, 0), (255, 215, 0)],
            "orange": [(255, 165, 0), (255, 140, 0)],
            "red": [(255, 0, 0), (220, 20, 60)],
            "brown": [(139, 69, 19), (160, 82, 45)]
        }
        
        self.formation_patterns = {
            "cluster": ["multiple_points", "grouped_crystals"],
            "single_point": ["terminated", "wand"],
            "geode": ["cavity", "druzy_interior"],
            "massive": ["no_distinct_crystals", "solid_form"],
            "phantom": ["ghost_crystal", "internal_layers"],
            "twin": ["joined_crystals", "contact_twin"]
        }
    
    async def analyze_crystal_images(self, images: List[bytes]) -> CrystalAnalysis:
        """Analyze multiple crystal images"""
        
        # Extract features from each image
        all_features = []
        scale_refs = []
        
        for img_bytes in images:
            image = self._load_image(img_bytes)
            features = await self._extract_features(image)
            all_features.append(features)
            
            scale = await self._detect_scale_reference(image)
            if scale:
                scale_refs.append(scale)
        
        # Combine features from multiple angles
        combined_features = self._combine_features(all_features)
        
        # Best scale reference
        best_scale = max(scale_refs, key=lambda x: x.confidence) if scale_refs else None
        
        # Build characteristics
        characteristics = {
            "colors": [self._color_name(c) for c in combined_features.dominant_colors],
            "transparency": self._transparency_description(combined_features.transparency_score),
            "luster": combined_features.luster_type,
            "formations": combined_features.detected_formations,
            "terminations": combined_features.termination_types,
            "inclusions": combined_features.inclusion_patterns,
            "estimated_size": f"{best_scale.estimated_size_cm:.1f} cm" if best_scale else "Unknown",
            "crystal_system": combined_features.crystal_system
        }
        
        # Find potential matches
        from app.services.crystal_db_service import CrystalDBService
        db_service = CrystalDBService()
        matches = await db_service.find_matches(characteristics)
        
        # Calculate confidence scores
        confidence_scores = self._calculate_confidence(matches, combined_features)
        
        return CrystalAnalysis(
            characteristics=characteristics,
            potential_matches=matches,
            confidence_scores=confidence_scores,
            scale_info=best_scale
        )
    
    def _load_image(self, img_bytes: bytes) -> Image.Image:
        """Load image from bytes"""
        return Image.open(io.BytesIO(img_bytes))
    
    async def _extract_features(self, image: Image.Image) -> CrystalFeatures:
        """Extract visual features from a single image"""
        
        # Color analysis
        colors = self._analyze_colors(image)
        
        # Transparency analysis
        transparency = self._analyze_transparency(image)
        
        # Luster analysis
        luster = self._analyze_luster(image)
        
        # Formation detection
        formations = self._detect_formations(image)
        
        # Termination analysis
        terminations = self._analyze_terminations(image)
        
        # Inclusion detection
        inclusions = self._detect_inclusions(image)
        
        return CrystalFeatures(
            dominant_colors=colors,
            transparency_score=transparency,
            luster_type=luster,
            detected_formations=formations,
            termination_types=terminations,
            inclusion_patterns=inclusions,
            estimated_hardness=None,  # Would need additional analysis
            crystal_system=self._estimate_crystal_system(formations, terminations)
        )
    
    def _analyze_colors(self, image: Image.Image) -> List[Tuple[int, int, int]]:
        """Extract dominant colors from image"""
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Simple color quantization
        image_small = image.resize((150, 150))
        pixels = list(image_small.getdata())
        
        # Get most common colors (simplified)
        from collections import Counter
        color_counts = Counter(pixels)
        dominant = [color for color, count in color_counts.most_common(5)]
        
        return dominant[:3]  # Top 3 colors
    
    def _analyze_transparency(self, image: Image.Image) -> float:
        """Estimate transparency level (0-1)"""
        # This is a simplified version - real implementation would be more complex
        # Could analyze edge detection, light transmission patterns, etc.
        
        # Convert to grayscale
        gray = image.convert('L')
        pixels = np.array(gray)
        
        # High variance in brightness might indicate transparency
        variance = np.var(pixels)
        
        # Normalize to 0-1 scale
        transparency_score = min(variance / 10000, 1.0)
        
        return transparency_score
    
    def _analyze_luster(self, image: Image.Image) -> str:
        """Determine luster type"""
        # Simplified - would analyze reflection patterns
        # Real implementation would use more sophisticated image analysis
        
        gray = image.convert('L')
        pixels = np.array(gray)
        
        # High contrast might indicate metallic or vitreous luster
        contrast = np.std(pixels)
        
        if contrast > 80:
            return "vitreous"
        elif contrast > 60:
            return "metallic"
        elif contrast > 40:
            return "resinous"
        else:
            return "dull"
    
    def _detect_formations(self, image: Image.Image) -> List[str]:
        """Detect crystal formations"""
        # Simplified - real implementation would use edge detection,
        # shape analysis, and possibly ML models
        
        formations = []
        
        # Convert to grayscale for edge detection
        gray = np.array(image.convert('L'))
        
        # Simple edge detection (would use Canny or similar in production)
        edges = np.gradient(gray)
        edge_strength = np.sqrt(edges[0]**2 + edges[1]**2)
        
        # High edge density might indicate cluster
        if np.mean(edge_strength) > 50:
            formations.append("cluster")
        
        # Additional formation detection would go here
        
        return formations
    
    def _analyze_terminations(self, image: Image.Image) -> List[str]:
        """Analyze crystal terminations"""
        # Simplified version
        terminations = []
        
        # Would analyze shape of crystal ends
        # Looking for pointed, flat, or complex terminations
        terminations.append("single_terminated")  # Placeholder
        
        return terminations
    
    def _detect_inclusions(self, image: Image.Image) -> List[str]:
        """Detect inclusion patterns"""
        inclusions = []
        
        # Would analyze internal patterns, color variations, etc.
        # This is a placeholder
        gray = np.array(image.convert('L'))
        
        # Look for internal variations
        if np.std(gray) > 30:
            inclusions.append("mineral_inclusions")
        
        return inclusions
    
    async def _detect_scale_reference(self, image: Image.Image) -> Optional[ScaleReference]:
        """Detect scale references like rulers or coins"""
        # This would use object detection in a real implementation
        # Placeholder for now
        
        # Would detect common references:
        # - Rulers (cm/inch markings)
        # - Coins (known sizes)
        # - Hands (average size estimation)
        
        return None  # Placeholder
    
    def _combine_features(self, features_list: List[CrystalFeatures]) -> CrystalFeatures:
        """Combine features from multiple images"""
        if not features_list:
            raise ValueError("No features to combine")
        
        if len(features_list) == 1:
            return features_list[0]
        
        # Combine colors from all angles
        all_colors = []
        for f in features_list:
            all_colors.extend(f.dominant_colors)
        
        # Get most common colors across all images
        from collections import Counter
        color_counts = Counter(all_colors)
        dominant_colors = [color for color, count in color_counts.most_common(3)]
        
        # Average transparency
        avg_transparency = np.mean([f.transparency_score for f in features_list])
        
        # Most common luster
        luster_counts = Counter([f.luster_type for f in features_list])
        most_common_luster = luster_counts.most_common(1)[0][0]
        
        # Combine all detected features
        all_formations = []
        all_terminations = []
        all_inclusions = []
        
        for f in features_list:
            all_formations.extend(f.detected_formations)
            all_terminations.extend(f.termination_types)
            all_inclusions.extend(f.inclusion_patterns)
        
        # Remove duplicates
        unique_formations = list(set(all_formations))
        unique_terminations = list(set(all_terminations))
        unique_inclusions = list(set(all_inclusions))
        
        return CrystalFeatures(
            dominant_colors=dominant_colors,
            transparency_score=avg_transparency,
            luster_type=most_common_luster,
            detected_formations=unique_formations,
            termination_types=unique_terminations,
            inclusion_patterns=unique_inclusions,
            estimated_hardness=None,
            crystal_system=features_list[0].crystal_system  # Take first
        )
    
    def _color_name(self, rgb: Tuple[int, int, int]) -> str:
        """Convert RGB to color name"""
        min_distance = float('inf')
        closest_color = "unknown"
        
        for color_name, color_values in self.color_mappings.items():
            for cv in color_values:
                distance = sum((a - b) ** 2 for a, b in zip(rgb, cv)) ** 0.5
                if distance < min_distance:
                    min_distance = distance
                    closest_color = color_name
        
        return closest_color
    
    def _transparency_description(self, score: float) -> str:
        """Convert transparency score to description"""
        if score > 0.8:
            return "transparent"
        elif score > 0.5:
            return "translucent"
        elif score > 0.2:
            return "semi-translucent"
        else:
            return "opaque"
    
    def _estimate_crystal_system(self, formations: List[str], terminations: List[str]) -> Optional[str]:
        """Estimate crystal system from visual features"""
        # This is highly simplified - real mineralogy is complex
        
        if "hexagonal" in str(formations) or "six_sided" in str(terminations):
            return "hexagonal"
        elif "cubic" in str(formations):
            return "cubic"
        elif "prismatic" in str(formations):
            return "tetragonal"
        
        return None
    
    def _calculate_confidence(self, matches: List[Dict], features: CrystalFeatures) -> Dict[str, float]:
        """Calculate confidence scores for matches"""
        confidence_scores = {}
        
        for match in matches:
            crystal_name = match['name']
            score = 0.0
            
            # Color match
            if 'color_primary' in match:
                for color in features.dominant_colors:
                    if self._color_name(color) == match['color_primary']:
                        score += 0.3
                        break
            
            # Transparency match
            if 'transparency' in match:
                if match['transparency'] == self._transparency_description(features.transparency_score):
                    score += 0.2
            
            # Luster match
            if 'luster' in match and match['luster'] == features.luster_type:
                score += 0.2
            
            # Formation match
            if 'common_formations' in match:
                for formation in features.detected_formations:
                    if formation in match['common_formations']:
                        score += 0.15
                        break
            
            # Crystal system match
            if 'crystal_system' in match and match['crystal_system'] == features.crystal_system:
                score += 0.15
            
            confidence_scores[crystal_name] = min(score, 1.0)
        
        return confidence_scores