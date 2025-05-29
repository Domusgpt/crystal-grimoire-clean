# 🔮 CrystalGrimoire Development Journey - CLAUDE.md

## Project Overview
**CrystalGrimoire** is a mystical Flutter mobile app that combines AI-powered crystal identification with spiritual guidance. The app uses GPT-4O vision capabilities to identify crystals from photos and provides personalized metaphysical guidance through a warm, spiritual advisor persona.

## Current Development Status

### ✅ Completed (Phase 1 - Foundation)
- [x] **Project Structure** - Created Flutter project with mystical architecture
- [x] **Core Configuration** 
  - `pubspec.yaml` - Dependencies and project setup
  - `api_config.dart` - OpenAI configuration and constants
  - `theme.dart` - Mystical purple theme with gradients and effects
- [x] **Data Models**
  - `crystal.dart` - Complete Crystal and CrystalIdentification models
  - Confidence levels, chakra associations, enums
- [x] **Core Services**
  - `openai_service.dart` - GPT-4O integration with spiritual advisor prompt
  - Image processing and API communication
- [x] **Main App Structure**
  - `main.dart` - App entry point with theme and state management

### 🔄 Currently Working On (Phase 2 - Core Features)
- [ ] **Supporting Services** - Cache, usage tracking, app state
- [ ] **UI Screens** - Home, camera, results, collection
- [ ] **Camera Integration** - Multi-angle photo capture
- [ ] **Results Display** - Beautiful mystical results presentation

### 📋 Next Steps (Phase 3 - Enhancement)
- [ ] **Subscription System** - Free/Premium/Pro tiers
- [ ] **Journal Feature** - Crystal collection and experiences
- [ ] **Spiritual Advisor Chat** - Premium conversational guidance
- [ ] **Polish & Testing** - Animations, error handling, optimization

## Architecture Decisions

### 🎨 **Design Philosophy: Mystical Simplicity**
- **Direct GPT-4O Integration** - No complex preprocessing, let AI handle analysis
- **Spiritual Advisor Persona** - Warm grandmother + geology professor voice
- **Purple Mystical Theme** - Deep purples, amethyst, gold accents
- **Progressive Enhancement** - Start simple, add features incrementally

### 🔧 **Technical Stack**
- **Flutter 3.10+** - Cross-platform mobile development
- **GPT-4 Vision Preview** - Crystal identification and spiritual guidance
- **Provider** - State management
- **SharedPreferences** - Local storage
- **SQLite** - Crystal collection storage
- **Image processing** - Camera integration and compression

### 💰 **Monetization Strategy**
```
FREE TIER: 10 IDs/month, 3 images max, basic journal
PREMIUM: $9.99/month - Unlimited IDs, spiritual chat, birth charts
PRO: $19.99/month - Latest AI, 10 images, API access, priority support
FOUNDERS: $499 lifetime - All features forever + future apps
```

## Key Features Implementation

### 🤖 **AI Integration**
The spiritual advisor prompt is the heart of the app:
- Combines scientific mineralogy with metaphysical wisdom
- Warm, encouraging personality ("Ah, beloved seeker...")
- Progressive confidence levels with clear explanations
- Interactive clarification when uncertain
- Structured responses with spiritual guidance

### 📱 **User Experience Flow**
1. **Welcome** - Mystical onboarding with free tier explanation
2. **Camera** - Multi-angle photo capture (1-5 images)
3. **Analysis** - Beautiful loading with mystical messages
4. **Results** - Comprehensive identification with spiritual guidance
5. **Collection** - Save crystals to personal grimoire
6. **Journal** - Track experiences and synchronicities

### 🔮 **Mystical Elements**
- **Sacred Geometry** - Grid patterns and layouts
- **Chakra Integration** - Color-coded associations
- **Lunar Timing** - Moon phase recommendations
- **Personalized Guidance** - Based on user's crystal journey
- **Confidence Visualization** - Progressive certainty display

## File Structure Progress

