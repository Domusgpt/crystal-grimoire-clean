# 🔮 CrystalGrimoire - Development Roadmap

**Current Status**: Camera Fixed, Backend Integrated, Core Features Pending  
**Current Build**: http://localhost:8671 (May 28, 19:20)  
**AI Accuracy**: 33% (1/3 crystals) - Needs improvement  

---

## 🎯 IMMEDIATE PRIORITIES (Next Session)

### 1. Crystal Journal Implementation 🔥
**Why Priority**: Core feature for user engagement and retention
**Current**: Missing entirely
**Target**: Full journal system with experience logging

**Implementation Plan**:
```dart
// Create lib/screens/journal_screen.dart
class JournalScreen extends StatefulWidget {
  // Features needed:
  // - Add journal entries for crystal experiences
  // - Search and filter entries by crystal type
  // - Tag entries with moods/energy levels
  // - Export journal data
  // - Link entries to specific crystal identifications
}

// Create lib/models/journal_entry.dart
class JournalEntry {
  final String id;
  final String userId;
  final String crystalId;
  final String title;
  final String content;
  final String mood;
  final int energyLevel; // 1-10 scale
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Backend endpoints needed:
// POST /api/v1/journal/entries
// GET /api/v1/journal/entries/{user_id}
// PUT /api/v1/journal/entries/{entry_id}
// DELETE /api/v1/journal/entries/{entry_id}
```

### 2. Settings Screen 🔥
**Why Priority**: User control and AI provider management
**Current**: Non-existent
**Target**: Full settings with AI provider selection

**Features Needed**:
```dart
// Create lib/screens/settings_screen.dart
class SettingsScreen extends StatefulWidget {
  // Sections:
  // 1. AI Provider Selection (Gemini, OpenAI, Claude)
  // 2. Subscription Management
  // 3. Usage Statistics Display
  // 4. Account Settings (email, password)
  // 5. Notification Preferences
  // 6. Data Export/Import
  // 7. About/Version Info
}

// Settings categories:
// - AI Model Settings
// - Account Settings  
// - Privacy Settings
// - Subscription Settings
// - Export/Import Data
```

### 3. Login Persistence Fix 🔥
**Why Priority**: User experience continuity
**Current**: Login state lost on refresh
**Target**: Persistent authentication

**Fix Required**:
```dart
// Update lib/services/auth_service.dart
class AuthService {
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setInt('token_expiry', expiryTimestamp);
  }
  
  static Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final expiry = prefs.getInt('token_expiry');
    
    if (token != null && expiry != null) {
      if (DateTime.now().millisecondsSinceEpoch < expiry) {
        BackendService.setAuth(token, prefs.getString('user_id')!);
        return true;
      }
    }
    return false;
  }
}
```

---

## 🤖 AI ACCURACY IMPROVEMENT PLAN

### Current Performance Analysis
- **Success Rate**: 1/3 crystals (33%)
- **Model**: Gemini 1.5 Flash
- **Issues**: Generic prompts, no image preprocessing, single-shot analysis

### Enhancement Strategy

