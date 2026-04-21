import 'package:conquest/presentation/views/auth/landing_screen.dart';
import 'package:conquest/presentation/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  runApp(ProviderScope(child: MainApp(isLoggedIn: token != null)));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MainScreen() : const LandingScreen(),
      routes: {
        '/home': (context) => const MainScreen(),
        '/landing': (context) => const LandingScreen(),
      },
    );
  }
}