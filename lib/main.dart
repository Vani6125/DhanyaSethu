import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talentfarm/screens/about_screen.dart';
import 'package:talentfarm/screens/auth_wrapper.dart';
import 'package:talentfarm/screens/disease._scree.dart';
import 'package:talentfarm/screens/forget_screen.dart';
import 'package:talentfarm/screens/profile_screen.dart';
import 'package:talentfarm/screens/register_screen.dart';
import 'package:talentfarm/screens/support_screen.dart';
import 'firebase_options.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/EmailVerificationScreen.dart';
import 'screens/soil_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/disease': (context) =>  DiseaseScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/about': (context) => const AboutScreen(),
        '/support': (context) => const SupportScreen(),
        '/soil':(context)=> SoilReportDashboardScreen(),
        '/email-verification': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return EmailVerificationScreen(email: email);
        },
      },
      home: FlutterSplashScreen(
        duration: const Duration(milliseconds: 2500),
        nextScreen: const AuthWrapper(),
        backgroundColor: Colors.white,
        setStateTimer: const Duration(seconds: 3),
        splashScreenBody: Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with proper asset loading
                      Image.asset(
                        'assets/images/rice.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.agriculture,
                            size: 100,
                            color: Colors.deepPurple.shade700,
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // App Name with beautiful styling
                      Text(
                        'DhanyaSetu',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                          letterSpacing: 1.5,
                          shadows: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),

                      // Tagline with delayed animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                'Bridging Agriculture & Technology',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple.shade600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
