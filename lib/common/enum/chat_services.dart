import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  static const userIdRef = 'userId';
  Future<String?> getAssignedCounsellor() async {
    if (currentUser == null) {
      return null;
    }
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc['assignedCounsellor'];
  }

  Future<void> saveUserIdToSharedPreference(String userUid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userIdRef, userUid);
  }

  Future<String?> getUserIdFromSharedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString(userIdRef);
    return userUid;
  }
}
