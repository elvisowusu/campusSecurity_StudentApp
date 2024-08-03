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
              padding: const EdgeInsets.all(11.0), 
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 48, 46, 46),
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
                size: 22.0, // Ensure icon size fits well
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
