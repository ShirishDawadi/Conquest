import 'dart:developer';
import 'package:conquest/core/services/location_service.dart';
import 'package:conquest/core/theme/app_theme.dart';
import 'package:conquest/presentation/views/auth/landing_screen.dart';
import 'package:conquest/presentation/views/shell/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService().initialize();
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  log('STARTUP: token exists: ${token != null}', name: 'Main');
  runApp(ProviderScope(child: MainApp(isLoggedIn: token != null)));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      home: isLoggedIn ? const MainScreen() : const LandingScreen(),
      routes: {
        '/home': (context) => const MainScreen(),
        '/landing': (context) => const LandingScreen(),
      },
    );
  }
}