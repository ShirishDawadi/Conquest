import 'package:conquest/core/app_colors.dart';
import 'package:conquest/presentation/views/auth/login_screen.dart';
import 'package:conquest/presentation/views/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: -(screenWidth / 2),
            child: Hero(
              tag: 'logo',
              child: SvgPicture.asset(
                'assets/images/logo_screen.svg',
                width: screenWidth * 2,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'conquest',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Vertigo',
                    fontSize: 24,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Outside is the new meta',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gpkn',
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          reverseTransitionDuration: const Duration(
                            milliseconds: 800,
                          ),
                          pageBuilder: (_, __, ___) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: AppColors.greenish_4),
                      backgroundColor: AppColors.greenish_2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          reverseTransitionDuration: const Duration(
                            milliseconds: 800,
                          ),
                          pageBuilder: (_, __, ___) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: AppColors.greenish_2),
                      backgroundColor: AppColors.greenish_4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
