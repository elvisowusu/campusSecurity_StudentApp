import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _verificationId;

  // Method to sign up using email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: 'The email address is already in use');
      } else {
        Fluttertoast.showToast(msg: 'An error occurred: ${e.code}');
      }
      return null;
    }
  }

  // Method to sign in using email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Invalid email or password');
      } else {
        Fluttertoast.showToast(msg: 'An error occurred: ${e.code}');
      }
      return null;
    }
  }

  // Method to sign in using Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        return userCredential.user;
      } else {
        Fluttertoast.showToast(msg: 'Google sign-in cancelled');
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Google sign-in error: $e');
      return null;
    }
  }

  // Method to send verification code to the phone number
    Future<void> sendVerificationCode(String phoneNumber) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: 'Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Method to verify the SMS code and sign in the user
  
  Future<bool> verifySmsCode(String smsCode) async {
    if (_verificationId == null) {
      Fluttertoast.showToast(msg: 'Verification ID is null');
      return false;
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _firebaseAuth.currentUser!.linkWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .update({'phoneNumber': user.phoneNumber});
        return true;
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to verify: ${e.toString()}');
      return false;
    }
  }

  // Method to sign in using phone auth credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .update({'phoneNumber': user.phoneNumber});
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to sign in: ${e.toString()}');
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
