import 'package:student_app/common/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle sign-up errors
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle sign-in errors
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Obtain the Google Auth details
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        // Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google Auth credential
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        return userCredential.user;
      } else {
        // User cancelled the Google sign-in flow
        showToast(message: 'Google sign-in cancelled');
        return null;
      }
    } catch (e) {
      showToast(message: 'Google sign-in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
