import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<String?> getAssignedCounsellor() async {
    if (currentUser == null) {
      return null;
    }
    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc['assignedCounsellor'];
  }
}