#### 1. Advanced Prompt Engineering
```dart
static const String _expertMineralogistPrompt = '''
You are Dr. Crystal, a world-renowned mineralogist and crystallographer with 30 years of experience. You have identified over 10,000 crystal specimens and have access to comprehensive databases.

SYSTEMATIC IDENTIFICATION PROTOCOL:

STEP 1 - PHYSICAL ANALYSIS:
- Crystal System: Determine if cubic, hexagonal, tetragonal, orthorhombic, monoclinic, or triclinic
- Habit: Prismatic, tabular, massive, druzy, geode, cluster, or single termination
- Color: Primary and secondary colors, color zoning, pleochroism
- Transparency: Transparent, translucent, or opaque
- Luster: Vitreous, metallic, pearly, silky, resinous, or dull
- Hardness Assessment: Visual clues for Mohs scale estimation

STEP 2 - FORMATION ANALYSIS:
- Termination Style: Natural points, cleaved faces, or broken surfaces
- Internal Features: Inclusions, phantoms, growth patterns, zoning
- Surface Features: Striations, etch marks, dissolution patterns
- Associated Minerals: Any visible matrix or associated crystals

STEP 3 - SIZE & SCALE ANALYSIS:
- If ruler/coin present: Exact measurements
- If no scale: Estimate size category (thumbnail, cabinet, museum specimen)
- Assess specimen quality: A grade (museum), B grade (collector), C grade (metaphysical)

STEP 4 - CONFIDENCE ASSESSMENT:
- 90-100% CERTAIN: Multiple confirming diagnostic features present
- 70-89% PROBABLE: Most features match, minor uncertainty remains  
- 50-69% POSSIBLE: Some features match, request additional angles
- <50% INSUFFICIENT: Provide top 3 most likely candidates

RESPONSE FORMAT:
1. PRIMARY IDENTIFICATION: [Crystal name] (Confidence: XX%)
2. DIAGNOSTIC FEATURES: [List 3-5 key identifying characteristics observed]
3. ALTERNATIVE POSSIBILITIES: [If confidence <90%, list 2-3 alternatives]
4. ADDITIONAL ANGLES NEEDED: [If confidence <70%, specify what angles would help]
5. SPECIMEN QUALITY: [A/B/C grade with reasoning]
6. METAPHYSICAL PROPERTIES: [Provide spiritual guidance based on confirmed ID]

Remember: Accuracy is paramount. It's better to request more information than to provide an incorrect identification.
''';
```

#### 2. Image Preprocessing Pipeline
```dart
// lib/services/image_enhancer.dart
class ImageEnhancer {
  static Future<List<Uint8List>> enhanceForAnalysis(List<PlatformFile> images) async {
    List<Uint8List> enhanced = [];
    
    for (var image in images) {
      var processed = image.bytes;
      
      // 1. Normalize lighting
      processed = await normalizeLighting(processed);
      
      // 2. Enhance contrast
      processed = await enhanceContrast(processed, factor: 1.2);
      
      // 3. Sharpen details
      processed = await applySharpeningFilter(processed);
      
      // 4. Color balance
      processed = await balanceColors(processed);
      
      enhanced.add(processed);
    }
    
    return enhanced;
  }
  
  static Future<bool> validateImageQuality(Uint8List imageBytes) async {
    // Check for blur, lighting, focus
    var quality = await analyzeImageQuality(imageBytes);
    return quality.sharpness > 0.7 && quality.lighting > 0.6;
  }
}
```

#### 3. Multi-Angle Analysis System
```dart
// lib/services/advanced_ai_service.dart
class AdvancedAIService {
  static Future<CrystalIdentification> identifyWithMultiAngle({
    required List<PlatformFile> images,
    String? userContext,
  }) async {
    
    // Validate we have multiple angles
    if (images.length < 2) {
      throw Exception('Please provide at least 2 different angles for accurate identification');
    }
    
    // Enhance images
    var enhancedImages = await ImageEnhancer.enhanceForAnalysis(images);
    
    // Analyze each angle separately
    List<PartialIdentification> angleResults = [];
    
    for (int i = 0; i < enhancedImages.length; i++) {
      var result = await _analyzeIndividualAngle(
        enhancedImages[i], 
        'Angle ${i + 1}: ${_getAngleDescription(i)}'
      );
      angleResults.add(result);
    }
    
    // Build consensus result
    return _buildConsensusIdentification(angleResults, images);
  }
  
  static String _getAngleDescription(int index) {
    switch (index) {
      case 0: return 'Front view showing main face and overall form';
      case 1: return 'Side profile showing thickness and termination';
      case 2: return 'Close-up of surface features and inclusions';
      case 3: return 'Scale reference or size comparison';
      default: return 'Additional angle for verification';
    }
  }
}
```

#### 4. Consensus Building Algorithm
```dart
class ConsensusBuilder {
  static CrystalIdentification buildConsensus(List<PartialIdentification> results) {
    // Weight results by confidence
    Map<String, double> crystalVotes = {};
    
    for (var result in results) {
      crystalVotes[result.crystalName] = 
        (crystalVotes[result.crystalName] ?? 0) + result.confidence;
    }
    
    // Find highest consensus
    var winner = crystalVotes.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    // Calculate final confidence
    double finalConfidence = winner.value / results.length;
    
    // If confidence too low, request more angles
    if (finalConfidence < 0.6) {
      return CrystalIdentification.needMoreInfo(
        topCandidates: crystalVotes.keys.take(3).toList(),
        suggestedAngles: ['Termination close-up', 'Natural lighting', 'Size reference']
      );
    }
    
    return CrystalIdentification(
      crystalName: winner.key,
      confidence: finalConfidence,
      // ... other properties
    );
  }
}
```

