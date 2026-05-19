import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  runApp(
    const ProviderScope(
      child: CoreVisionApp(),
    ),
  );
}

class CoreVisionApp extends StatelessWidget {
  const CoreVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Core Vision',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Enforcing the dark sleek theme requested
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Welcome to Core Vision, Jayaraj!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}