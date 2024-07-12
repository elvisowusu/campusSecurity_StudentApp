import 'package:flutter/material.dart';
import 'dart:core';

class IndividualChatPage extends StatefulWidget {
  const IndividualChatPage({super.key, required this.counselorId});

  final String counselorId;

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Counselor'),
      ),
      body: const Column(
        children: [
          Text('Chat with Counselor'),
        ],
      )
    );
  }
}
