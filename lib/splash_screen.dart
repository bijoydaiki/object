import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:object/questions_page.dart';
import 'package:page_transition/page_transition.dart';



class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset('assets/sheba.png',fit: BoxFit.cover,), // Replace with your image path
      nextScreen: QuestionsPage(),
      splashTransition: SplashTransition.scaleTransition, // Animation type
      pageTransitionType: PageTransitionType.fade, // Page transition type
      backgroundColor: Colors.white, // Background color of splash screen
      duration: 2000, // Duration in milliseconds
    );
  }
}


