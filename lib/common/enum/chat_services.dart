import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/user_session.dart';


class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<String?> getAssignedCounsellor() async {
    if (currentUser == null) {
      return null;
    }
    DocumentSnapshot doc =
        await _firestore.collection('students').doc(currentUser!.uid).get();
    return doc['assignedCounsellor'];
  }

  Future<void> saveUserIdToSession() async {
    if (currentUser == null) {
      return;
    }
    final String userUid = currentUser!.uid;
    await UserSession().saveSession(userUid, '', '',''); // Update with default values or adjust as needed
  }

  Future<String?> getUserIdFromSession() async {
    // Load session data to ensure it's updated
    await UserSession().loadSession();
    return UserSession().studentId;
  }
}
