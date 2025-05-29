import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/crystal_collection.dart';
import '../models/birth_chart.dart';
import '../services/collection_service.dart';
import '../services/astrology_service.dart';
import '../services/backend_service.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';

class MetaphysicalGuidanceScreen extends StatefulWidget {
  const MetaphysicalGuidanceScreen({Key? key}) : super(key: key);

  @override
  State<MetaphysicalGuidanceScreen> createState() => _MetaphysicalGuidanceScreenState();
}

class _MetaphysicalGuidanceScreenState extends State<MetaphysicalGuidanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _parallaxController;
  late AnimationController _floatingController;
  
  String _selectedGuidanceType = 'daily';
  bool _isLoading = false;
  String? _currentGuidance;
  Map<String, dynamic>? _userProfile;

  final List<String> _guidanceTypes = [
    'daily',
    'crystal_selection',
    'chakra_balancing',
    'lunar_guidance',
    'manifestation',
    'healing_session',
    'spiritual_reading'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _parallaxController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    await CollectionService.initialize();
    
    // Build user profile from journal/collection data and birth chart
    final collection = CollectionService.collection;
    final stats = CollectionStats.fromCollection(collection, []);
    
    setState(() {
      _userProfile = {
        'collection_stats': stats.toAIContext(),
        'favorite_crystals': collection.where((e) => e.isFavorite).map((e) => e.crystal.name).toList(),
        'recent_crystals': collection.take(5).map((e) => {
          'name': e.crystal.name,
          'date_added': e.dateAdded.toIso8601String(),
          'chakras': e.crystal.chakras,
          'metaphysical_properties': e.crystal.metaphysicalProperties,
        }).toList(),
        'spiritual_preferences': {
          'meditation_crystals': collection.where((e) => e.primaryUses.contains('meditation')).length,
          'healing_crystals': collection.where((e) => e.primaryUses.contains('healing')).length,
          'protection_crystals': collection.where((e) => e.primaryUses.contains('protection')).length,
        }
      };
    });
  }

  Future<void> _getPersonalizedGuidance() async {
    if (_isLoading || _userProfile == null) return;
    
    setState(() {
      _isLoading = true;
      _currentGuidance = null;
    });

    try {
      // Create a personalized prompt based on user's data
      final prompt = _buildPersonalizedPrompt(_selectedGuidanceType);
      
      // Use the backend's LLM integration for personalized guidance
      final response = await BackendService.getPersonalizedGuidance(
        guidanceType: _selectedGuidanceType,
        userProfile: _userProfile!,
        customPrompt: prompt,
      );

      setState(() {
        _currentGuidance = response['guidance'] ?? 'Unable to provide guidance at this time.';
      });
    } catch (e) {
      setState(() {
        _currentGuidance = 'I apologize, beloved seeker. The cosmic energies are currently disrupted. Please try again in a moment.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildPersonalizedPrompt(String guidanceType) {
    final userStats = _userProfile!['collection_stats'] as Map<String, dynamic>;
    final favoriteCrystals = _userProfile!['favorite_crystals'] as List<dynamic>;
    final recentCrystals = _userProfile!['recent_crystals'] as List<dynamic>;
    
    String basePrompt = """You are the CrystalGrimoire Spiritual Advisor, providing deeply personalized metaphysical guidance. 

USER'S SPIRITUAL PROFILE:
- Crystal Collection: ${userStats['totalCrystals']} crystals
- Favorite Crystals: ${favoriteCrystals.join(', ')}
- Recent Additions: ${recentCrystals.map((c) => c['name']).join(', ')}
- Chakra Coverage: ${userStats['chakraCoverage']}
- Primary Purposes: ${userStats['primaryPurposes']}
- Collection Gaps: ${userStats['gaps']}

GUIDANCE REQUEST: """;

    switch (guidanceType) {
      case 'daily':
        return basePrompt + """Daily Spiritual Guidance
Provide personalized daily guidance incorporating their crystal collection and spiritual journey. Include:
- A crystal recommendation from their collection for today
- Specific meditation or intention-setting practice
- Astrological insights if relevant
- Personal affirmation based on their crystals""";
        
      case 'crystal_selection':
        return basePrompt + """Crystal Selection Guidance  
Based on their current collection and gaps, recommend:
- Which crystal from their collection to work with for a specific intention
- Crystals they should consider adding to balance their collection
- How to combine their existing crystals for maximum effect""";
        
      case 'chakra_balancing':
        return basePrompt + """Chakra Balancing Session
Create a personalized chakra balancing routine using their existing crystals:
- Identify which chakras need attention based on their collection
- Map their crystals to chakra healing
- Provide step-by-step balancing instructions""";
        
      case 'lunar_guidance':
        return basePrompt + """Lunar Cycle Guidance
Provide moon phase-specific guidance incorporating their crystals:
- How to work with their crystals during current moon phase
- Charging and cleansing rituals for their collection
- Manifestation practices aligned with lunar energy""";
        
      case 'manifestation':
        return basePrompt + """Manifestation Guidance
Create a personalized manifestation practice:
- Select crystals from their collection for manifestation work
- Design a crystal grid using their stones
- Provide specific affirmations and visualization techniques""";
        
      case 'healing_session':
        return basePrompt + """Healing Session Design
Design a healing session using their crystals:
- Identify healing crystals in their collection
- Create layouts for physical, emotional, or spiritual healing
- Provide step-by-step healing instructions""";
        
      case 'spiritual_reading':
        return basePrompt + """Spiritual Reading & Insights
Provide intuitive insights about their spiritual journey:
- Read the energy of their crystal collection
- Identify spiritual patterns and growth areas
- Offer guidance for their next steps on the path""";
        
      default:
        return basePrompt + "General spiritual guidance incorporating their unique crystal collection and spiritual journey.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.indigo.withOpacity(0.2),
              Colors.deepPurple.withOpacity(0.1),
              const Color(0xFF0F0F23),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildParallaxBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGuidanceView(),
                        _buildToolsView(),
                        _buildInsightsView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔮 Metaphysical Guidance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Personalized spiritual wisdom & tools',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.indigo],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Guidance'),
          Tab(text: 'Tools'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildGuidanceView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_fix_high, color: Colors.purple[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Personalized Guidance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select the type of guidance you seek:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildGuidanceTypeSelector(),
              const SizedBox(height: 16),
              _isLoading
                ? Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.purple.withOpacity(0.3),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : MysticalButton(
                    onPressed: _getPersonalizedGuidance,
                    label: 'Receive Guidance',
                    isPrimary: true,
                  ),
            ],
          ),
        ),
        if (_currentGuidance != null) ...[
          const SizedBox(height: 16),
          MysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.amber[300]),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Personal Guidance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentGuidance!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuidanceTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _guidanceTypes.map((type) {
        final isSelected = type == _selectedGuidanceType;
        return GestureDetector(
          onTap: () => setState(() => _selectedGuidanceType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected 
                ? LinearGradient(colors: [Colors.purple, Colors.indigo])
                : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
              ),
            ),
            child: Text(
              _getGuidanceTypeLabel(type),
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getGuidanceTypeLabel(String type) {
    switch (type) {
      case 'daily': return 'Daily Guidance';
      case 'crystal_selection': return 'Crystal Selection';
      case 'chakra_balancing': return 'Chakra Balancing';
      case 'lunar_guidance': return 'Lunar Guidance';
      case 'manifestation': return 'Manifestation';
      case 'healing_session': return 'Healing Session';
      case 'spiritual_reading': return 'Spiritual Reading';
      default: return type;
    }
  }

  Widget _buildToolsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            children: [
              Icon(Icons.construction, color: Colors.orange[300], size: 48),
              const SizedBox(height: 16),
              const Text(
                'Spiritual Tools & Calculators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Advanced tools for crystal grids, lunar calculations, and chakra analysis coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_userProfile != null) _buildProfileInsights(),
      ],
    );
  }

  Widget _buildProfileInsights() {
    final stats = _userProfile!['collection_stats'] as Map<String, dynamic>;
    
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.blue[300]),
              const SizedBox(width: 8),
              const Text(
                'Your Spiritual Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow('Total Crystals', '${stats['totalCrystals']}'),
          _buildInsightRow('Chakra Coverage', '${(stats['chakraCoverage'] as Map).length} chakras'),
          _buildInsightRow('Collection Gaps', '${(stats['gaps'] as List).length} areas'),
          const SizedBox(height: 16),
          if ((stats['gaps'] as List).isNotEmpty) ...[
            const Text(
              'Recommended Additions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...(stats['gaps'] as List).map((gap) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $gap',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_parallaxController.value * 2 * math.pi) * 0.3,
                math.cos(_parallaxController.value * 2 * math.pi) * 0.3,
              ),
              radius: 1.5,
              colors: [
                Colors.purple.withOpacity(0.2),
                Colors.indigo.withOpacity(0.1),
                Colors.deepPurple.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}