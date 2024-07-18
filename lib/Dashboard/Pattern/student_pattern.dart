import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/Dashboard/Case%20Analysis/map.dart';
import 'package:student_app/Dashboard/Old%20Cases/individual_chat_room.dart';

class StudentPattern extends StatelessWidget {
  final String referenceNumber;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  StudentPattern({super.key, required this.referenceNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome - $referenceNumber'),
      ),
      body: const Column(
        children: [
          Text('Distress signal is sent here'),
          // Add other widgets as needed for your layout
        ],
      ),
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const FloatingActionButton(
              onPressed: null,
              tooltip: 'Loading...',
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var counselorId = data['assignedCounsellor'];

          return FloatingActionButton(
            onPressed: counselorId == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapSample(),
                      ),
                    );
                  },
            tooltip: counselorId == null
                ? 'No counsellor assigned yet'
                : 'Chat with Counsellor',
            child: const Icon(Icons.chat_rounded),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
