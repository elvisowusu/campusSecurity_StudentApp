import 'package:flutter/material.dart';
import 'package:student_app/Dashboard/Old%20Cases/individual_chat_room.dart';
import 'package:student_app/common/enum/chat_services.dart';


class StudentPattern extends StatefulWidget {
  final String referenceNumber;

  const StudentPattern({super.key, required this.referenceNumber});

  @override
  State<StudentPattern> createState() => _StudentPatternState();
}

class _StudentPatternState extends State<StudentPattern> {
  final ChatService _chatService = ChatService(); // Initialize the ChatService

  void _navigateToChat(BuildContext context) async {
    String? counsellorId = await _chatService.getAssignedCounsellor();
    if (counsellorId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndividualChatPage(contactId: counsellorId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No counsellor assigned yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome - ${widget.referenceNumber}'),
      ),
      body: const Column(
        children: [
          Text('Map will appear here'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _navigateToChat(context),
        tooltip: 'Chat with Counsellor',
        child: const Icon(Icons.chat_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
