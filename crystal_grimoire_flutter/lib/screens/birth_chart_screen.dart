import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/birth_chart.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';
import '../config/mystical_theme.dart';
import '../services/storage_service.dart';
import '../services/astrology_service.dart';

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({Key? key}) : super(key: key);

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _zodiacController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  
  // Form controllers
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  BirthChart? _existingChart;
  bool _isCalculating = false;
  
  // Zodiac wheel colors
  static const Map<String, Color> zodiacColors = {
    'Aries': Color(0xFFFF6B6B),
    'Taurus': Color(0xFF4ECDC4),
    'Gemini': Color(0xFFFFE66D),
    'Cancer': Color(0xFF95E1D3),
    'Leo': Color(0xFFF38181),
    'Virgo': Color(0xFFAA96DA),
    'Libra': Color(0xFFFCBAD3),
    'Scorpio': Color(0xFF8B5CF6),
    'Sagittarius': Color(0xFFF97B22),
    'Capricorn': Color(0xFF6C5CE7),
    'Aquarius': Color(0xFF00B8D4),
    'Pisces': Color(0xFF5EB7B7),
  };

  @override
  void initState() {
    super.initState();
    _zodiacController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadExistingChart();
  }
  
  Future<void> _loadExistingChart() async {
    final chartData = await StorageService.getBirthChart();
    if (chartData != null) {
      setState(() {
        _existingChart = BirthChart.fromJson(chartData);
        _dateController.text = '${_existingChart!.birthDate.day}/${_existingChart!.birthDate.month}/${_existingChart!.birthDate.year}';
        _timeController.text = _existingChart!.birthTime;
        _locationController.text = _existingChart!.birthLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              const Color(0xFF2D1B69),
              const Color(0xFF0F0F23),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated starfield background
            _buildStarfield(),
            
            // Zodiac wheel background
            if (_existingChart != null)
              _buildZodiacWheel(),
            
            // Main content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: MysticalIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: ShimmeringText(
                      text: '🌟 Birth Chart',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (_existingChart == null)
                            _buildInputForm()
                          else
                            _buildChartDisplay(),
                        ],
                      ),
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
  
  Widget _buildStarfield() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: List.generate(50, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 3 + 1;
            final x = random.nextDouble() * MediaQuery.of(context).size.width;
            final y = random.nextDouble() * MediaQuery.of(context).size.height;
            final twinkle = math.sin(_floatingController.value * 2 * math.pi * (1 + random.nextDouble()));
            
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3 + twinkle * 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: size * 2,
                      spreadRadius: size * 0.5,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
  
  Widget _buildZodiacWheel() {
    return Center(
      child: AnimatedBuilder(
        animation: _zodiacController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _zodiacController.value * 2 * math.pi,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Stack(
                children: List.generate(12, (index) {
                  final angle = (index * 30 - 90) * math.pi / 180;
                  final zodiac = ZodiacSign.values[index];
                  return Positioned(
                    left: 150 + 120 * math.cos(angle) - 20,
                    top: 150 + 120 * math.sin(angle) - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: zodiacColors[zodiac.name]?.withOpacity(0.3),
                        border: Border.all(
                          color: zodiacColors[zodiac.name]?.withOpacity(0.6) ?? Colors.white30,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          zodiac.symbol,
                          style: TextStyle(
                            fontSize: 20,
                            color: zodiacColors[zodiac.name],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInputForm() {
    return FadeScaleIn(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            MysticalCard(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.stars,
                        size: 48,
                        color: MysticalTheme.accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unlock Your Cosmic Blueprint',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your birth details to receive personalized crystal guidance aligned with your astrological chart.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Birth Date
                    _buildInputField(
                      controller: _dateController,
                      label: 'Birth Date',
                      hint: 'DD/MM/YYYY',
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Birth Time
                    _buildInputField(
                      controller: _timeController,
                      label: 'Birth Time',
                      hint: 'HH:MM (24-hour format)',
                      icon: Icons.access_time,
                      onTap: () => _selectTime(context),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Birth Location
                    _buildInputField(
                      controller: _locationController,
                      label: 'Birth Location',
                      hint: 'City, Country',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 24),
                    
                    MysticalButton(
                      onPressed: _isCalculating ? () {} : _calculateChart,
                      label: _isCalculating ? 'Calculating...' : 'Generate Birth Chart',
                      icon: Icons.auto_awesome,
                      isPrimary: true,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Privacy note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your birth information is stored locally and never shared.',
                      style: TextStyle(
                        color: Colors.blue.shade200,
                        fontSize: 12,
                      ),
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
  
  Widget _buildChartDisplay() {
    final chart = _existingChart!;
    
    return Column(
      children: [
        // Main chart card
        FadeScaleIn(
          child: MysticalCard(
            gradientColors: [
              zodiacColors[chart.sunSign.name]?.withOpacity(0.3) ?? Colors.purple.withOpacity(0.3),
              zodiacColors[chart.moonSign.name]?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
            ],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Big Three
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildZodiacInfo('Sun', chart.sunSign),
                      _buildZodiacInfo('Moon', chart.moonSign),
                      _buildZodiacInfo('Rising', chart.ascendant),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Birth info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.cake, 'Born', '${chart.birthDate.day}/${chart.birthDate.month}/${chart.birthDate.year}'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.access_time, 'Time', chart.birthTime),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.location_on, 'Place', chart.birthLocation),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal recommendations
        FadeScaleIn(
          delay: const Duration(milliseconds: 200),
          child: MysticalCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PulsingGlow(
                        glowColor: Colors.amber,
                        child: Icon(Icons.diamond, color: Colors.amber),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Your Crystal Allies',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Based on your astrological blueprint, these crystals resonate strongly with your energy:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chart.getCrystalRecommendations().take(8).map((crystal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withOpacity(0.3),
                              Colors.orange.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          crystal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dominant elements
        FadeScaleIn(
          delay: const Duration(milliseconds: 400),
          child: MysticalCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.whatshot, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text(
                        'Elemental Balance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...chart.getSpiritualContext()['dominantElements'].entries.map((entry) {
                    final element = entry.key as String;
                    final count = entry.value as int;
                    final elementColors = {
                      'Fire': Colors.red,
                      'Earth': Colors.green,
                      'Air': Colors.blue,
                      'Water': Colors.cyan,
                    };
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: elementColors[element]?.withOpacity(0.3),
                              border: Border.all(
                                color: elementColors[element] ?? Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                element[0],
                                style: TextStyle(
                                  color: elementColors[element],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  element,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                LinearProgressIndicator(
                                  value: count / 8,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation(elementColors[element]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count',
                            style: TextStyle(
                              color: elementColors[element],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Actions
        Row(
          children: [
            Expanded(
              child: MysticalButton(
                onPressed: _editChart,
                label: 'Edit Chart',
                icon: Icons.edit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MysticalButton(
                onPressed: _shareChart,
                label: 'Share',
                icon: Icons.share,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: MysticalTheme.accentColor),
        hintStyle: TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: MysticalTheme.accentColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MysticalTheme.accentColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
  
  Widget _buildZodiacInfo(String label, ZodiacSign sign) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zodiacColors[sign.name]?.withOpacity(0.3),
                border: Border.all(
                  color: zodiacColors[sign.name] ?? Colors.grey,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (zodiacColors[sign.name] ?? Colors.grey).withOpacity(0.5 + _pulseController.value * 0.3),
                    blurRadius: 10 + _pulseController.value * 5,
                    spreadRadius: 1 + _pulseController.value * 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  sign.symbol,
                  style: TextStyle(
                    fontSize: 24,
                    color: zodiacColors[sign.name],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          sign.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: MysticalTheme.accentColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: MysticalTheme.accentColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  Future<void> _calculateChart() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isCalculating = true);
    
    try {
      // Get coordinates from location
      final coords = await AstrologyService.getCoordinatesFromLocation(_locationController.text);
      if (coords == null) {
        throw Exception('Could not find location coordinates');
      }
      
      // Calculate birth chart using astrology API
      final chart = await AstrologyService.calculateBirthChart(
        birthDate: _selectedDate!,
        birthTime: _timeController.text,
        birthLocation: _locationController.text,
        latitude: coords['lat']!,
        longitude: coords['lon']!,
      );
      
      // Save to storage
      await StorageService.saveBirthChart(chart.toJson());
      
      setState(() {
        _existingChart = chart;
        _isCalculating = false;
      });
      
      HapticFeedback.heavyImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Birth chart calculated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isCalculating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating chart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _editChart() {
    setState(() {
      _existingChart = null;
    });
  }
  
  void _shareChart() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
  
  @override
  void dispose() {
    _zodiacController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}