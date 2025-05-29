import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CrystalGrimoire());
}

class CrystalGrimoire extends StatelessWidget {
  const CrystalGrimoire({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: '🔮 Crystal Grimoire',
        theme: CrystalTheme.theme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}