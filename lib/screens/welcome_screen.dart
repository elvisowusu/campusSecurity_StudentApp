import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:student_app/screens/signin_screen.dart';
import 'package:student_app/screens/signup_screen.dart';
import 'package:student_app/widgets/custom_button.dart';
import 'package:student_app/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      image: 'assets/images/WelcomePhoto.avif',
      customContainer: Stack(
        children: [
          // Background image with blur effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/WelcomePhoto.avif'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 0.3, sigmaY: 0.3), // Adjust blur sigma values
              child: Container(
                color:
                    Colors.white.withOpacity(0.1), // Adjust opacity as needed
              ),
            ),
          ),
          // Content on top of the blurred background
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Buttons and content here
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Expanded(
                      child: WelcomeButton(
                        buttonName: 'Sign In',
                        onTap: const SignInScreen(),
                        textColor: Colors.white,
                        buttonColor: const Color.fromARGB(255, 6, 6, 6).withOpacity(0.7),
                      ),
                    ),
                    Expanded(
                      child: WelcomeButton(
                        buttonName: 'Sign Up',
                        onTap: const SignUpScreen(),
                        textColor: Colors.white,
                        buttonColor: const Color.fromARGB(255, 6, 6, 6).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
