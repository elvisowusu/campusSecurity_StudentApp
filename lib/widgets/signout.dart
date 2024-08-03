import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_app/firebase_authentication/firebase_auth_services.dart';
import 'package:student_app/screens/welcome_screen.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          FirebaseAuthService authService = FirebaseAuthService();
          await authService.signOut(); // Use the sign-out method from FirebaseAuthService

          // Navigate to WelcomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        } catch (e) {
          // Show error message using Fluttertoast
          Fluttertoast.showToast(msg: "Error signing out: $e");
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(9.0),
              decoration: BoxDecoration(
                color: Colors.red, // Make the button more noticeable
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout, // Use logout icon for sign-out button
                size: 20.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold, // Make the text bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}
