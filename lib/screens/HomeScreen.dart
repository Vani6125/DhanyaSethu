import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talentfarm/screens/LoginScreen.dart';
import 'package:talentfarm/screens/SignupScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            // Background image
            SizedBox.expand(
              child: Image.asset(
                'assets/images/home_wallpaper.png',
                fit: BoxFit.cover,
              ),
            ),
            // Foreground content
            SafeArea(
              child: Center(
              
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Home text in white box
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: const Text(
                        'Welcome To Talentfarm',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login and Signup spaced evenly
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.to(()=>LoginScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.8),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.black,fontSize: 20),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                             Get.to(()=>SignupScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.8),
                            ),
                            child: const Text(
                              'Signup',
                              style: TextStyle(color: Colors.black,fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
