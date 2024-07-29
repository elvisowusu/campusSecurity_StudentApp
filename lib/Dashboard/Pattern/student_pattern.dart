import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/dashboard/Old%20Cases/individual_chat_room.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentPattern extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  StudentPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const IconButton(
                  icon: Icon(Icons.chat_rounded),
                  tooltip: 'Loading...',
                  onPressed: null,
                );
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;
              var counselorId = data['assignedCounsellor'];

              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6), // Padding around the SVG
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 53, 112, 231), // Background color
                    shape: BoxShape.circle, // Circular background
                  ),
                  child: SvgPicture.asset(
                    'assets/chat.svg',
                    // ignore: deprecated_member_use
                    color: Colors.white,
                    width: 30,
                    height: 60,
                  ),
                ),
                tooltip: counselorId == null
                    ? 'No counsellor assigned yet'
                    : 'Chat with Counsellor',
                onPressed: counselorId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IndividualChatPage(counselorId: counselorId),
                          ),
                        );
                      },
              );
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          Text("We'll perform gait analysis and share live location here"),
          // Add other widgets
        ],
      ),
    );
  }
}
