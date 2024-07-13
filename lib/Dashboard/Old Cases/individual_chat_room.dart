import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IndividualChatPage extends StatefulWidget {
  const IndividualChatPage({super.key, required this.counselorId});

  final String counselorId;

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chats').add({
        'text': _messageController.text,
        'senderId': currentUser!.uid,
        'receiverId': widget.counselorId,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentUser!.uid, widget.counselorId],
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Counselor'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('participants', arrayContains: currentUser!.uid)
                  .where('participants', arrayContains: widget.counselorId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var messageText = message['text'];
                    var messageSenderId = message['senderId'];

                    return ListTile(
                      title: Align(
                        alignment: messageSenderId == currentUser!.uid
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: messageSenderId == currentUser!.uid
                                ? Colors.blue
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            messageText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
