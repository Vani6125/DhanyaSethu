import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talentfarm/screens/HomeScreen.dart';
import 'package:talentfarm/screens/LoginScreen.dart';
import 'package:talentfarm/screens/SignupScreen.dart';
import 'package:talentfarm/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      getPages: [
        GetPage(name: Routes.LOGIN, page: () => const LoginScreen()),
        GetPage(name: Routes.SIGNUP, page: ()=> const SignupScreen())
    ],
    );
  }
}
