//lib/screens/splash_screen.dart

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/NutriNova.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(), // Push content to bottom like image
                  // Welcome (aligned like picture)
                  Text(
                    "Welcome !",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 154, 144, 144),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Your personalized AI meal plan \n"
                    "begins here.",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 154, 144, 144),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Get Started bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          154,
                          144,
                          144,
                        ),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
