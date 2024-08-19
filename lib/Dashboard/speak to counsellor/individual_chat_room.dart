import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/common/enum/message_type.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class IndividualChatPage extends StatefulWidget {
  final String contactId;

  const IndividualChatPage({super.key, required this.contactId});

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  late User? _currentUser;
  late CollectionReference _messagesCollection;
  final ScrollController _scrollController = ScrollController();
  final Map<String, AnimationController> _animationControllers = {};
  String? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _messagesCollection = _firestore
        .collection('counselors')
        .doc(widget.contactId)
        .collection('chats')
        .doc(_currentUser!.uid)
        .collection('messages');
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markMessagesAsRead() async {
    QuerySnapshot unreadMessages = await _messagesCollection
        .where('senderId', isEqualTo: widget.contactId)
        .where('read', isEqualTo: false)
        .get();

    WriteBatch batch = _firestore.batch();
    for (QueryDocumentSnapshot doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> sendMessage(MessageType messageType, String content) async {
    if (content.trim().isEmpty) return;

    final userChatsCollection = _firestore
        .collection('counselors')
        .doc(widget.contactId)
        .collection('chats');

    final userChatDoc = await userChatsCollection.doc(_currentUser!.uid).get();

    if (!userChatDoc.exists) {
      final String userUid = _currentUser!.uid;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userUid)
          .get();
      final data = userDoc.data() as Map<String, dynamic>;
      final String userName = data['fullName'];
      final String referenceNumber = data['Reference number'];

      await userChatsCollection.doc(_currentUser!.uid).set({
        'Name': userName,
        'referenceNumber': referenceNumber,
      });
    }

    await _messagesCollection.add({
      'senderId': _currentUser!.uid,
      'content': content,
      'timestamp': Timestamp.now(),
      'type': messageType.toString(),
      'participants': [_currentUser!.uid, widget.contactId],
      'read': false,
      'replyingTo': _replyingToMessage,
    });

    setState(() {
      _replyingToMessage = null;
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageBubble(String message, bool isMe, String? replyingToMessage,
      Timestamp timestamp, String messageId, MessageType messageType) {
    if (!_animationControllers.containsKey(messageId)) {
      _animationControllers[messageId] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
    final animationController = _animationControllers[messageId]!;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          animationController.value += details.primaryDelta! / 100 * (isMe ? -1 : 1);
        },
        onHorizontalDragEnd: (details) {
          if (animationController.value.abs() > 0.5) {
            setState(() {
              _replyingToMessage = message;
            });
          }
          animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(50 * animationController.value * (isMe ? -1 : 1), 0),
              child: Stack(
                children: [
                  child!,
                  Positioned(
                    left: isMe ? null : 10 * animationController.value,
                    right: isMe ? 10 * animationController.value : null,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.reply,
                        color: Colors.grey[600],
                        size: 20 * animationController.value.abs(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: Radius.circular(isMe ? 16.0 : 0.0),
                bottomRight: Radius.circular(isMe ? 0.0 : 16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (replyingToMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    padding: const EdgeInsets.all(5.0),
                    width: max(3, 420),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      replyingToMessage,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                _buildMessageContent(message, messageType),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(String message, MessageType messageType) {
    switch (messageType) {
      case MessageType.text:
        return Text(
          message,
          style: const TextStyle(color: Colors.black),
        );
      case MessageType.image:
        return Text('Image: $message', style: const TextStyle(color: Colors.black));
      case MessageType.audio:
        return Text('Audio: $message', style: const TextStyle(color: Colors.black));
      case MessageType.video:
        return Text('Video: $message', style: const TextStyle(color: Colors.black));
      case MessageType.gif:
        return Text('GIF: $message', style: const TextStyle(color: Colors.black));
      default:
        return Text(message, style: const TextStyle(color: Colors.black));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: const [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat with Counsellor'),
        ),
        body: Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/chatbg.png'),
        fit: BoxFit.cover,
      ),
    ),
        child:SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messagesCollection.orderBy('timestamp', descending: true).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<DocumentSnapshot> messages = snapshot.data!.docs;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = messages[index];
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String message = data['content'];
                        String senderId = data['senderId'];
                        String? replyingToMessage = data['replyingTo'];
                        Timestamp timestamp = data['timestamp'];
                        MessageType messageType = (data['type'] as String).toEnum();
                        bool isMe = senderId == _currentUser!.uid;

                        return _buildMessageBubble(
                          message,
                          isMe,
                          replyingToMessage,
                          timestamp,
                          document.id,
                          messageType,
                        );
                      },
                    );
                  },
                ),
              ),
              if (_replyingToMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Replying to: $_replyingToMessage',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _replyingToMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () {
                        sendMessage(MessageType.text, _messageController.text);
                      },
                    ),
                  ],
                ),
              ),
            ]
          ),
        ),
      )
      ),
    );
  }
}