import 'package:flutter/material.dart';

class IndividualChatRoom extends StatefulWidget {
  const IndividualChatRoom({super.key});

  @override
  State<IndividualChatRoom> createState() => _IndividualChatRoomState();
}

class _IndividualChatRoomState extends State<IndividualChatRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Chat Room'),
      ),
    );
  }
}