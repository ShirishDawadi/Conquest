import 'package:conquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile'),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authViewModelProvider.notifier).logout();
                Navigator.pushReplacementNamed(context, '/landing');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
