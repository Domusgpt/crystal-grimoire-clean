import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crystal_collection.dart';
import '../models/crystal.dart';
import '../models/crystal_v2.dart' as v2;
import '../services/collection_service.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';

class CrystalDetailScreen extends StatefulWidget {
  final CollectionEntry entry;

  const CrystalDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<CrystalDetailScreen> createState() => _CrystalDetailScreenState();
}

class _CrystalDetailScreenState extends State<CrystalDetailScreen> {
  late CollectionEntry _entry;
  List<UsageLog> _usageLogs = [];
  bool _showUsageForm = false;

  // Usage form controllers
  final _intentionController = TextEditingController();
  final _resultController = TextEditingController();
  String _selectedPurpose = 'meditation';
  int _moodBefore = 5;
  int _moodAfter = 5;
  int _energyBefore = 5;
  int _energyAfter = 5;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _loadUsageLogs();
  }

  void _loadUsageLogs() {
    setState(() {
      _usageLogs = CollectionService.getUsageLogsForCrystal(_entry.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: MysticalTheme.backgroundGradient,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with crystal info
              _buildHeader(),
              
              // Main content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Crystal properties
                    _buildPropertiesCard(),
                    const SizedBox(height: 16),
                    
                    // Collection details
                    _buildCollectionDetailsCard(),
                    const SizedBox(height: 16),
                    
                    // Usage statistics
                    _buildUsageStatsCard(),
                    const SizedBox(height: 16),
                    
                    // Record usage button or form
                    if (!_showUsageForm)
                      MysticalButton(
                        onPressed: () => setState(() => _showUsageForm = true),
                        label: 'Record Usage',
                        icon: Icons.add,
                        width: double.infinity,
                        height: 56,
                      )
                    else
                      _buildUsageForm(),
                    
                    const SizedBox(height: 16),
                    
                    // Usage history
                    if (_usageLogs.isNotEmpty) ...[
                      _buildUsageHistory(),
                      const SizedBox(height: 16),
                    ],
                    
                    // Personal notes
                    if (_entry.notes != null && _entry.notes!.isNotEmpty) ...[
                      _buildNotesCard(),
                      const SizedBox(height: 16),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFavorite,
        backgroundColor: MysticalTheme.primaryColor,
        child: Icon(
          _entry.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _entry.crystal.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MysticalTheme.primaryColor.withOpacity(0.8),
                MysticalTheme.secondaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.diamond,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < _entry.userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesCard() {
    final crystal = _entry.crystal;
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ Crystal Properties',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildPropertyRow('Group', crystal.group),
            _buildPropertyRow('Scientific Name', crystal.scientificName),
            _buildPropertyRow('Hardness', crystal.hardness),
            _buildPropertyRow('Color', crystal.colorDescription),
            _buildPropertyRow('Formation', crystal.formation),
            
            const SizedBox(height: 12),
            
            // Chakras
            if (crystal.chakras.isNotEmpty) ...[
              const Text(
                'Chakras',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: crystal.chakras.map((chakra) {
                  return Chip(
                    label: Text(
                      chakra,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getChakraColorByName(chakra).withOpacity(0.3),
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Metaphysical properties
            if (crystal.metaphysicalProperties.isNotEmpty) ...[
              const Text(
                'Metaphysical Properties',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: crystal.metaphysicalProperties.map((prop) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withOpacity(0.4)),
                    ),
                    child: Text(
                      prop,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionDetailsCard() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📦 Collection Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildPropertyRow('Added', _formatDate(_entry.dateAdded)),
            _buildPropertyRow('Source', _entry.source),
            if (_entry.location != null)
              _buildPropertyRow('Location', _entry.location!),
            if (_entry.price != null)
              _buildPropertyRow('Price', '\$${_entry.price!.toStringAsFixed(2)}'),
            _buildPropertyRow('Size', _entry.size),
            _buildPropertyRow('Quality', _entry.quality),
            
            if (_entry.primaryUses.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Primary Uses',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _entry.primaryUses.map((use) {
                  return Chip(
                    label: Text(use, style: const TextStyle(fontSize: 12)),
                    backgroundColor: MysticalTheme.accentColor.withOpacity(0.3),
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatsCard() {
    final stats = _calculateUsageStats();
    
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Usage Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_entry.usageCount} uses',
                  style: const TextStyle(
                    color: MysticalTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (stats['avgMoodImprovement'] != null)
              _buildStatBar(
                'Avg Mood Improvement',
                stats['avgMoodImprovement']!,
                10,
                Colors.pink,
              ),
            
            if (stats['avgEnergyImprovement'] != null)
              _buildStatBar(
                'Avg Energy Improvement',
                stats['avgEnergyImprovement']!,
                10,
                Colors.orange,
              ),
            
            if (stats['mostUsedPurpose'] != null) ...[
              const SizedBox(height: 12),
              _buildPropertyRow('Most Used For', stats['mostUsedPurpose']!),
            ],
            
            if (stats['lastUsed'] != null) ...[
              _buildPropertyRow('Last Used', _formatDate(stats['lastUsed']!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageForm() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '✨ Record Usage',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => setState(() => _showUsageForm = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Purpose selection
            DropdownButtonFormField<String>(
              value: _selectedPurpose,
              dropdownColor: MysticalTheme.cardColor,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Purpose'),
              items: ['meditation', 'healing', 'protection', 'manifestation', 'other']
                  .map((purpose) => DropdownMenuItem(
                        value: purpose,
                        child: Text(purpose.substring(0, 1).toUpperCase() + purpose.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedPurpose = value!),
            ),
            
            const SizedBox(height: 16),
            
            // Intention
            TextField(
              controller: _intentionController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Intention (optional)'),
            ),
            
            const SizedBox(height: 16),
            
            // Mood before/after
            _buildSliderSection(
              'Mood',
              _moodBefore,
              _moodAfter,
              (before) => setState(() => _moodBefore = before.round()),
              (after) => setState(() => _moodAfter = after.round()),
              Colors.pink,
            ),
            
            const SizedBox(height: 16),
            
            // Energy before/after
            _buildSliderSection(
              'Energy',
              _energyBefore,
              _energyAfter,
              (before) => setState(() => _energyBefore = before.round()),
              (after) => setState(() => _energyAfter = after.round()),
              Colors.orange,
            ),
            
            const SizedBox(height: 16),
            
            // Result notes
            TextField(
              controller: _resultController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _buildInputDecoration('Results/Notes (optional)'),
            ),
            
            const SizedBox(height: 20),
            
            // Save button
            MysticalButton(
              onPressed: _saveUsage,
              label: 'Save Usage',
              icon: Icons.save,
              isPrimary: true,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSection(
    String label,
    int before,
    int after,
    Function(double) onBeforeChanged,
    Function(double) onAfterChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        
        // Before slider
        Row(
          children: [
            const SizedBox(
              width: 60,
              child: Text('Before:', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            Expanded(
              child: Slider(
                value: before.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: color.withOpacity(0.6),
                inactiveColor: Colors.white.withOpacity(0.1),
                onChanged: onBeforeChanged,
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                before.toString(),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        
        // After slider
        Row(
          children: [
            const SizedBox(
              width: 60,
              child: Text('After:', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            Expanded(
              child: Slider(
                value: after.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: color,
                inactiveColor: Colors.white.withOpacity(0.1),
                onChanged: onAfterChanged,
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                after.toString(),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageHistory() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📜 Usage History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._usageLogs.take(5).map((log) => _buildUsageLogItem(log)),
            
            if (_usageLogs.length > 5) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _showAllUsageLogs,
                  child: Text('View all ${_usageLogs.length} entries'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageLogItem(UsageLog log) {
    final moodChange = log.moodAfter != null && log.moodBefore != null
        ? log.moodAfter! - log.moodBefore!
        : null;
    final energyChange = log.energyAfter != null && log.energyBefore != null
        ? log.energyAfter! - log.energyBefore!
        : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log.purpose.substring(0, 1).toUpperCase() + log.purpose.substring(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(log.dateTime),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
          
          if (log.intention != null) ...[
            const SizedBox(height: 4),
            Text(
              'Intention: ${log.intention}',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
          
          if (moodChange != null || energyChange != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (moodChange != null) ...[
                  _buildChangeIndicator('Mood', moodChange, Colors.pink),
                  const SizedBox(width: 16),
                ],
                if (energyChange != null) ...[
                  _buildChangeIndicator('Energy', energyChange, Colors.orange),
                ],
              ],
            ),
          ],
          
          if (log.result != null) ...[
            const SizedBox(height: 8),
            Text(
              log.result!,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(String label, int change, Color color) {
    final isPositive = change > 0;
    final isNeutral = change == 0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : isNeutral ? Icons.remove : Icons.arrow_downward,
          size: 16,
          color: isPositive ? Colors.green : isNeutral ? Colors.grey : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${isPositive ? '+' : ''}$change',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Personal Notes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _entry.notes!,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double value, double max, Color color) {
    final percentage = (value / max).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            Text(
              '+${value.toStringAsFixed(1)}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MysticalTheme.accentColor),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  Color _getChakraColorByName(String chakra) {
    switch (chakra.toLowerCase()) {
      case 'root':
        return Colors.red;
      case 'sacral':
        return Colors.orange;
      case 'solar plexus':
      case 'solarplexus':
        return Colors.yellow;
      case 'heart':
        return Colors.green;
      case 'throat':
        return Colors.blue;
      case 'third eye':
      case 'thirdeye':
        return Colors.indigo;
      case 'crown':
        return Colors.purple;
      case 'all':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _calculateUsageStats() {
    final stats = <String, dynamic>{};
    
    if (_usageLogs.isEmpty) return stats;
    
    // Calculate average mood improvement
    final moodImprovements = _usageLogs
        .where((log) => log.moodBefore != null && log.moodAfter != null)
        .map((log) => (log.moodAfter! - log.moodBefore!).toDouble())
        .toList();
    
    if (moodImprovements.isNotEmpty) {
      stats['avgMoodImprovement'] = 
          moodImprovements.reduce((a, b) => a + b) / moodImprovements.length;
    }
    
    // Calculate average energy improvement
    final energyImprovements = _usageLogs
        .where((log) => log.energyBefore != null && log.energyAfter != null)
        .map((log) => (log.energyAfter! - log.energyBefore!).toDouble())
        .toList();
    
    if (energyImprovements.isNotEmpty) {
      stats['avgEnergyImprovement'] = 
          energyImprovements.reduce((a, b) => a + b) / energyImprovements.length;
    }
    
    // Find most used purpose
    final purposeCounts = <String, int>{};
    for (final log in _usageLogs) {
      purposeCounts[log.purpose] = (purposeCounts[log.purpose] ?? 0) + 1;
    }
    
    if (purposeCounts.isNotEmpty) {
      final sortedPurposes = purposeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      stats['mostUsedPurpose'] = sortedPurposes.first.key;
    }
    
    // Last used date
    stats['lastUsed'] = _usageLogs.first.dateTime;
    
    return stats;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _toggleFavorite() async {
    HapticFeedback.lightImpact();
    await CollectionService.toggleFavorite(_entry.id);
    setState(() {
      _entry = _entry.copyWith(isFavorite: !_entry.isFavorite);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _entry.isFavorite ? 'Added to favorites! 💖' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveUsage() async {
    final log = await CollectionService.recordUsage(
      collectionEntryId: _entry.id,
      purpose: _selectedPurpose,
      intention: _intentionController.text.isEmpty ? null : _intentionController.text,
      result: _resultController.text.isEmpty ? null : _resultController.text,
      moodBefore: _moodBefore,
      moodAfter: _moodAfter,
      energyBefore: _energyBefore,
      energyAfter: _energyAfter,
    );
    
    // Update local state
    setState(() {
      _entry = _entry.recordUsage();
      _usageLogs.insert(0, log);
      _showUsageForm = false;
    });
    
    // Clear form
    _intentionController.clear();
    _resultController.clear();
    _moodBefore = 5;
    _moodAfter = 5;
    _energyBefore = 5;
    _energyAfter = 5;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usage recorded! ✨'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAllUsageLogs() {
    // TODO: Navigate to full usage history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full history coming soon!')),
    );
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _resultController.dispose();
    super.dispose();
  }
}