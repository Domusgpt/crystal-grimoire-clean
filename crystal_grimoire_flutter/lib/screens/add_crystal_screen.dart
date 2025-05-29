import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crystal.dart';
import '../models/crystal_collection.dart';
import '../services/collection_service.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import 'camera_screen.dart';

class AddCrystalScreen extends StatefulWidget {
  final Crystal? crystal; // Pre-filled if coming from identification

  const AddCrystalScreen({Key? key, this.crystal}) : super(key: key);

  @override
  State<AddCrystalScreen> createState() => _AddCrystalScreenState();
}

class _AddCrystalScreenState extends State<AddCrystalScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  
  // Form values
  String _source = 'purchased';
  String _size = 'medium';
  String _quality = 'tumbled';
  List<String> _selectedPurposes = [];
  Crystal? _selectedCrystal;
  
  // Available options
  final List<String> _sources = ['purchased', 'gifted', 'found', 'inherited', 'traded'];
  final List<String> _sizes = ['tiny', 'small', 'medium', 'large', 'specimen'];
  final List<String> _qualities = ['raw', 'tumbled', 'polished', 'cluster', 'point', 'sphere'];
  final List<String> _purposes = [
    'meditation',
    'healing',
    'protection',
    'manifestation',
    'grounding',
    'sleep',
    'clarity',
    'love',
    'prosperity',
    'chakra work',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCrystal = widget.crystal;
    _nameController = TextEditingController(text: widget.crystal?.name ?? '');
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: MysticalTheme.backgroundGradient,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            '✨ Add to Collection ✨',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                ),
                
                // Form content
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Crystal selection
                      _buildCrystalSelection(),
                      const SizedBox(height: 20),
                      
                      // Source information
                      _buildSourceSection(),
                      const SizedBox(height: 20),
                      
                      // Physical properties
                      _buildPhysicalPropertiesSection(),
                      const SizedBox(height: 20),
                      
                      // Purpose selection
                      _buildPurposeSection(),
                      const SizedBox(height: 20),
                      
                      // Notes
                      _buildNotesSection(),
                      const SizedBox(height: 32),
                      
                      // Save button
                      MysticalButton(
                        onPressed: _saveCrystal,
                        label: 'Add to Collection',
                        icon: Icons.save,
                        isPrimary: true,
                        width: double.infinity,
                        height: 56,
                      ),
                      
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrystalSelection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💎 Crystal Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_selectedCrystal != null) ...[
              // Crystal already selected
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MysticalTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MysticalTheme.primaryColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: MysticalTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCrystal!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _selectedCrystal!.group,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _identifyNewCrystal,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // No crystal selected
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Crystal Name',
                  'Enter the crystal name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a crystal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _identifyNewCrystal,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Identify with Camera'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📍 Source Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Source dropdown
            DropdownButtonFormField<String>(
              value: _source,
              dropdownColor: MysticalTheme.cardColor,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('How acquired', ''),
              items: _sources.map((source) {
                return DropdownMenuItem(
                  value: source,
                  child: Text(
                    source.substring(0, 1).toUpperCase() + source.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _source = value!),
            ),
            
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                'Location',
                'Where did you get it?',
              ),
            ),
            
            if (_source == 'purchased') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                  'Price',
                  'Amount paid (optional)',
                  prefix: '\$',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalPropertiesSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📏 Physical Properties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Size selection
            const Text(
              'Size',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _sizes.map((size) {
                final isSelected = _size == size;
                return ChoiceChip(
                  label: Text(
                    size.substring(0, 1).toUpperCase() + size.substring(1),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _size = size);
                  },
                  selectedColor: MysticalTheme.primaryColor,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Quality selection
            const Text(
              'Quality/Form',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _qualities.map((quality) {
                final isSelected = _quality == quality;
                return ChoiceChip(
                  label: Text(
                    quality.substring(0, 1).toUpperCase() + quality.substring(1),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _quality = quality);
                  },
                  selectedColor: MysticalTheme.primaryColor,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Primary Uses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select all that apply',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _purposes.map((purpose) {
                final isSelected = _selectedPurposes.contains(purpose);
                return FilterChip(
                  label: Text(
                    purpose.substring(0, 1).toUpperCase() + purpose.substring(1),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPurposes.add(purpose);
                      } else {
                        _selectedPurposes.remove(purpose);
                      }
                    });
                  },
                  selectedColor: MysticalTheme.accentColor,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Personal Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: _buildInputDecoration(
                'Notes',
                'Any special properties, experiences, or thoughts about this crystal...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      prefixStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MysticalTheme.accentColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  void _identifyNewCrystal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    ).then((result) {
      if (result != null && result is Crystal) {
        setState(() {
          _selectedCrystal = result;
          _nameController.text = result.name;
        });
      }
    });
  }

  void _saveCrystal() async {
    if (_formKey.currentState!.validate()) {
      // Create crystal object if not already selected
      final crystal = _selectedCrystal ?? Crystal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        scientificName: '',
        group: 'Unknown',
        description: 'User-added crystal',
        metaphysicalProperties: [],
        healingProperties: [],
        chakras: [],
        elements: [],
        properties: {},
        colorDescription: 'Various',
        hardness: '0',
        formation: 'Unknown',
        careInstructions: '',
        imageUrls: [],
      );
      
      // Add to collection
      await CollectionService.addCrystal(
        crystal: crystal,
        source: _source,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        price: _priceController.text.isEmpty 
          ? null 
          : double.tryParse(_priceController.text),
        size: _size,
        quality: _quality,
        primaryUses: _selectedPurposes,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      // Show success and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${crystal.name} added to your collection! ✨'),
          backgroundColor: MysticalTheme.primaryColor,
        ),
      );
      
      Navigator.pop(context);
    }
  }
}