```
crystal_grimoire_flutter/
├── lib/
│   ├── main.dart                    ✅ Created
│   ├── config/
│   │   ├── api_config.dart         ✅ Created
│   │   └── theme.dart              ✅ Created
│   ├── models/
│   │   └── crystal.dart            ✅ Created
│   ├── services/
│   │   ├── openai_service.dart     ✅ Created
│   │   ├── cache_service.dart      🔄 In Progress
│   │   ├── usage_tracker.dart      🔄 In Progress
│   │   └── app_state.dart          🔄 In Progress
│   ├── screens/
│   │   ├── home_screen.dart        🔄 Next
│   │   ├── camera_screen.dart      🔄 Next
│   │   ├── results_screen.dart     🔄 Next
│   │   └── collection_screen.dart  📋 Planned
│   └── widgets/
│       └── mystical_components.dart 📋 Planned
└── pubspec.yaml                    ✅ Created
```

## Development Guidelines

### 🎭 **Voice & Personality**
- Always maintain mystical, warm tone
- Use crystal/spiritual metaphors
- Encourage and uplift users
- Ground mystical concepts in real properties
- "Beloved seeker" addressing style

### 🔬 **Technical Standards**
- Follow Flutter best practices
- Implement proper error handling
- Use async/await correctly
- Cache responses to minimize API costs
- Responsive design for all screen sizes

### 💎 **Crystal Knowledge Sources**
- "The Crystal Bible" by Judy Hall
- "Love Is in the Earth" by Melody
- "The Book of Stones" by Robert Simmons
- Scientific mineralogy databases
- Traditional metaphysical associations

## API Integration Notes

### 🔑 **OpenAI Configuration**
- Model: `gpt-4-vision-preview`
- Max tokens: 800 (sufficient for detailed responses)
- Temperature: 0.7 (balanced creativity/consistency)
- Image quality: 90% JPEG (good quality, reasonable size)

### 💰 **Cost Management**
- ~$0.01-0.02 per identification
- 30-day response caching
- Free tier: 10 identifications/month
- Image compression before upload
- Error handling to prevent wasted calls

## Testing Strategy

### 🧪 **Testing Phases**
1. **Unit Tests** - Models, services, utilities
2. **Widget Tests** - UI components and screens
3. **Integration Tests** - API calls and data flow
4. **User Testing** - Real crystals with varied lighting

### 📸 **Test Crystal Collection**
- Common crystals: Quartz, Amethyst, Rose Quartz
- Challenging ones: Fluorite varieties, Jaspers
- Different formations: Points, clusters, tumbled
- Various lighting conditions and angles

## Launch Preparation

### 🚀 **Pre-Launch Checklist**
- [ ] Core functionality complete and tested
- [ ] Subscription system implemented
- [ ] App store assets created
- [ ] Privacy policy and terms drafted
- [ ] Analytics integration
- [ ] Crash reporting setup
- [ ] Performance optimization

### 📈 **Success Metrics**
- Monthly active users
- Identification accuracy feedback
- Subscription conversion rates
- User retention (7-day, 30-day)
- Average session duration
- Crystal collection growth

## Notes for Claude Code

### 🎯 **Current Focus**
We're building a mystical crystal identification app with Flutter + GPT-4O. The core architecture is established, and we're now implementing the supporting services and UI screens.

### 🔧 **Key Development Principles**
1. **Simplicity First** - Rely on GPT-4O's excellent vision capabilities
2. **Mystical UX** - Every interaction should feel magical
3. **Progressive Enhancement** - Start with core features, expand gradually
4. **Cost-Effective** - Smart caching and usage limits

### 📋 **Immediate Next Steps**
1. Complete supporting services (cache, usage tracking, app state)
2. Build core UI screens (home, camera, results)
3. Implement camera integration with multi-angle capture
4. Create beautiful results display with spiritual guidance

### 🔮 **Long-term Vision**
Transform this into a comprehensive spiritual companion app with crystal guidance, meditation patterns, astrology integration, and a growing suite of mystical tools.

---

*"In every crystal lies infinite wisdom, waiting to be discovered by those who seek with pure intention."* ✨🔮✨