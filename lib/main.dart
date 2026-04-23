import 'package:flutter/material.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/home/presentation/home_screen.dart';

void main() {
  runApp(const GeoWakeApp());
}

class GeoWakeApp extends StatelessWidget {
  const GeoWakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoWake',
      theme: AppTheme.theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