---

## 💰 PAYMENT SYSTEM IMPLEMENTATION

### Required Components

#### 1. Stripe Integration
```dart
// lib/services/payment_service.dart
class PaymentService {
  static const String _stripePublishableKey = 'pk_test_...';
  
  static Future<void> initializeStripe() async {
    Stripe.publishableKey = _stripePublishableKey;
    await Stripe.instance.applySettings();
  }
  
  static Future<PaymentResult> createSubscription({
    required String priceId, // Stripe price ID
    required String email,
  }) async {
    
    // Create payment intent
    var paymentIntent = await _createPaymentIntent(priceId, email);
    
    // Present payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent.clientSecret,
        customerEphemeralKeySecret: paymentIntent.ephemeralKey,
        customerId: paymentIntent.customerId,
        merchantDisplayName: 'CrystalGrimoire',
      ),
    );
    
    return await Stripe.instance.presentPaymentSheet();
  }
}
```

#### 2. Subscription Tiers
```dart
enum SubscriptionTier {
  free(
    name: 'Spiritual Seeker',
    monthlyIdentifications: 4,
    price: 0,
    features: ['Basic AI identification', 'Simple crystal info'],
  ),
  
  premium(
    name: 'Crystal Enthusiast', 
    monthlyIdentifications: 50,
    price: 9.99,
    features: ['Enhanced AI accuracy', 'Crystal journal', 'Collection tracking'],
  ),
  
  pro(
    name: 'Master Crystallographer',
    monthlyIdentifications: -1, // unlimited
    price: 19.99,
    features: ['Unlimited identifications', 'Expert consultation', 'Custom grids'],
  );
}
```

#### 3. Usage Enforcement
```dart
// lib/services/subscription_manager.dart
class SubscriptionManager {
  static Future<bool> canPerformIdentification(String userId) async {
    var user = await BackendService.getUserSubscription(userId);
    
    if (user.tier == SubscriptionTier.pro) return true;
    
    var currentUsage = await BackendService.getMonthlyUsage(userId);
    return currentUsage < user.tier.monthlyIdentifications;
  }
  
  static Future<void> showUpgradePrompt(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        currentTier: await getCurrentTier(),
        onUpgrade: (tier) => PaymentService.createSubscription(
          priceId: tier.stripePriceId,
          email: await getCurrentUserEmail(),
        ),
      ),
    );
  }
}
```

---

## 📱 UI/UX IMPROVEMENTS

### Enhanced Camera Interface
```dart
// lib/widgets/advanced_camera_widget.dart
class AdvancedCameraWidget extends StatefulWidget {
  // Features to add:
  // - Angle guidance overlay
  // - Image quality indicator
  // - Lighting assessment
  // - Focus confirmation
  // - Size reference reminder
}
```

### Results Enhancement
```dart
// lib/widgets/enhanced_results_widget.dart
class EnhancedResultsWidget extends StatefulWidget {
  // Features to add:
  // - Confidence visualization
  // - Alternative possibilities
  // - "Need more angles" prompts
  // - Quality assessment display
  // - Save to collection CTA
}
```

---

## 🚀 DEPLOYMENT PREPARATION

### Environment Configuration
```dart
// lib/config/environment.dart
class Environment {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const String apiBaseUrl = isProduction 
    ? 'https://api.crystalgrimoire.com'
    : 'http://localhost:8000';
    
  static const String stripePublishableKey = isProduction
    ? 'pk_live_...'
    : 'pk_test_...';
}
```

### Production Checklist
- [ ] Environment variables configured
- [ ] Stripe webhook endpoints set up
- [ ] Database migration scripts ready
- [ ] SSL certificates configured
- [ ] Error tracking (Sentry) integrated
- [ ] Analytics (Firebase/Mixpanel) integrated
- [ ] Performance monitoring enabled

---

**Next Steps**: Focus on Journal implementation first, then Settings screen, then login persistence. The camera is working and backend is solid - now we build the user experience features that make this a complete crystal identification platform.