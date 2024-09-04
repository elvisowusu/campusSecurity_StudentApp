import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/dashboard/speak%20to%20counsellor/individual_chat_room.dart';

class ChatIconButton extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  ChatIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('students').doc(currentUser!.uid).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return const IconButton(
            icon: Icon(Icons.chat_rounded),
            tooltip: 'Loading...',
            onPressed: null,
          );
        }

        var data = snapshot.data!.data();
        if (data == null || data is! Map<String, dynamic>) {
          return const IconButton(
            icon: Icon(Icons.chat_rounded),
            tooltip: 'Error: Invalid data',
            onPressed: null,
          );
        }

        var counselorId = data['assignedCounsellor'];
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('counselors')
              .doc(counselorId)
              .collection('chats')
              .doc(currentUser!.uid)
              .collection('messages')
              .where('senderId', isEqualTo: counselorId)
              .where('read', isEqualTo: false)
              .snapshots(),
          builder: (context, messageSnapshot) {
            int unreadCount =
                messageSnapshot.hasData ? messageSnapshot.data!.docs.length : 0;

            return Stack(
              children: [
                GestureDetector(
                  onTap: counselorId == null
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IndividualChatPage(contactId: counselorId),
                            ),
                          );
                          // Clear the unread count after navigation
                          _clearUnreadCount(counselorId);
                        },
                  child: Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          214, 255, 255, 255), // Common background color
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 61, 61, 61)
                              .withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_rounded,
                              size: 32, color: Colors.blue),
                          Text(
                            'Counselor',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _clearUnreadCount(String counselorId) async {
    // Get the unread messages and mark them as read
    QuerySnapshot unreadMessages = await _firestore
        .collection('counselors')
        .doc(counselorId)
        .collection('chats')
        .doc(currentUser!.uid)
        .collection('messages')
        .where('senderId', isEqualTo: counselorId)
        .where('read', isEqualTo: false)
        .get();

    WriteBatch batch = _firestore.batch();
    for (QueryDocumentSnapshot doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
