import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student_app/dashboard/speak%20to%20counsellor/individual_chat_room.dart';

class ChatIconButton extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  ChatIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const IconButton(
            icon: Icon(Icons.chat_rounded),
            tooltip: 'Loading...',
            onPressed: null,
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var counselorId = data['assignedCounsellor'];

        return GestureDetector(
          onTap: counselorId == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          IndividualChatPage(contactId: counselorId),
                    ),
                  );
                },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(9.0), // Match the padding
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0, // Add a border to match the style
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/chat.svg',
                  // ignore: deprecated_member_use
                  color: Colors.white, // Match icon color
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
