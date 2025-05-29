import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import 'camera_screen.dart';
import 'collection_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Mystical background gradient
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
          
          // Floating particles background
          const FloatingParticles(
            particleCount: 15,
            color: Colors.purpleAccent,
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App bar with title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Logo and title
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 200),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // App title
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 400),
                            child: ShimmeringText(
                              text: 'Crystal Grimoire',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 600),
                            child: Text(
                              'Your Mystical Crystal Companion',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main action button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 800),
                        child: MysticalButton(
                          onPressed: () => _navigateToIdentify(context),
                          label: 'Identify Crystal',
                          icon: Icons.camera_alt,
                          isPrimary: true,
                          width: double.infinity,
                          height: 64,
                        ),
                      ),
                    ),
                  ),
                  
                  // Usage stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 1000),
                        child: _UsageCard(appState: appState),
                      ),
                    ),
                  ),
                  
                  // Feature cards grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildListDelegate([
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1200),
                          child: FeatureCard(
                            icon: Icons.collections,
                            title: 'Collection',
                            description: 'View your crystal collection',
                            iconColor: Colors.amber,
                            onTap: () => _navigateToCollection(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1300),
                          child: FeatureCard(
                            icon: Icons.auto_stories,
                            title: 'Journal',
                            description: 'Your crystal collection',
                            iconColor: Colors.blue,
                            isPremium: false,  // Free for collection tracking
                            onTap: () => _navigateToJournal(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1400),
                          child: FeatureCard(
                            icon: Icons.grid_on,
                            title: 'Grid Designer',
                            description: 'Create crystal grids',
                            iconColor: Colors.green,
                            isPremium: true,  // Lock behind paywall
                            onTap: () => _navigateToGridDesigner(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1500),
                          child: FeatureCard(
                            icon: Icons.settings,
                            title: 'Settings',
                            description: 'App preferences',
                            iconColor: Colors.grey,
                            onTap: () => _navigateToSettings(context),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating action button
      floatingActionButton: FadeScaleIn(
        delay: const Duration(milliseconds: 1600),
        child: CrystalFAB(
          icon: Icons.add_a_photo,
          onPressed: () => _navigateToIdentify(context),
          tooltip: 'Quick Identify',
        ),
      ),
    );
  }
  
  void _navigateToIdentify(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
  }
  
  void _navigateToCollection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CollectionScreen(),
      ),
    );
  }
  
  void _navigateToJournal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JournalScreen(),
      ),
    );
  }
  
  void _navigateToGridDesigner(BuildContext context) {
    // TODO: Navigate to grid designer screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening grid designer...')),
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}

/// Usage card showing identification limits
class _UsageCard extends StatelessWidget {
  final AppState appState;

  const _UsageCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usageData = appState.currentMonthUsage;
    final isFreeTier = appState.subscriptionTier == 'free';
    final limit = appState.monthlyLimit;
    final remaining = limit - usageData['identifications']!;
    final percentage = limit > 0 ? usageData['identifications']! / limit : 0.0;
    
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFreeTier ? 'Free Tier' : 'Premium',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isFreeTier)
                MysticalButton(
                  onPressed: () {
                    // TODO: Navigate to subscription screen
                  },
                  label: 'Upgrade',
                  height: 32,
                  backgroundColor: theme.colorScheme.secondary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Usage progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Identifications',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    isFreeTier ? '$remaining/$limit remaining' : 'Unlimited',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (isFreeTier) ...[
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Benefits of upgrading
                Text(
                  '✨ Upgrade for unlimited identifications, spiritual chat, and more!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ] else ...[
                // Premium benefits
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BenefitChip(label: '∞ Unlimited IDs'),
                    _BenefitChip(label: '💬 Spiritual Chat'),
                    _BenefitChip(label: '🔮 Priority Support'),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Small benefit chip
class _BenefitChip extends StatelessWidget {
  final String label;

  const _BenefitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.secondary.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}