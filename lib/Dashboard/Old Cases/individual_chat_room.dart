import 'package:flutter/material.dart';
import 'package:student_app/widgets/chat_textfield.dart';

class IndividualChatPage extends StatelessWidget {
  final String contact;

  const IndividualChatPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact),
      ),
      body:  Stack(
        children: [
          const Image(
            image: AssetImage('assets/images/chatbg.jpg'),
            width: double.maxFinite,
            height: double.maxFinite,
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                ),
              ),
              const ChatTextField(receriverId: '1')
            ],
          )
        ],
      )
    );
  }
}