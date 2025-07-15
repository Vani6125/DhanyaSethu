import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'EmailVerificationScreen.dart';
import 'home_page.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (!user.emailVerified) {
            return EmailVerificationScreen(email: user.email ?? '');
          } else {
            return const HomePage();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

