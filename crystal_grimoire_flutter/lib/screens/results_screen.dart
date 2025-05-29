import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/crystal.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';

class ResultsScreen extends StatefulWidget {
  final CrystalIdentification identification;
  final List<File> images;

  const ResultsScreen({
    Key? key,
    required this.identification,
    required this.images,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _expandController;
  late AnimationController _chakraController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _expandAnimation;
  
  int _selectedImageIndex = 0;
  bool _showFullDescription = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _chakraController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeController.forward();
    _expandController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _expandController.dispose();
    _chakraController.dispose();
    super.dispose();
  }
  
  void _saveToCollection() {
    setState(() => _isSaved = true);
    HapticFeedback.mediumImpact();
    
    // TODO: Actually save to collection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Crystal saved to your collection!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crystal = widget.identification.crystal;
    
    if (crystal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Crystal Results')),
        body: const Center(
          child: Text('No crystal data available'),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Mystical background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.background.withBlue(30),
                ],
              ),
            ),
          ),
          
          // Floating particles
          const FloatingParticles(
            particleCount: 20,
            color: Colors.purpleAccent,
          ),
          
          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App bar with back button
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  leading: MysticalIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    MysticalIconButton(
                      icon: Icons.share,
                      onPressed: () {
                        // TODO: Share functionality
                      },
                    ),
                  ],
                ),
                
                // Main content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Crystal images carousel
                          _buildImageCarousel(),
                          const SizedBox(height: 24),
                          
                          // Crystal name and confidence
                          _buildCrystalHeader(crystal),
                          const SizedBox(height: 24),
                          
                          // Metaphysical properties
                          _buildMetaphysicalSection(crystal),
                          const SizedBox(height: 24),
                          
                          // Chakra associations
                          _buildChakraSection(crystal),
                          const SizedBox(height: 24),
                          
                          // Healing properties
                          _buildHealingSection(crystal),
                          const SizedBox(height: 24),
                          
                          // Mystical message
                          _buildMysticalMessage(),
                          const SizedBox(height: 24),
                          
                          // Care instructions
                          _buildCareSection(crystal),
                          const SizedBox(height: 32),
                          
                          // Action buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageCarousel() {
    return Column(
      children: [
        // Main image display
        FadeScaleIn(
          child: MysticalCard(
            padding: EdgeInsets.zero,
            borderRadius: 24,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: widget.images.isNotEmpty
                    ? Image.file(
                        widget.images[_selectedImageIndex],
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.diamond,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
              ),
            ),
          ),
        ),
        
        // Image thumbnails
        if (widget.images.length > 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return FadeScaleIn(
                  delay: Duration(milliseconds: 100 * index),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedImageIndex = index);
                        HapticFeedback.selectionClick();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedImageIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            widget.images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildCrystalHeader(Crystal crystal) {
    final theme = Theme.of(context);
    final confidence = widget.identification.confidence;
    
    return FadeScaleIn(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crystal name with shimmer effect
          ShimmeringText(
            text: crystal.name,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 8),
          
          // Scientific name and group
          Text(
            '${crystal.scientificName} • ${crystal.group}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          
          // Confidence indicator
          Row(
            children: [
              Icon(
                confidence > 0.8 ? Icons.verified : Icons.info_outline,
                color: confidence > 0.8 ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getConfidenceText(confidence),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: confidence > 0.8 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetaphysicalSection(Crystal crystal) {
    final theme = Theme.of(context);
    
    return FadeScaleIn(
      delay: const Duration(milliseconds: 400),
      child: MysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PulsingGlow(
                  glowColor: theme.colorScheme.secondary,
                  minGlowRadius: 3,
                  maxGlowRadius: 8,
                  child: Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Metaphysical Properties',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Element associations
            _buildPropertyRow('Elements', crystal.elements.join(', ')),
            const SizedBox(height: 8),
            
            // Energy type
            _buildPropertyRow('Energy', crystal.properties['energy'] ?? 'Balanced'),
            const SizedBox(height: 8),
            
            // Vibration
            _buildPropertyRow('Vibration', crystal.properties['vibration'] ?? 'High'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChakraSection(Crystal crystal) {
    return FadeScaleIn(
      delay: const Duration(milliseconds: 600),
      child: MysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _chakraController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _chakraController.value * 2 * 3.14159,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.brightness_7,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Chakra Associations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Chakra list with colors
            ...crystal.chakras.map((chakra) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _ChakraIndicator(chakra: chakra),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHealingSection(Crystal crystal) {
    final theme = Theme.of(context);
    final healingProperties = crystal.properties['healing'] as List<String>? ?? [];
    
    return FadeScaleIn(
      delay: const Duration(milliseconds: 800),
      child: MysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.pink,
                ),
                const SizedBox(width: 12),
                Text(
                  'Healing Properties',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Animated healing properties list
            ...healingProperties.asMap().entries.map((entry) {
              final index = entry.key;
              final property = entry.value;
              
              return FadeScaleIn(
                delay: Duration(milliseconds: 900 + (index * 100)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          property,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMysticalMessage() {
    final theme = Theme.of(context);
    final message = widget.identification.mysticalMessage;
    
    return FadeScaleIn(
      delay: const Duration(milliseconds: 1000),
      child: PulsingGlow(
        glowColor: theme.colorScheme.primary,
        child: MysticalCard(
          gradientColors: [
            theme.colorScheme.primary.withOpacity(0.6),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
          child: Column(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCareSection(Crystal crystal) {
    final theme = Theme.of(context);
    
    return FadeScaleIn(
      delay: const Duration(milliseconds: 1200),
      child: MysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.spa,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Care & Cleansing',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              crystal.careInstructions,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return FadeScaleIn(
      delay: const Duration(milliseconds: 1400),
      child: Column(
        children: [
          MysticalButton(
            onPressed: _isSaved ? () {} : _saveToCollection,
            label: _isSaved ? 'Saved to Collection ✓' : 'Save to Collection',
            icon: _isSaved ? Icons.check : Icons.bookmark_add,
            isPrimary: true,
            width: double.infinity,
            backgroundColor: _isSaved ? Colors.green : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MysticalButton(
                  onPressed: () {
                    // TODO: Navigate to journal
                  },
                  label: 'Journal',
                  icon: Icons.edit_note,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MysticalButton(
                  onPressed: () {
                    // TODO: Share
                  },
                  label: 'Share',
                  icon: Icons.share,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  String _getConfidenceText(double confidence) {
    if (confidence > 0.9) return 'Very high confidence';
    if (confidence > 0.8) return 'High confidence';
    if (confidence > 0.7) return 'Good confidence';
    if (confidence > 0.6) return 'Moderate confidence';
    return 'Low confidence - Consider retaking photos';
  }
}

/// Chakra indicator widget
class _ChakraIndicator extends StatelessWidget {
  final String chakra;
  
  const _ChakraIndicator({required this.chakra});
  
  static const Map<String, Color> chakraColors = {
    'Root': Colors.red,
    'Sacral': Colors.orange,
    'Solar Plexus': Colors.yellow,
    'Heart': Colors.green,
    'Throat': Colors.blue,
    'Third Eye': Color(0xFF4B0082),
    'Crown': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = chakraColors[chakra] ?? theme.colorScheme.primary;
    
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          chakra,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}