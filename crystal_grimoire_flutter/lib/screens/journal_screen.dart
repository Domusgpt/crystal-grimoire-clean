import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crystal_collection.dart';
import '../models/crystal.dart';
import '../models/crystal_v2.dart' as v2;
import '../services/collection_service.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../widgets/common/mystical_card.dart';
import 'add_crystal_screen.dart';
import 'crystal_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterBy = 'all';
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    await CollectionService.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: MysticalTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCollectionGrid(),
                    _buildFavoritesGrid(),
                    _buildByPurposeView(),
                    _buildStatsView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCrystal,
        backgroundColor: MysticalTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Crystal'),
      ),
    );
  }

  Widget _buildHeader() {
    final stats = CollectionService.getStats();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '✨ Crystal Collection ✨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  _showStats ? Icons.grid_view : Icons.insights,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _showStats = !_showStats),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.totalCrystals} crystals in your grimoire',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search your collection...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorColor: MysticalTheme.accentColor,
        tabs: const [
          Tab(text: 'All Crystals'),
          Tab(text: 'Favorites'),
          Tab(text: 'By Purpose'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildCollectionGrid() {
    final collection = _searchQuery.isEmpty
        ? CollectionService.collection
        : CollectionService.searchCollection(_searchQuery);

    if (collection.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: collection.length,
      itemBuilder: (context, index) {
        return _buildCrystalCard(collection[index]);
      },
    );
  }

  Widget _buildFavoritesGrid() {
    final favorites = CollectionService.getFavorites();
    
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No favorite crystals yet',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any crystal to add it',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return _buildCrystalCard(favorites[index]);
      },
    );
  }

  Widget _buildByPurposeView() {
    final purposes = ['meditation', 'healing', 'protection', 'manifestation', 'grounding'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purposes.length,
      itemBuilder: (context, index) {
        final purpose = purposes[index];
        final crystals = CollectionService.getCrystalsByPurpose(purpose);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: MysticalCard(
            child: ExpansionTile(
            title: Text(
              purpose.substring(0, 1).toUpperCase() + purpose.substring(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              '${crystals.length} crystals',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            children: crystals.map((entry) => ListTile(
              leading: CircleAvatar(
                backgroundColor: MysticalTheme.primaryColor.withOpacity(0.3),
                child: Text(
                  entry.crystal.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                entry.crystal.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Used ${entry.usageCount} times',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.userRating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          entry.userRating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: entry.isFavorite ? Colors.pink : Colors.white54,
                    ),
                    onPressed: () async {
                      await CollectionService.toggleFavorite(entry.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
              onTap: () => _openCrystalDetail(entry),
            )).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsView() {
    final stats = CollectionService.getStats();
    final mostUsed = CollectionService.getMostUsed();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsCard(
          'Collection Overview',
          [
            _buildStatRow('Total Crystals', stats.totalCrystals.toString()),
            _buildStatRow('Favorite Crystals', stats.favoriteCrystals.length.toString()),
            _buildStatRow('Total Uses', CollectionService.usageLogs.length.toString()),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          'Most Used Crystals',
          mostUsed.map((entry) => _buildStatRow(
            entry.crystal.name,
            '${entry.usageCount} uses',
          )).toList(),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          'Chakra Coverage',
          v2.ChakraType.values.map((chakra) {
            final count = stats.crystalsByChakra[chakra.name] ?? 0;
            return _buildStatRow(
              chakra.name,
              count > 0 ? '$count crystals' : 'None yet',
              color: count > 0 ? Colors.green : Colors.orange,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          'Collection Insights',
          [
            if (stats.effectivenessRatings.isNotEmpty)
              ...stats.effectivenessRatings.entries.take(3).map((e) =>
                _buildStatRow(
                  'Best for mood: ${e.key}',
                  '+${e.value.toStringAsFixed(1)} avg',
                  color: Colors.green,
                ),
              ),
            if (stats.totalCrystals < 5)
              _buildStatRow(
                'Tip',
                'Add more crystals to unlock insights',
                color: Colors.blue,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, List<Widget> children) {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrystalCard(CollectionEntry entry) {
    return GestureDetector(
      onTap: () => _openCrystalDetail(entry),
      child: MysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crystal image or placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [
                    MysticalTheme.primaryColor.withOpacity(0.6),
                    MysticalTheme.secondaryColor.withOpacity(0.6),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.diamond,
                  size: 48,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.crystal.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.size} • ${entry.quality}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.usageCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await CollectionService.toggleFavorite(entry.id);
                            setState(() {});
                          },
                          child: Icon(
                            entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: entry.isFavorite ? Colors.pink : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your crystal collection awaits',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first crystal to begin your journey',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewCrystal,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Crystal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewCrystal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCrystalScreen(),
      ),
    ).then((_) => _loadCollection());
  }

  void _openCrystalDetail(CollectionEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrystalDetailScreen(entry: entry),
      ),
    ).then((_) => _loadCollection());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}